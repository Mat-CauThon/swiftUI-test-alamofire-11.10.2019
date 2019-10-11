//
//  User+CoreDataProperties.swift
//  
//
//  Created by Roman Mishchenko on 11.10.2019.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var imageUrl: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var image: Data?

}
