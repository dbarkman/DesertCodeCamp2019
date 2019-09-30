//
//  WhenAndWhereViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/26/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit

protocol WhenAndWhereViewControllerDelegate {
    func toggleLeftPanel()
    func collapseSidePanels()
}

class WhenAndWhereViewController: UIViewController {
    
    var delegate: WhenAndWhereViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "When and Where"

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(openMenu))
    }
    
    @objc func openMenu() {
        delegate?.toggleLeftPanel()
    }
}
