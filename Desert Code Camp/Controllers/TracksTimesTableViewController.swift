//
//  TracksTimesTableViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit
import CoreData

protocol TracksTimesTableViewControllerDelegate {
    func toggleLeftPanel()
    func collapseSidePanels()
}

class TracksTimesTableViewController: UITableViewController {

    // MARK: - Variables
    
    var container: NSPersistentContainer!
    var filterPredicate: NSPredicate?
    var filters = [String]()
    var filterType = "tracks"
    var filterButtonTitle = "by Times"
    var filterButton = UIBarButtonItem()
    var delegate: TracksTimesTableViewControllerDelegate?
    let tracksTimesRefreshControl = UIRefreshControl()

    // MARK: - Main Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)

        do {
            try container = PersistentContainer.container(name: "DesertCodeCamp")
            container.loadPersistentStores { storeDescription, error in
//                self.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy //local storage overwrites incoming updates
                self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy //incoming updates overwrites local storage
                if let error = error {
                    print("Unresolved error \(error)")
                }
            }
        } catch {
            print("An error occured: \(error)")
        }

        title = "Desert Code Camp"
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionsUpdated(notification:)), name: .sessionsUpdated, object: nil)

        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendTweet))
        navigationItem.rightBarButtonItem = actionButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(openMenu))
                
        tableView.refreshControl = tracksTimesRefreshControl
        tracksTimesRefreshControl.addTarget(self, action: #selector(refreshTracksTimes(_:)), for: .valueChanged)
        
        filterButton = UIBarButtonItem(title: filterButtonTitle, style: .plain, target: self, action: #selector(changeFilter))
        navigationController?.isToolbarHidden = false
        toolbarItems = [filterButton]

        loadFilters()
    }
    
    @objc func sessionsUpdated(notification: NSNotification) {
        loadFilters()
    }
    
    @objc func sendTweet() {
        var share = ""
        if let hashTag = UserDefaults.standard.string(forKey: "hashTag") {
            share = hashTag
        }
        let activityViewController = UIActivityViewController(activityItems: [share], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc func openMenu() {
        delegate?.toggleLeftPanel()
    }
    
    @objc func refreshTracksTimes(_ sender: Any) {
        filters.removeAll()
        loadFilters()
        tracksTimesRefreshControl.endRefreshing()
    }

    @objc func changeFilter() {
        if filterType == "tracks" {
            filterButton.title = "by Tracks"
            filterType = "times"
        } else if filterType == "times" {
            filterButton.title = "by Times"
            filterType = "tracks"
        }
        refreshTracksTimes(self)
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
                if filterType == "tracks" {
                    if !filters.contains(session.track) {
                        filters.append(session.track)
                    }
                } else if filterType == "times" {
                    if !filters.contains(session.time) {
                        filters.append(session.time)
                    }
                }
            }
            if filterType == "tracks" {
                filters.sort()
            }
            tableView.reloadData()
        } catch {
            print("Fetch failed 😭")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let cell = sender as? UITableViewCell {
            if let sessionsTableViewController = segue.destination as? SessionsTableViewController {
                if let cellText = cell.textLabel?.text {
                    sessionsTableViewController.filterType = filterType
                    sessionsTableViewController.filter = cellText
                    sessionsTableViewController.isRootViewController = false
                }
            }
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
