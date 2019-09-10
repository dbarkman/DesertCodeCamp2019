//
//  TracksTimesTableViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit

class TracksTimesTableViewController: UITableViewController {

    var tracks = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        APIServices.getSessionsByConferenceId(getSessionsHandler: { json, response in
            print("response code: \(response.statusCode)")
            print("session count: \(json.arrayValue.count)")
            
            let sessionArray = json.arrayValue
            for session in sessionArray {
                let track = session["Track"]["Name"].stringValue
                if !self.tracks.contains(track) {
                    self.tracks.append(track)
                }
            }
            self.tracks.sort()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tracks[indexPath.row]
        return cell
    }
}
