//
//  TracksTimesTableViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit
import CoreData

class TracksTimesTableViewController: UITableViewController {

    // MARK: - Variables
    
    var container: NSPersistentContainer!
    var filterPredicate: NSPredicate?
    var filters = [String]()
    var filter = "tracks"
    var trackTimesButton = UIBarButtonItem()

    // MARK: - Main Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        title = "Desert Code Camp"
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionsUpdated(notification:)), name: .sessionsUpdated, object: nil)
        
        trackTimesButton = UIBarButtonItem(title: "by Times", style: .plain, target: self, action: #selector(changeFilter))
        navigationItem.rightBarButtonItem = trackTimesButton

        loadFilters()
    }
    
    @objc func changeFilter() {
        if filter == "tracks" {
            trackTimesButton.title = "by Tracks"
            filter = "times"
        } else if filter == "times" {
            trackTimesButton.title = "by Times"
            filter = "tracks"
        }
        filters.removeAll()
        loadFilters()
    }
    
    @objc func sessionsUpdated(notification: NSNotification) {
        print("sessions updated, reloading table")
        loadFilters()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let cell = sender as? UITableViewCell {
            if let sessionsTableViewController = segue.destination as? SessionsTableViewController {
                if let cellText = cell.textLabel?.text {
                    sessionsTableViewController.filterType = filter
                    sessionsTableViewController.filter = cellText
                }
            }
        }
    }
    
    // MARK: - Core Data Fetching

    func loadFilters() {
        let request = Sessions.createFetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        request.sortDescriptors = [sort]
        self.filterPredicate = NSPredicate(format: "isApproved == true")
        request.predicate = filterPredicate

        do {
            let sessions = try container.viewContext.fetch(request)
            for session in sessions {
                if filter == "tracks" {
                    if !filters.contains(session.track) {
                        filters.append(session.track)
                    }
                } else if filter == "times" {
                    if !filters.contains(session.time) {
                        filters.append(session.time)
                    }
                }
            }
            if filter == "tracks" {
                filters.sort()
            }
            tableView.reloadData()
        } catch {
            print("Fetch failed 😭")
        }
    }
}

// MARK: - Extentions

// MARK: - TableView Methods

extension TracksTimesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filters.count < 1 {
            return 1
        } else {
            return filters.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if filters.count < 1 {
            cell.textLabel?.text = "Loading tracks, please wait..."
            cell.accessoryType = .none
            return cell
        } else {
            cell.textLabel?.text = filters[indexPath.row]
            return cell
        }
    }
}
