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
            print("got everything!")
            getSessionsByConferenceId(getSessionsHandler: { json, response in })
        } else {
            print("something is missing")
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
        print("getting conferences")
        let apiSettings = getAPISettings()
        if let url = URL(string: apiSettings.url + apiSettings.conferenceEndPoint + apiSettings.getConferencesMethod) {
            print("url: \(url)")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            Network.callAPI(request: request, callAPIClosure: { json, response in
                let conferenceArray = json.arrayValue
                if  let currentConference = conferenceArray.last {
                    let conferenceId = currentConference["ConferenceId"].rawString()
                    let hashTag = currentConference["HashTag"].rawString()
                    let subdomain = currentConference["Subdomain"].rawString()
                    UserDefaults.standard.set(conferenceId, forKey: "conferenceId")
                    UserDefaults.standard.set(hashTag, forKey: "hashTag")
                    UserDefaults.standard.set(subdomain, forKey: "subdomain")
                    getAllData()
                }
//                print("response: \(response.statusCode)")
//                print("json: \(json)")
            })
        }
    }
    
    static func getSessionsByConferenceId(getSessionsHandler: @escaping (JSON, HTTPURLResponse) -> Void) {
        let apiSettings = getAPISettings()
        if let conferenceId = UserDefaults.standard.string(forKey: "conferenceId") {
            getSessions(by: apiSettings.getSessionsByConferenceIdMethod, with: apiSettings.conferenceIdParameter, for: conferenceId, getSessionsHandler: { json, response in
                getSessionsHandler(json, response)
            })
        }
    }
    
    static func getSessions(by method: String, with parameter: String, for value: String, getSessionsHandler: @escaping (JSON, HTTPURLResponse) -> Void) {
        print("getting sessions")
        let apiSettings = getAPISettings()
        if let url = URL(string: apiSettings.url + apiSettings.sessionEndPoint + method + "?" + parameter + "=" + value) {
            print("url: \(url)")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            Network.callAPI(request: request, callAPIClosure: { json, response in
//                print("response: \(response.statusCode)")
//                print("json: \(json.arrayValue.count)")
                getSessionsHandler(json, response)
            })
        }
    }
}
