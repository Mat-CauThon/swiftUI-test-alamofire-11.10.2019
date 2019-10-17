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






struct UsersRow: View {
    var user: User

    var body: some View {
        HStack {
            Image(uiImage: UIImage(data: user.image!)!)
                .resizable()
                .frame(width: 50, height: 50)
            Text((user.lastName ?? "Someone") + " " + (user.name ?? "unknow"))
            Spacer()
        }
    }
}



struct UserList: View {
    
    @State private var first: String = ""
    @State private var last: String = ""
    
    //i'm tried to avoid usersLocal and work with fetchedRC.fetchedObjects but it does not work 🤷‍♂️
    @State private var usersLocal: [User] = []
    
    func delete(at offsets: IndexSet) {
       
        let index = Array(offsets).first
        usersLocal.remove(at: index!)
        removeData(indexPath: IndexPath(item: index!, section: 0))
        
        
    }
    
    
    var body: some View {
        NavigationView {
            
            VStack {
                HStack {
                    Spacer()
                    //sort buttons
                    if sortCheck {
                        //up sort
                        Button(action: {
                            sortCheck.toggle()
                            refresh(ascending: sortCheck)
                            self.usersLocal = fetchedRC.fetchedObjects!
                            
                        }) {
                            Text("Ascending")
                            .foregroundColor(Color.blue)
                        }
                    } else {
                        //down sort
                        Button(action: {
                            sortCheck.toggle()
                            refresh(ascending: sortCheck)
                            self.usersLocal = fetchedRC.fetchedObjects!
                            
                        }) {
                            Text("Descending")
                            .foregroundColor(Color.blue)
                        }
                    }
                        
                    Spacer()
                    //load data button
                    Button(action: {
                        //clean old data
                        removeAllData()
                        self.usersLocal = []
                            
                        
                        request(safeURL, method: .get, encoding: URLEncoding.default, headers: headers)
                        .validate()
                        
                        .responseJSON { (response) in
                            switch response.result {
                                case .success(let value):
                                    //loaded data
                                    data = ParsedData.init(value: value)
                                    
                                    //every user from data
                                    for user in data.usersDict {
                                        
                                        let userToSave = User(entity: User.entity(), insertInto: context)
                                        guard let userInfo = user as? [String: Any] else {return}
                                        userToSave.imageUrl = userInfo["avatar"] as? String
                                        userToSave.email = userInfo["email"] as? String
                                        userToSave.name = userInfo["first_name"] as? String
                                        userToSave.id = (userInfo["id"] as? Int32)!
                                        userToSave.lastName = userInfo["last_name"] as? String
                                                            
                                                
                                        var image: UIImage?
                                        let url = NSURL(string: userToSave.imageUrl!)! as URL
                                        if let imageData: NSData = NSData(contentsOf: url) {
                                            image = UIImage(data: imageData as Data)
                                        }
                                        
                                        userToSave.image = image?.pngData()
                                        PersistentService.saveContext()
                                               
                                    }
                                            
                                    refresh(ascending: sortCheck)
                                    self.usersLocal = fetchedRC.fetchedObjects!
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
                    //filter fields
                    TextField("First letter", text: $first)
                    TextField("Secons letter", text: $last)
                    
                    //filter button
                    Button(action: {
                        queryF = self.first
                        queryL = self.last
                        refresh(ascending: sortCheck)
                        self.usersLocal = fetchedRC.fetchedObjects!
                                   
                                    
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
                refresh(ascending: sortCheck)
                self.usersLocal = fetchedRC.fetchedObjects ?? []
            })
            
            .navigationBarTitle(Text("Some users"))
        }
    }
    
}

