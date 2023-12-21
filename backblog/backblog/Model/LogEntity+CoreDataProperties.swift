//
//  LogEntity+CoreDataProperties.swift
//  backblog
//
//  Created by Nick Abegg on 12/20/23.
//
//

import Foundation
import CoreData


extension LogEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogEntity> {
        return NSFetchRequest<LogEntity>(entityName: "LogEntity")
    }

    @NSManaged public var logname: String?
    @NSManaged public var logid: Int64

}

extension LogEntity : Identifiable {

}
