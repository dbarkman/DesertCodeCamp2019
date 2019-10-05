/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

protocol ContainerViewControllerDelegate {
    func logout()
}

class ContainerViewController: UIViewController {
    
    enum SlideOutState {
        case bothCollapsed
        case leftPanelExpanded
    }
    
    var centerNavigationController: UINavigationController!
    var tracksTimesTableViewController: TracksTimesTableViewController!
    var sessionsTableViewController: SessionsTableViewController!
    var aboutViewController: AboutViewController!
    var delegate: ContainerViewControllerDelegate?

    var currentState: SlideOutState = .bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .bothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: SidePanelViewController?
    
    let centerPanelExpandedOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tracksTimesTableViewController = UIStoryboard.tracksTimesTableViewController()
        tracksTimesTableViewController.delegate = self
        
        centerNavigationController = UINavigationController(rootViewController: tracksTimesTableViewController)
        view.addSubview(centerNavigationController.view)
        addChild(centerNavigationController)
        
        centerNavigationController.didMove(toParent: self)
        centerNavigationController.navigationBar.prefersLargeTitles = true
    }
}

private extension UIStoryboard {
    static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    static func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
    }
    
    static func tracksTimesTableViewController() -> TracksTimesTableViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "tracksTimes") as? TracksTimesTableViewController
    }
    
    static func sessionsTableViewController() -> SessionsTableViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "sessions") as? SessionsTableViewController
    }
    
    static func aboutViewController() -> AboutViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "about") as? AboutViewController
    }
}

// MARK: CenterViewController delegate

extension ContainerViewController: TracksTimesTableViewControllerDelegate, SessionsTableViewControllerDelegate, AboutViewControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        guard leftViewController == nil else { return }
        
        if let vc = UIStoryboard.leftViewController() {
            addChildSidePanelController(vc)
            leftViewController = vc
        }
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .bothCollapsed
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil
            }
        }
    }
    
    func collapseSidePanels() {
        switch currentState {
        case .leftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        sidePanelController.delegate = self
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

extension ContainerViewController: SidePanelViewControllerDelegate {
    func didSelectOption(_ option: String, _ row: Int) {
        collapseSidePanels()
        let aboutViewsText = AboutViewText()
        switch row {
        case 1:
            tracksTimesTableViewController = UIStoryboard.tracksTimesTableViewController()
            tracksTimesTableViewController.delegate = self
            centerNavigationController.setViewControllers([tracksTimesTableViewController], animated: false)
        case 2:
            tracksTimesTableViewController = UIStoryboard.tracksTimesTableViewController()
            tracksTimesTableViewController.delegate = self
            centerNavigationController.setViewControllers([tracksTimesTableViewController], animated: false)
        case 3:
            tracksTimesTableViewController = UIStoryboard.tracksTimesTableViewController()
            tracksTimesTableViewController.delegate = self
            tracksTimesTableViewController.filterType = "times"
            tracksTimesTableViewController.filterButtonTitle = "by Tracks"
            centerNavigationController.setViewControllers([tracksTimesTableViewController], animated: false)
        case 4:
            sessionsTableViewController = UIStoryboard.sessionsTableViewController()
            sessionsTableViewController.isRootViewController = true
            sessionsTableViewController.delegate = self
            delegate = sessionsTableViewController
            sessionsTableViewController.filterType = "tracks"
            sessionsTableViewController.selectedView = "interestedSessions"
            sessionsTableViewController.filter = "I Want to Attend"
            centerNavigationController.setViewControllers([sessionsTableViewController], animated: false)
        case 5:
            sessionsTableViewController = UIStoryboard.sessionsTableViewController()
            sessionsTableViewController.isRootViewController = true
            sessionsTableViewController.delegate = self
            delegate = sessionsTableViewController
            sessionsTableViewController.filterType = "tracks"
            sessionsTableViewController.selectedView = "presentingSessions"
            sessionsTableViewController.filter = "I'm Presenting"
            centerNavigationController.setViewControllers([sessionsTableViewController], animated: false)
        case 6:
            sessionsTableViewController = UIStoryboard.sessionsTableViewController()
            sessionsTableViewController.isRootViewController = true
            sessionsTableViewController.delegate = self
            sessionsTableViewController.filterType = "tracks"
            sessionsTableViewController.selectedView = "mySchedule"
            sessionsTableViewController.filter = "My Schedule"
            centerNavigationController.setViewControllers([sessionsTableViewController], animated: false)
        case 7:
            aboutViewController = UIStoryboard.aboutViewController()
            aboutViewController.delegate = self
            aboutViewController.viewTitle = option
            aboutViewController.content = aboutViewsText.whenWhereAttributedString
            centerNavigationController.setViewControllers([aboutViewController], animated: false)
        case 8:
            aboutViewController = UIStoryboard.aboutViewController()
            aboutViewController.delegate = self
            aboutViewController.viewTitle = option
            aboutViewController.content = aboutViewsText.codeOfConductAttributedString
            centerNavigationController.setViewControllers([aboutViewController], animated: false)
        case 9:
            aboutViewController = UIStoryboard.aboutViewController()
            aboutViewController.delegate = self
            aboutViewController.viewTitle = option
            aboutViewController.content = aboutViewsText.aboutAttributedString
            centerNavigationController.setViewControllers([aboutViewController], animated: false)
        case 10:
            aboutViewController = UIStoryboard.aboutViewController()
            aboutViewController.delegate = self
            aboutViewController.viewTitle = option
            aboutViewController.content = aboutViewsText.creditsAttributedString
            centerNavigationController.setViewControllers([aboutViewController], animated: false)
        case 11:
            if  UserDefaults.standard.string(forKey: "login") != nil { //login is populated
                UserDefaults.standard.set(nil, forKey: "login")
                let alertController = UIAlertController(title: "Logout", message: "Your DesertCodeCamp.com login has been removed.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.delegate?.logout()
                }))
                present(alertController, animated: true)
            } else {
                showLoginAlert()
            }
        default:
            print("problems")
        }
    }

    func showLoginAlert() {
        let alertController = UIAlertController(title: "Enter Username", message: "This Username is used to request sessions from the API you've marked as \"I want to attend\" or you are presenting. A username is not necessary for just browsing the sessions or setting up a schedule in the \"My Schedule\" screen.", preferredStyle: .alert)
        alertController.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alertController] _ in
            let login = alertController.textFields![0].text
            UserDefaults.standard.set(login, forKey: "login")
        }
        alertController.addAction(submitAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
}
