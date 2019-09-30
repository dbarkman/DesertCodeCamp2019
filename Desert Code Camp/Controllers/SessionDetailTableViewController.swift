//
//  SessionDetailTableViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/22/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SessionDetailTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    var container: NSPersistentContainer!
    var sessionPredicate: NSPredicate?
    var sessionName = String()
    var sessionId = Int16()
    var session = Sessions()
    var sessions = [Sessions]()
    var presenters = [Presenters]()
    var presenterArray = [String]()
    var presentersEmail = String()
    var sessionAbstract = NSMutableAttributedString()
    var cellFontSize = CGFloat()

    // MARK: - Main Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sessionAction))
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell"), let label = cell.textLabel {
            print("name font size: \(label.font.pointSize)")
            cellFontSize = label.font.pointSize
        }

        loadSession()
        loadPresenters()
    }
    
    @objc func sessionAction() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Add to My Schedule", style: .default, handler: { _ in
            print("add to my schedule tapped")
            self.session.inMySchedule = true
            self.sessions[0] = self.session
            self.saveContext()
        }))
        alertController.addAction(UIAlertAction(title: "Post on Twitter", style: .default, handler: { _ in
            print("tweet tapped")
            let message = "In session: " + self.session.name + " by " + self.presenters[0].name + " (" + self.presenters[0].twitterHandle + ") at "
            self.sendTweet(message: message)
        }))
        alertController.addAction(UIAlertAction(title: "Email Presenter", style: .default, handler: { _ in
            print("email presenter tapped")
            self.sendEmail(email: self.presentersEmail)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("cancel tapped")
        }))
        self.present(alertController, animated: true)
    }
    
    func sendTweet(message: String) {
        if let hashTag = UserDefaults.standard.string(forKey: "hashTag") {
            let share = [message + hashTag]
            let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Core Data Fetching

    func loadSession() {
        let request = Sessions.createFetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        request.sortDescriptors = [sort]
        self.sessionPredicate = NSPredicate(format: "sessionId = %i", sessionId)
        request.predicate = sessionPredicate

        do {
            sessions = try container.viewContext.fetch(request)
            session = sessions[0]
            cleanSessionAbstract(abstract: session.abstract)
            print("session: \(sessions[0].name)")
            tableView.reloadData()
        } catch {
            print("Fetch failed 😭")
        }
    }
    
    func cleanSessionAbstract(abstract: String) {
        let font = UIFont.systemFont(ofSize: cellFontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .kern: 0]
        let sessionAbstractData = Data(abstract.utf8)
        if let attributedString = try? NSAttributedString(data: sessionAbstractData, options: [.documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            sessionAbstract.append(attributedString)
            sessionAbstract.addAttributes(attributes, range: NSRange(location: 0, length: sessionAbstract.length))
            print("abstract: \(sessionAbstract)")
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
            presentersEmail = presenters[0].email
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
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
}

// MARK: - Extentions

// MARK: - Send Email

extension SessionDetailTableViewController: MFMailComposeViewControllerDelegate {
    func sendEmail(email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            present(mail, animated: true)
        } else {
            print("can't send email")
            let alertController = UIAlertController(title: "No Email", message: "You do not have an email account setup on this device. Please configure one in order to send an email.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

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
                    print("name font size: \(label.font.pointSize)")
                case 1:
                    if sessionAbstract.length > 0 {
                        label.attributedText = sessionAbstract
                    } else {
                        label.text = session.abstract
                    }
                default:
                    label.text = ""
                }
            case 1:
                cell.selectionStyle = .default
                if indexPath.row == 2 || indexPath.row % 3 == 2 {
                    cell.accessoryType = .disclosureIndicator
                }
                if indexPath.row == 1 || indexPath.row % 3 == 1 {
                    cell.accessoryType = .disclosureIndicator
                }
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
        if indexPath.section == 1 {
            let row = indexPath.row
            if row == 2 || row % 3 == 2 {
                sendTweet(message: presenterArray[indexPath.row] + "  ")
            }
            if row == 1 || row % 3 == 1 {
                sendEmail(email: presenterArray[indexPath.row])
            }
        }
        if let indexPathSelected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathSelected, animated: true)
        }
    }
}
