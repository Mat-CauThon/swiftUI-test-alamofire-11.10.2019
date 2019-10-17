//
//  Data.swift
//  Project42
//
//  Created by Roman Mishchenko on 17.10.2019.
//  Copyright © 2019 Roman Mishchenko. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import Alamofire


class ParsedData {
    var parseDict: [String: Any]
    var usersDict: [Any]
    init(value: Any) {
        parseDict = value as? [String: Any] ?? [:]
        usersDict = parseDict["data"] as? [Any] ?? []
    }
}

var data: ParsedData!

let url = "https://reqres.in/api/users?page=2"
let safeURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

let headers: HTTPHeaders = [
    "Authorization": "Basic VXNlcm5hbWU6UGFzc3dvcmQ=",
    "Accept": "application/json"
]


var queryF = ""
var queryL = ""

var appDelegate = UIApplication.shared.delegate as! AppDelegate
var context = PersistentService.persistentContainer.viewContext
var fetchedRC: NSFetchedResultsController<User>!
var sortCheck = true


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



func removeData(indexPath: IndexPath) {
    context.delete(fetchedRC.object(at: indexPath))
    do {
        try context.save()
        print("saved!")
    } catch let error as NSError {
        print("Could not save \(error), \(error.userInfo)")
    } catch {}

    refresh(ascending: sortCheck)
}


func removeAllData() {
    let moc = PersistentService.context
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
    let result = try? moc.fetch(fetchRequest)
    let resultData = result as! [User]
    for object in resultData {
        moc.delete(object)
    }
    do {
        try context.save()
        print("saved!")
    } catch let error as NSError {
        print("Could not save \(error), \(error.userInfo)")
    } catch {}
    refresh(ascending: sortCheck)
}
