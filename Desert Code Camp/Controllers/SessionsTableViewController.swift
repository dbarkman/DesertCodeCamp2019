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
    var sessionsJson = [JSON]()
    var interestedSessionIdArray = [Int16]()
    var presentingSessionIdArray = [Int16]()
    var delegate: SessionsTableViewControllerDelegate?
    var isRootViewController = false
    var selectedView = "trackSessions"

    // MARK: - Main Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isRootViewController {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(openMenu))
        }
        navigationItem.backBarButtonItem?.title = filter
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendTweet))
        navigationItem.rightBarButtonItem = actionButton

        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
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

        title = filter
        
        navigationController?.isToolbarHidden = false
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshView))]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkView()
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

    @objc func refreshView() {
        sessionsDictionary.removeAll()
        keys.removeAll()
        tableView.reloadData()
        checkView()
    }
    
    func checkView() {
        switch selectedView {
        case "trackSessions":
            loadSessions()
        case "interestedSessions":
            loadInterestedSessions()
        case "presentingSessions":
            loadPresentingSessions()
        case "mySchedule":
            loadSessions()
        default:
            print("problems")
        }
    }
    
    func needLogin() {
        sessionsDictionary.removeAll()
        keys.removeAll()
        tableView.reloadData()
        checkAlternateViews()
    }

    @objc func openMenu() {
        delegate?.toggleLeftPanel()
    }
    
    // MARK: - Core Data Fetching

    func loadSessions() {
        sessionsDictionary.removeAll()
        keys.removeAll()
        let request = Sessions.createFetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        request.sortDescriptors = [sort]
        switch selectedView {
        case "trackSessions":
            if filterType == "tracks" {
                self.sessionPredicate = NSPredicate(format: "isApproved == true AND track == %@", filter)
            } else if filterType == "times" {
                self.sessionPredicate = NSPredicate(format: "isApproved == true AND time == %@", filter)
            }
        case "interestedSessions":
            self.sessionPredicate = NSPredicate(format: "isApproved == true AND sessionId IN %@", interestedSessionIdArray)
        case "presentingSessions":
            self.sessionPredicate = NSPredicate(format: "isApproved == true AND sessionId IN %@", presentingSessionIdArray)
        case "mySchedule":
            self.sessionPredicate = NSPredicate(format: "isApproved == true AND inMySchedule == true")
        default:
            print("problems")
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
        checkAlternateViews()
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

    func loadInterestedSessions() {
        if  UserDefaults.standard.string(forKey: "login") != nil {
            APIServices.getMyInterestedInSessionsByLogin(getMyInterestedInSessionsByLoginHandler: { json, response in
                self.sessionsJson = json.arrayValue
                for session in self.sessionsJson {
                    if let sessionId = session["SessionId"].int16 {
                        self.interestedSessionIdArray.append(sessionId)
                    }
                }
                DispatchQueue.main.async {
                    self.loadSessions()
                }
            })
        } else {
            needLogin()
        }
    }
    
    func loadPresentingSessions() {
        if  UserDefaults.standard.string(forKey: "login") != nil {
            APIServices.getMyPresentationsByLogin(getMyPresentationsByLoginHandler: { json, response in
                self.sessionsJson = json.arrayValue
                for session in self.sessionsJson {
                    if let sessionId = session["SessionId"].int16 {
                        self.presentingSessionIdArray.append(sessionId)
                    }
                }
                DispatchQueue.main.async {
                    self.loadSessions()
                }
            })
        } else {
            needLogin()
        }
    }
    
    func checkAlternateViews() {
        let aboutViewText = AboutViewText()
        var message = String()
        var showLogin = false
        switch selectedView {
        case "interestedSessions":
            if sessionsDictionary.count == 0 {
                if let _ = UserDefaults.standard.string(forKey: "login") {
                    message = aboutViewText.interestedString
                } else {
                    message = aboutViewText.interestedPreLoginString
                    showLogin = true
                }
                showAlert(message: message, showLogin: showLogin)
            }
        case "presentingSessions":
            if sessionsDictionary.count == 0 {
                if let _ = UserDefaults.standard.string(forKey: "login") {
                    if UserDefaults.standard.integer(forKey: "conferenceState") == 2 {
                        message = aboutViewText.presentingAcceptingString
                    } else {
                        message = aboutViewText.presentingNotAcceptingString
                    }
                } else {
                    message = aboutViewText.presentingPreLoginString
                    showLogin = true
                }
                showAlert(message: message, showLogin: showLogin)
            }
        case "mySchedule":
            if sessionsDictionary.count == 0 {
                message = aboutViewText.myScheduleString
                showAlert(message: message, showLogin: showLogin)
            }
        default:
            print("nothing to do")
        }
    }
    
    func showAlert(message: String, showLogin: Bool) {
        var cancelTitle = "Cancel"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        if showLogin {
            alertController.addAction(UIAlertAction(title: "Enter Username", style: .default, handler: { _ in
                self.showLoginAlert()
            }))
        }
        if !showLogin {
            cancelTitle = "OK"
        }
        alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    func showLoginAlert() {
        let alertController = UIAlertController(title: "Enter Username", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alertController] _ in
            let login = alertController.textFields![0].text
            UserDefaults.standard.set(login, forKey: "login")
            self.checkView()
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if selectedView == "mySchedule" {
            return .delete
        } else {
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let indexPaths = [indexPath]
        let title = keys[indexPath.section]
        if var tempArray = sessionsDictionary[title] {
            let session = tempArray[indexPath.row]
            session.inMySchedule = false
            tempArray.remove(at: indexPath.row)
            sessionsDictionary[title] = tempArray
            if let index = sessions.firstIndex(of: session) {
                sessions[index] = session
                self.saveContext()
            }
        }
        tableView.deleteRows(at: indexPaths, with: .fade)
        refreshView()
    }
}

extension SessionsTableViewController: ContainerViewControllerDelegate {
    func logout() {
        print("doing logout delegate stuff")
        needLogin()
    }
}
