//
//  SessionsUpdatedEvent.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/20/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let sessionsUpdated = Notification.Name("sessionsUpdated")
    
    static let needLogin = Notification.Name("needLogin")
}
