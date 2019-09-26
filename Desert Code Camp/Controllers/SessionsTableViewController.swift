//
//  SessionsTableViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/12/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit
import CoreData

protocol SessionsTableViewControllerDelegate {
    func toggleLeftPanel()
    func collapseSidePanels()
}

class SessionsTableViewController : UITableViewController {
    
    // MARK: - Variables
    
    var container: NSPersistentContainer!
    var sessionPredicate: NSPredicate?
    var filterType = String()
    var filter = String()
    var keys = [String]()
    var sessionsDictionary = [String: [Sessions]]()
    var sessions = [Sessions]()
    var delegate: SessionsTableViewControllerDelegate?
    var isRootViewController = false

    // MARK: - Main Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isRootViewController {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(openMenu))
        }
        navigationItem.backBarButtonItem?.title = filter

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

        title = filter
        
        loadSessions()
    }
    
    @objc func openMenu() {
        delegate?.toggleLeftPanel()
    }
    
    // MARK: - Core Data Fetching

    func loadSessions() {
        let request = Sessions.createFetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        request.sortDescriptors = [sort]
        if filterType == "tracks" {
            self.sessionPredicate = NSPredicate(format: "isApproved == true AND track == %@", filter)
        } else if filterType == "times" {
            self.sessionPredicate = NSPredicate(format: "isApproved == true AND time == %@", filter)
        }
        request.predicate = sessionPredicate

        do {
            sessions = try container.viewContext.fetch(request)
            for session in sessions {
                if filterType == "tracks" {
                    if !sessionsDictionary.keys.contains(session.time) {
                        let tempArray = [session]
                        sessionsDictionary[session.time] = tempArray
                        keys.append(session.time)
                    } else {
                        var tempArray = sessionsDictionary[session.time]
                        sessionsDictionary.removeValue(forKey: session.time)
                        tempArray?.append(session)
                        tempArray?.sort(by: { $0.name < $1.name })
                        sessionsDictionary[session.time] = tempArray
                    }
                } else if filterType == "times" {
                    if !sessionsDictionary.keys.contains(session.track) {
                        let tempArray = [session]
                        sessionsDictionary[session.track] = tempArray
                        keys.append(session.track)
                    } else {
                        var tempArray = sessionsDictionary[session.track]
                        sessionsDictionary.removeValue(forKey: session.track)
                        tempArray?.append(session)
                        tempArray?.sort(by: { $0.name < $1.name })
                        sessionsDictionary[session.track] = tempArray
                    }
                }
            }
            if filterType == "times" {
                keys.sort()
            }
            tableView.reloadData()
        } catch {
            print("Fetch failed 😭")
        }
    }
}

// MARK: - Extentions

// MARK: - TableView Methods

extension SessionsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sessionsDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = keys[section]
        return title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let title = keys[section]
        var rowsCount = 1
        if let tempArray = sessionsDictionary[title] {
            rowsCount = tempArray.count
        }
        return rowsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let label = cell.textLabel {
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            let title = keys[indexPath.section]
            if let tempArray = sessionsDictionary[title] {
                let session = tempArray[indexPath.row]
                label.text = session.name
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = keys[indexPath.section]
        if let tempArray = sessionsDictionary[title] {
            let session = tempArray[indexPath.row]
            if let sessionDetailTableViewController = storyboard?.instantiateViewController(withIdentifier: "sessionDetail") as? SessionDetailTableViewController {
                sessionDetailTableViewController.sessionName = session.name
                sessionDetailTableViewController.sessionId = session.sessionId
                navigationController?.pushViewController(sessionDetailTableViewController, animated: true)
            }
        }
    }
}
