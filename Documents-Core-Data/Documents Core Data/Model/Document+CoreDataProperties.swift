//
//  Document+CoreDataProperties.swift
//  Documents Core Data
//
//  Created by Chris Rehagen on 3/19/19.
//  Copyright © 2019 Dale Musser. All rights reserved.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var content: String?
    @NSManaged public var name: String?
    @NSManaged public var rawImage: NSData?
    @NSManaged public var rawModifiedDate: NSDate?
    @NSManaged public var size: Int64

}
