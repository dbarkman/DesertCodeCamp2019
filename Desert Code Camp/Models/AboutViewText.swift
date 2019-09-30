//
//  AboutViewText.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/27/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit

class AboutViewText {
    
    var interestedPreLoginString = String()
    var interestedString = String()
    var presentingPreLoginString = String()
    var presentingAcceptingString = String()
    var presentingNotAcceptingString = String()
    var myScheduleString = String()
    var aboutAttributedString = NSMutableAttributedString()
    var whenWhereAttributedString = NSMutableAttributedString()
    var codeOfConductAttributedString = NSMutableAttributedString()
    var creditsAttributedString = NSMutableAttributedString()
    
    init() {
        var font = UIFont.systemFont(ofSize: 18)
        let font18 = [NSAttributedString.Key.font: font]
        font = UIFont.systemFont(ofSize: 14)
        let font14 = [NSAttributedString.Key.font: font]
        let dynamicBodyFont = UIFont.preferredFont(forTextStyle: .body)
        let attributes: [NSAttributedString.Key: Any] = [.font: dynamicBodyFont]

        //Interested Sessions View
        interestedPreLoginString =
            "This screen will display sessions you've marked as Interested on the DesertCodeCamp.com website. In order to view those sessions, tap the \"Enter Username\" button below and enter your DesertCodeCamp.com username on the popup screen."
        interestedString =
            "This screen will display sessions you've marked as Interested on the DesertCodeCamp.com website. In order to mark sessions as Interested,  log in to your account, or create a new account, at DesertCodeCamp.com. When viewing the list of sessions, click the \"More Info\" button, review the session, and if interested, set \"I want to attend this\" to \"Yes\" and click \"Save\". Once you've marked some sessions as Interested, return here and tap the Refresh button."

        //Presenting Sessions View
        presentingPreLoginString =
            "This screen will display sessions you've volunteered to present. In order to view those sessions, tap the \"Enter Username\" button below and enter your DesertCodeCamp.com username on the popup screen."
        presentingAcceptingString =
            "This screen will display sessions you've volunteered to present. In order to volunteer to present a session, log in to your account, or create a new account, at DesertCodeCamp.com. When viewing the list of sessions, fill out the form at the top of the page, with all the details for your suggested session. A Desert Code Camp coordinator will then contact you."
        presentingNotAcceptingString =
            "This screen will display sessions you've volunteered to present. The upcoming conference is no longer accepting new sessions, but some sessions still need presenters. In order to volunteer to present a session, log in to your account, or create a new account, at DesertCodeCamp.com. When viewing the list of sessions, look for sessions marked with the \"Needs a Presenter\" icon. Click the \"More Info\" button, review the session, and if interested, set \"I want to teach this\" to \"Yes\" and click \"Save\". A Desert Code Camp coordinator will then contact you."

        //My Schedule View
        myScheduleString =
            "This screen is used to manage your schedule for sessions you might want to attend at Desert Code Camp. To add sessions to your schedule, go to one of the All Sessions or Interested Sessions screen and navigate into the details of a session.  Once in the session details, tap the Action button in the top right and tap the \"Add to My Schedule\" popup button. Then return to this screen to view your selected sessions by time."

        //About View
        let title1 = "What is Desert Code Camp?"
        let protocols =
            "\n\n" +
            "The answer is actually simple. In order to use the official Technology Conference name we follow these simple protocols:\n" +
            "\n" +
            "By and For the Developer Community\n" +
            "Code Conferences are about the developer community at large. They are meant to be a place for developers to come and learn from their peers. Topics are always based on community interest and never determined by anyone other than the community.\n" +
            "\n" +
            "Free\n" +
            "Desert Code Camps are free for attendees.\n" +
            "\n" +
            "Community Developed Material\n" +
            "The success of the Code Conferences is that they are based on community content. All content that is delivered is original. All presentation content must be provided completely (including code) without any restriction. If you have content you don't want to share or provide to attendees then the Technology Conference is not the place for you.\n" +
            "\n" +
            "No Fluff: Only Code\n" +
            "Code Conferences are about showing the code. Refer to rule #1 if you have any questions on this.\n" +
            "\n" +
            "Community Ownership\n" +
            "The most important element of the Technology Conference is always the developer community. All are welcome to attend and speak and do so without expectation of payment or any other compensation other than their participation in the community.\n" +
            "\n" +
            "Never occur during work hours\n" +
            "We need to understand that many times people can't leave work for a day or two to attend training or even seminars. The beauty of the Technology Conference is that they always occur on weekends.\n" +
            "\n"
            let title2 = "Creator: Joseph Guadagno"
            let aboutJoseph =
            "\n\n" +
            "For 20 years or so I have been in Software Development. During that time I have used many tools, languages, and technologies. I started out programming with a small book on QuickBASIC. I later moved on to Visual Basic for DOS. Windows then came along and I starting using Visual Basic for Windows, I then migrated to Visual Basic .NET and eventually ended up using Visual C#. I work as a Team Leader at Quicken Loans, based in Detroit, MI. I am a public speaker and present internationally on a lot of different technology topics, a list of them are available at https://www.josephguadagno.net/presentations/.  I have been recognized as a Microsoft MVP in .NET (since 2009) and a Friends of Red Gate program(since 2015).\n"
        aboutAttributedString = NSMutableAttributedString(string: title1, attributes: font18)
        aboutAttributedString.append(NSMutableAttributedString(string: protocols, attributes: font14))
        aboutAttributedString.append(NSMutableAttributedString(string: title2, attributes: font18))
        aboutAttributedString.append(NSMutableAttributedString(string: aboutJoseph, attributes: font14))
        aboutAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: aboutAttributedString.length))
        
        //When and Where View
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        var dateStart = Date()
        var dateEnd = Date()
        if let dateStartString = UserDefaults.standard.string(forKey: "dateStart"), let dateEndString = UserDefaults.standard.string(forKey: "dateEnd"), let dateStartDate = formatter.date(from: dateStartString), let dateEndDate = formatter.date(from: dateEndString) {
            dateStart = dateStartDate
            dateEnd = dateEndDate
        }
        formatter.dateFormat = "EEEE MMMM dd, yyyy"
        let conferenceDate = formatter.string(from: dateStart)
        formatter.dateFormat = "h:mm a"
        let conferenceStartTime = formatter.string(from: dateStart)
        let conferenceEndTime = formatter.string(from: dateEnd)
        let whenTitle = "When"
        let whenContent =
            "\n" +
            conferenceDate + "\n" +
            conferenceStartTime + " - " + conferenceEndTime + "\n\n"
        let whereTitle = "Where"
        var whereContent = "\n"
        if let locationName = UserDefaults.standard.string(forKey: "locationName"), let address1 = UserDefaults.standard.string(forKey: "address1"), let address2 = UserDefaults.standard.string(forKey: "address2"), let city = UserDefaults.standard.string(forKey: "city"), let state = UserDefaults.standard.string(forKey: "state"), let zip = UserDefaults.standard.string(forKey: "zip") {
            whereContent +=
                locationName + "\n" +
                address1 + "\n"
            if address2.count > 0 {
                whereContent += address2 + "\n"
            }
            whereContent += city + ", " + state + " " + zip
        }
        whenWhereAttributedString = NSMutableAttributedString(string: whenTitle, attributes: font18)
        whenWhereAttributedString.append(NSMutableAttributedString(string: whenContent, attributes: font14))
        whenWhereAttributedString.append(NSMutableAttributedString(string: whereTitle, attributes: font18))
        whenWhereAttributedString.append(NSMutableAttributedString(string: whereContent, attributes: font14))
        whenWhereAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: whenWhereAttributedString.length))
        
        //Code of Conduct view
        let codeOfConductContent =
            "<p>All attendees, speakers, sponsors and volunteers at our conference are required to agree with the following code of conduct. Organisers will enforce this code throughout the event. We expect cooperation from all participants to help ensure a safe environment for everybody.</p> <h2>Need Help?</h2> <p>You have our contact details in the emails we've sent.</p> <h2>The Quick Version</h2> <p>Our conference is dedicated to providing a harassment-free conference experience for everyone, regardless of gender, gender identity and expression, age, sexual orientation, disability, physical appearance, body size, race, ethnicity, religion (or lack thereof), or technology choices. We do not tolerate harassment of conference participants in any form. Sexual language and imagery is not appropriate for any conference venue, including talks, workshops, parties, Twitter and other online media. Conference participants violating these rules may be sanctioned or expelled from the conference <em>without a refund</em> at the discretion of the conference organisers.</p> <h2>The Less Quick Version</h2> <p>Harassment includes offensive verbal comments related to gender, gender identity and expression, age, sexual orientation, disability, physical appearance, body size, race, ethnicity, religion, technology choices, sexual images in public spaces, deliberate intimidation, stalking, following, harassing photography or recording, sustained disruption of talks or other events, inappropriate physical contact, and unwelcome sexual attention.</p> <p>Participants asked to stop any harassing behavior are expected to comply immediately.</p> <p>Sponsors are also subject to the anti-harassment policy. In particular, sponsors should not use sexualised images, activities, or other material. Booth staff (including volunteers) should not use sexualised clothing/uniforms/costumes, or otherwise create a sexualised environment.</p> <p>If a participant engages in harassing behavior, the conference organisers may take any action they deem appropriate, including warning the offender or expulsion from the conference with no refund.</p> <p>If you are being harassed, notice that someone else is being harassed, or have any other concerns, please contact a member of conference staff immediately. Conference staff can be identified as they'll be wearing branded t-shirts.</p> <p>Conference staff will be happy to help participants contact hotel/venue security or local law enforcement, provide escorts, or otherwise assist those experiencing harassment to feel safe for the duration of the conference. We value your attendance.</p> <p>We expect participants to follow these rules at conference and workshop venues and conference-related social events.</p>"
        let codeOfConductData = Data(codeOfConductContent.utf8)
        if let attributedString = try? NSAttributedString(data: codeOfConductData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            codeOfConductAttributedString.append(attributedString)
            codeOfConductAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: codeOfConductAttributedString.length))
        }
        
        let creditsContent =
            "<p>App Developed by:</p> <p>David Barkman @ Dbarkman LLC</p> <p>dbarkman.com @cybler</p><br><p>App QA by:</p> <p>Maritza Lomba</p>"
        let creditsData = Data(creditsContent.utf8)
        if let attributedString = try? NSAttributedString(data: creditsData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            creditsAttributedString.append(attributedString)
            creditsAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: creditsAttributedString.length))
        }
    }
}
