//
//  Presenters+CoreDataProperties.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/23/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension Presenters {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Presenters> {
        return NSFetchRequest<Presenters>(entityName: "Presenters")
    }

    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var twitterHandle: String
    @NSManaged public var facebookId: String
    @NSManaged public var biography: String
    @NSManaged public var sessionId: Int16
    @NSManaged public var presenterId: Int64
    @NSManaged public var isPrimary: Bool

}
