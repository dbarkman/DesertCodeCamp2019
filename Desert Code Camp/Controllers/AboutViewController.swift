//
//  AboutViewController.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/26/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit

protocol AboutViewControllerDelegate {
    func toggleLeftPanel()
    func collapseSidePanels()
}

class AboutViewController: UIViewController {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    var delegate: AboutViewControllerDelegate?
    var content = NSAttributedString()
    var viewTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewTitle

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(openMenu))
        
        contentLabel.attributedText = content
    }
    
    @objc func openMenu() {
        delegate?.toggleLeftPanel()
    }
}
