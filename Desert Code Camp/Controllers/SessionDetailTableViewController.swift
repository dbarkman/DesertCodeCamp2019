//
//  SessionDetailTableViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/22/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit
import CoreData

class SessionDetailTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    var container: NSPersistentContainer!
    var sessionPredicate: NSPredicate?
    var sessionName = String()
    var sessionId = Int16()
    var session = Sessions()
    var presenters = [Presenters]()
    var presenterArray = [String]()

    // MARK: - Main Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
        
        do {
            try container = PersistentContainer.container(name: "DesertCodeCamp")
            container.loadPersistentStores { storeDescription, error in
                self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                if let error = error {
                    print("Unresolved error \(error)")
                }
            }
        } catch {
            print("An error occured: \(error)")
        }

//        title = sessionName
        print("here 👍🏻 \(sessionId)")
        
        loadSession()
        loadPresenters()
    }

    // MARK: - Core Data Fetching

    func loadSession() {
        let request = Sessions.createFetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        request.sortDescriptors = [sort]
        self.sessionPredicate = NSPredicate(format: "sessionId = %i", sessionId)
        request.predicate = sessionPredicate

        do {
            let sessions = try container.viewContext.fetch(request)
            session = sessions[0]
            print("session: \(sessions[0].name)")
            tableView.reloadData()
        } catch {
            print("Fetch failed 😭")
        }
    }
    
    func loadPresenters() {
        let request = Presenters.createFetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        self.sessionPredicate = NSPredicate(format: "sessionId = %i", sessionId)
        request.predicate = sessionPredicate

        do {
            presenters = try container.viewContext.fetch(request)
            for presenter in presenters {
                presenterArray.append(presenter.name)
                presenterArray.append(presenter.email)
                presenterArray.append(presenter.twitterHandle)
            }
            tableView.reloadData()
        } catch {
            print("Fetch failed 😭")
        }
    }
}

// MARK: - Extentions

// MARK: - TableView Methods

extension SessionDetailTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = ""
        switch section {
        case 0:
            sectionTitle = "Session"
        case 1:
            if presenters.count > 1 {
                sectionTitle = "Presenters"
            } else {
                sectionTitle = "Presenter"
            }
        case 2:
            sectionTitle = "Details"
        default:
            sectionTitle = ""
        }
        return sectionTitle
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch section {
        case 0:
            numberOfRows = 2
        case 1:
            numberOfRows = 3 * presenters.count
        case 2:
            numberOfRows = 2
        default:
            numberOfRows = 0
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        if let label = cell.textLabel {
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    label.text = session.name
                case 1:
                    label.text = session.abstract
                default:
                    label.text = ""
                }
            case 1:
                cell.selectionStyle = .default
                label.text = presenterArray[indexPath.row]
            case 2:
                switch indexPath.row {
                case 0:
                    label.text = session.room
                case 1:
                    label.text = session.time
                default:
                    label.text = ""
                }
            default:
                label.text = ""
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPathSelected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathSelected, animated: true)
        }
    }
}
