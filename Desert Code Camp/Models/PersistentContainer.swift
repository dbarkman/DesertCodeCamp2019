//
//  PersistentContainer.swift
//  Schedule Anything
//
//  Created by David Barkman on 8/29/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit
import CoreData

class PersistentContainer {
    
    enum CoreDataError: Error {
        case modelURLNotFound(forResourceName: String)
        case modelLoadingFailed(forURL: URL)
    }

    private static var _model: NSManagedObjectModel?
    
    public static func container(name: String) throws -> NSPersistentContainer {
        return NSPersistentContainer(name: name, managedObjectModel: try model(name: name))
    }

    private static func model(name: String) throws -> NSManagedObjectModel {
        if _model == nil {
            _model = try loadModel(name: name, bundle: Bundle.main)
        }
        return _model!
    }

    private static func loadModel(name: String, bundle: Bundle) throws -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            throw CoreDataError.modelURLNotFound(forResourceName: name)
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.modelLoadingFailed(forURL: modelURL)
       }
        return model
    }
}
