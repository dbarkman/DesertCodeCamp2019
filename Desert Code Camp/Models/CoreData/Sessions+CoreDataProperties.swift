//
//  Sessions+CoreDataProperties.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/23/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension Sessions {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Sessions> {
        return NSFetchRequest<Sessions>(entityName: "Sessions")
    }

    @NSManaged public var abstract: String
    @NSManaged public var conferenceId: Int16
    @NSManaged public var endDate: Date
    @NSManaged public var inMySchedule: Bool
    @NSManaged public var isApproved: Bool
    @NSManaged public var name: String
    @NSManaged public var room: String
    @NSManaged public var sessionId: Int16
    @NSManaged public var startDate: Date
    @NSManaged public var time: String
    @NSManaged public var track: String

}
