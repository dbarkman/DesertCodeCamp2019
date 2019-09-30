//
//  API.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

struct API: Codable {
    var url = ""
    var conferenceIdParameter = ""
    var conferenceEndPoint = ""
    var getConferencesMethod = ""
    var sessionEndPoint = ""
    var getSessionsByConferenceIdMethod = ""
    var getMyInterestedInSessionsByLoginMethod = ""
    var getMyPresentationsByLoginMethod = ""
}
