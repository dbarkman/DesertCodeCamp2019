//
//  CoreDataServices.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import CoreData

class CoreDataServices {

    var container: NSPersistentContainer!
    let formatter = DateFormatter()
    
    // MARK: - Utility Functions
    
    init() {
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        do {
            try container = PersistentContainer.container(name: "DesertCodeCamp")
            container.loadPersistentStores { storeDescription, error in
                self.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                if let error = error {
                    print("Unresolved error \(error)")
                }
            }
        } catch {
            print("An error occured: \(error)")
        }
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    // MARK: - Update Database Calls
    
    // MARK: - Update Sessions

    func updateSessions(json: JSON) {
        let jsonSessionArray = json.arrayValue
        DispatchQueue.main.async {
            for jsonSession in jsonSessionArray {
                var startDate = Date()
                var endDate = Date()
                var time = "Not Scheduled"
                var room = "Not Assigned"
                if  let sessionId = jsonSession["SessionId"].int16,
                    let isApproved = jsonSession["IsApproved"].bool,
                    let name = jsonSession["Name"].rawString(),
                    let abstract = jsonSession["Abstract"].rawString(),
                    let track = jsonSession["Track"]["Name"].rawString(),
                    let conferenceId = jsonSession["Conference"]["ConferenceId"].int16
                {
                    if  let timeDictionary = jsonSession["Time"].dictionary,
                        let tempTime = timeDictionary["Name"]?.rawString(),
                        let startDateString = timeDictionary["StartDate"]?.stringValue,
                        let startDateDate = self.formatter.date(from: startDateString),
                        let endDateString = timeDictionary["EndDate"]?.stringValue,
                        let endDateDate = self.formatter.date(from: endDateString)
                    {
                        time = tempTime
                        startDate = startDateDate
                        endDate = endDateDate
                    }
                    if let roomDictionary = jsonSession["Room"].dictionary, let tempRoom = roomDictionary["Name"]?.stringValue {
                        room = tempRoom
                    }
                    let jsonPresenterArray = jsonSession["Presenters"].arrayValue
                    for jsonPresenter in jsonPresenterArray {
                        if  let name = jsonPresenter["User"]["DisplayName"].rawString(),
                            let email = jsonPresenter["User"]["Email"].rawString(),
                            let twitterHandle = jsonPresenter["User"]["TwitterHandle"].rawString(),
                            let facebookId = jsonPresenter["User"]["FacebookId"].rawString(),
                            let biography = jsonPresenter["User"]["Biography"].rawString(),
                            let userId = jsonPresenter["User"]["UserId"].rawString(),
                            let sessionIdString = jsonSession["SessionId"].rawString(),
                            let isPrimary = jsonPresenter["IsPrimary"].bool
                        {
                            let presenter = Presenters(context: self.container.viewContext)
                            presenter.name = name
                            presenter.email = email
                            presenter.twitterHandle = twitterHandle
                            presenter.facebookId = facebookId
                            presenter.biography = biography
                            presenter.isPrimary = isPrimary
                            presenter.sessionId = sessionId
                            if let presenterInt = Int64(userId + sessionIdString) {
                                presenter.presenterId = presenterInt
                            }
                        }
                    }
                    let session = Sessions(context: self.container.viewContext)
                    session.sessionId = sessionId
                    session.isApproved = isApproved
                    session.name = name
                    session.abstract = abstract
                    session.startDate = startDate
                    session.endDate = endDate
                    session.time = time
                    session.room = room
                    session.track = track
                    session.conferenceId = conferenceId
                }
            }
            self.saveContext()
            NotificationCenter.default.post(name: .sessionsUpdated, object: nil)
        }
    }
}
