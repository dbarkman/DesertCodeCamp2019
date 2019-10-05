//
//  APIServices.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import Foundation

class APIServices {
    
    static func getAllData() {
        if  UserDefaults.standard.string(forKey: "conferenceId") != nil &&
            UserDefaults.standard.string(forKey: "hashTag") != nil &&
            UserDefaults.standard.string(forKey: "subdomain") != nil
        {
            getSessionsByConferenceId(getSessionsHandler: { json, response in })
        } else {
            getConferences(getConferencesHandler: { json, response in })
        }
    }
    
    static func getAPISettings() -> API {
        var apiSettings = API()
        if  let path = Bundle.main.path(forResource: "api", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
            let api = try? PropertyListDecoder().decode(API.self, from: xml)
        {
            apiSettings = api
        }
        return apiSettings
    }
    
    static func getConferences(getConferencesHandler: @escaping (JSON, HTTPURLResponse) -> Void) {
        let apiSettings = getAPISettings()
        if let url = URL(string: apiSettings.url + apiSettings.conferenceEndPoint + apiSettings.getConferencesMethod) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            Network.callAPI(request: request, callAPIClosure: { json, response in
                let conferenceArray = json.arrayValue
                if  let currentConference = conferenceArray.last {
                    let conferenceId = currentConference["ConferenceId"].rawString()
                    let hashTag = currentConference["HashTag"].rawString()
                    let subdomain = currentConference["Subdomain"].rawString()
                    let domain = currentConference["Domain"].rawString()
                    let conferenceState = currentConference["State"]["StateId"].int
                    let conferenceTitle = currentConference["ConferenceTitle"].rawString()
                    let dateStart = currentConference["DateStart"].rawValue
                    let dateEnd = currentConference["DateEnd"].rawValue
                    let locationName = currentConference["Location"]["DisplayName"].rawString()
                    let address1 = currentConference["Location"]["Address"]["Address1"].rawString()
                    let address2 = currentConference["Location"]["Address"]["Address2"].rawString()
                    let city = currentConference["Location"]["Address"]["City"].rawString()
                    let state = currentConference["Location"]["Address"]["State"].rawString()
                    let zip = currentConference["Location"]["Address"]["Zip"].rawString()
                    UserDefaults.standard.set(conferenceId, forKey: "conferenceId")
                    UserDefaults.standard.set(hashTag, forKey: "hashTag")
                    UserDefaults.standard.set(subdomain, forKey: "subdomain")
                    UserDefaults.standard.set(domain, forKey: "domain")
                    UserDefaults.standard.set(conferenceState, forKey: "conferenceState")
                    UserDefaults.standard.set(conferenceTitle, forKey: "conferenceTitle")
                    UserDefaults.standard.set(dateStart, forKey: "dateStart")
                    UserDefaults.standard.set(dateEnd, forKey: "dateEnd")
                    UserDefaults.standard.set(locationName, forKey: "locationName")
                    UserDefaults.standard.set(address1, forKey: "address1")
                    UserDefaults.standard.set(address2, forKey: "address2")
                    UserDefaults.standard.set(city, forKey: "city")
                    UserDefaults.standard.set(state, forKey: "state")
                    UserDefaults.standard.set(zip, forKey: "zip")
                    getAllData()
                }
            })
        }
    }
    
    static func getSessionsByConferenceId(getSessionsHandler: @escaping (JSON, HTTPURLResponse) -> Void) {
        let apiSettings = getAPISettings()
        if let conferenceId = UserDefaults.standard.string(forKey: "conferenceId") {
            getSessions(by: apiSettings.getSessionsByConferenceIdMethod, with: apiSettings.conferenceIdParameter, for: conferenceId, getSessionsHandler: { json, response in
                let coreDataServices = CoreDataServices()
                coreDataServices.updateSessions(json: json)
                getSessionsHandler(json, response)
            })
        }
    }
    
    static func getSessions(by method: String, with parameter: String, for value: String, getSessionsHandler: @escaping (JSON, HTTPURLResponse) -> Void) {
        let apiSettings = getAPISettings()
        if let url = URL(string: apiSettings.url + apiSettings.sessionEndPoint + method + "?" + parameter + "=" + value) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            Network.callAPI(request: request, callAPIClosure: { json, response in
                getSessionsHandler(json, response)
            })
        }
    }

    static func getMyInterestedInSessionsByLogin(getMyInterestedInSessionsByLoginHandler: @escaping (JSON, HTTPURLResponse) -> Void) {
        if  let login = UserDefaults.standard.string(forKey: "login"),
            let subdomain = UserDefaults.standard.string(forKey: "subdomain"),
            let domain = UserDefaults.standard.string(forKey: "domain") {
            if let url = URL(string: getAPISettings().url + getAPISettings().sessionEndPoint + getAPISettings().getMyInterestedInSessionsByLoginMethod + "?" + "login=" + login + "&" + "subdomain=" + subdomain  + "&" + "domain=" + domain) {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                Network.callAPI(request: request, callAPIClosure: { json, response in
                    getMyInterestedInSessionsByLoginHandler(json, response)
                })
            }
        }
    }
    
    static func getMyPresentationsByLogin(getMyPresentationsByLoginHandler: @escaping (JSON, HTTPURLResponse) -> Void) {
        if  let login = UserDefaults.standard.string(forKey: "login"),
            let subdomain = UserDefaults.standard.string(forKey: "subdomain"),
            let domain = UserDefaults.standard.string(forKey: "domain") {
            if let url = URL(string: getAPISettings().url + getAPISettings().sessionEndPoint + getAPISettings().getMyPresentationsByLoginMethod + "?" + "login=" + login + "&" + "subdomain=" + subdomain  + "&" + "domain=" + domain) {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                Network.callAPI(request: request, callAPIClosure: { json, response in
                    getMyPresentationsByLoginHandler(json, response)
                })
            }
        }
    }
}
