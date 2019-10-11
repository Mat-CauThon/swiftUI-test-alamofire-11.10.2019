//
//  ContentView.swift
//  Project42
//
//  Created by Roman Mishchenko on 10.10.2019.
//  Copyright © 2019 Roman Mishchenko. All rights reserved.
//

import SwiftUI
import CoreData
import Alamofire


let headers: HTTPHeaders = [
    "Authorization": "Basic VXNlcm5hbWU6UGFzc3dvcmQ=",
    "Accept": "application/json"
]


var queryF = ""
var queryL = ""
var filtered = [User]()



struct UsersRow: View {
    var user: User

    var body: some View {
        HStack {
          //  Image(data: user.image!)
            Image(uiImage: UIImage(data: user.image!)!)
                .resizable()
                .frame(width: 50, height: 50)
            Text((user.lastName ?? "Someone") + " " + (user.name ?? "unknow"))
           // Text(user.email)
            Spacer()
        }
    }
}





struct UserList: View {
    
    @State private var first: String = ""
    @State private var last: String = ""
    
    @State private var sortCheck = true
    @State private var usersLocal: [User] = []
    
    @State private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @State private var context = PersistentService.persistentContainer.viewContext
    @State private var fetchedRC: NSFetchedResultsController<User>!
    func refresh(ascending: Bool) {
            
            
                 let request = User.fetchRequest() as NSFetchRequest<User>
                 if !queryF.isEmpty && !queryL.isEmpty {
                     request.predicate = NSCompoundPredicate(
                         type: .and,
                         subpredicates: [
                             NSPredicate(format: "lastName CONTAINS[cd] %@", queryF),
                             NSPredicate(format: "lastName CONTAINS[cd] %@", queryL)
                         ]
                     )

                 }
                 let sort = NSSortDescriptor(key: #keyPath(User.lastName), ascending: ascending, selector: #selector(NSString.caseInsensitiveCompare(_:)))
                 request.sortDescriptors = [sort]
                 do {
                    fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                     try fetchedRC.performFetch()
                 } catch let error as NSError {
                     print("Could not fetch. \(error), \(error.userInfo)")
                 }
                
             

        }
    
    
    
    
    func delete(at offsets: IndexSet) {
       
        let index = Array(offsets).first
        usersLocal.remove(at: index!)
        
        self.context.delete(self.fetchedRC.object(at: IndexPath(item: index!, section: 0)))
        do {
            try self.context.save()
            print("saved!")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        } catch {}

        self.refresh(ascending: sortCheck)
        
    }
    
    var body: some View {
        NavigationView {
            
            VStack {
                HStack {
                    Spacer()
                    if sortCheck {
                        Button(action: {
                            self.sortCheck.toggle()
                            //print(sortCheck)
                            self.refresh(ascending: self.sortCheck)
                            self.usersLocal = self.fetchedRC.fetchedObjects!
                            
                        }) {
                        Text("Ascending")
                            .foregroundColor(Color.blue)
                        }
                    } else {
                        Button(action: {
                            self.sortCheck.toggle()
                            self.refresh(ascending: self.sortCheck)
                            self.usersLocal = self.fetchedRC.fetchedObjects!
                            
                            
                            
                        }) {
                        Text("Descending")
                            .foregroundColor(Color.blue)
                        }
                    }
                        
                        Spacer()
                        Button(action: {
                            
                            let moc = PersistentService.context
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                            let result = try? moc.fetch(fetchRequest)
                            let resultData = result as! [User]
                            for object in resultData {
                                moc.delete(object)
                            }
                            do {
                                try self.context.save()
                                print("saved!")
                            } catch let error as NSError {
                                print("Could not save \(error), \(error.userInfo)")
                            } catch {}
                            self.refresh(ascending: self.sortCheck)
                            self.usersLocal = []
                            
                            let url = "https://reqres.in/api/users?page=2"
                                       
                                        let safeURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                    
                                        request(safeURL, method: .get, encoding: URLEncoding.default, headers: headers)
                                                            
                                        .validate()
                                        .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                                           // print("Progress: \(progress)")
                                            //не работает для полосы загрузки, Parent: 0x0 (portion: 0) / Fraction completed: 0.0000 / Completed: 436209 of -1
                                        }
                                                        
                                        .responseJSON { (response) in
                                        
                                                            
                                        switch response.result {
                                            case .success(let value):
                                            
                    
                                            
                                            guard let parseDict = value as? [String: Any] else {return}
                                       
                                            guard let usersDict = parseDict["data"] as? [Any] else {return}
                                           
                             
                                            for user in usersDict {
                                                let userToSave = User(entity: User.entity(), insertInto: self.context)
                                            
                                                guard let userInfo = user as? [String: Any] else {return}
                                                guard let avatarLink = userInfo["avatar"] as? String else {return}
                                                guard let email = userInfo["email"] as? String else {return}
                                                guard let firstName = userInfo["first_name"] as? String else {return}
                                                guard let id = userInfo["id"] as? Int else {return}
                                                guard let lastName = userInfo["last_name"] as? String else {return}
                                                            
                                                userToSave.imageUrl = avatarLink
                                                userToSave.name = firstName
                                                userToSave.lastName = lastName
                                                userToSave.email = email
                                                userToSave.id = Int32(id)
                                                
                                                var image: UIImage?
                                                let url = NSURL(string: avatarLink)! as URL
                                                if let imageData: NSData = NSData(contentsOf: url) {
                                                    image = UIImage(data: imageData as Data)
                                                }
                                                
                                                userToSave.image = image?.pngData()
                                                
                                               
                                                
//                                                print(avatarLink)
//                                                print(email)
//                                                print(firstName)
//                                                print(lastName)
//                                                print(id)
                                                PersistentService.saveContext()
                                                print("---------------------")
                                                
                                               
                                                
                                            
                                               
                                               
                                                             
                                                    
                                            }
                                            
                                            self.refresh(ascending: self.sortCheck)
                                          
                                            self.usersLocal = self.fetchedRC.fetchedObjects!
                                            break
                                            case .failure(let error):
                                                
                                                print(error)
                                             
                                        }
                                           
                                                        
                                        }
                                    
                                    
                        }) {
                        Text("Load again")
                            .foregroundColor(Color.blue)
                        }
                    Spacer()
                }
                HStack {
                    Spacer()
                    
                    //wtf how get only 1 character
                    TextField("First letter", text: $first)
                    TextField("Secons letter", text: $last)
                    
                                
                
                                Button(action: {
                                    
                                    print(self.first)
                                    print(self.last)
                                    queryF = self.first
                                    queryL = self.last
                                    
                                    self.refresh(ascending: self.sortCheck)
                                    self.usersLocal = self.fetchedRC.fetchedObjects!
                                   
                                    
                                }) {
                                    Text("Select")
                                        .foregroundColor(Color.blue)
                                }
                    Spacer()
                }
                List{
                               
                               
                               
                    ForEach(usersLocal) { user in
                               
                        UsersRow(user: user)
                                   
                               
                    } .onDelete(perform: delete)
                           
                }
            }.onAppear(perform: {
                self.refresh(ascending: self.sortCheck)
                self.usersLocal = self.fetchedRC.fetchedObjects ?? []
            })
            
            .navigationBarTitle(Text("Some users"))
        }
    }
    
}

