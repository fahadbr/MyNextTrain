//
//  RealmConfig.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/20/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm


extension Realm {

    static func gtfs() throws -> Realm {
        let newSchemaVersion: UInt64 = 5
        return try Realm(configuration: Realm.Configuration(
            fileURL: RealmURLs.gtfsUrl,
            schemaVersion: newSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion != newSchemaVersion {
                    Logger.debug("migrating to new realm schema")
                }
            }
        ))
    }
    
}

extension RealmChangeset: ChangeSet {}

fileprivate class RealmURLs {

    static let sharedContainerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.mynexttrain")!.appendingPathComponent("realm")
    static let gtfsUrl = createDirectory(RealmURLs.sharedContainerUrl.appendingPathComponent("gtfs")).appendingPathComponent("gtfs.realm", isDirectory: false)

    static func createDirectory(_ url: URL) -> URL {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        } catch _ {
            fatalError("failed to get or create directory")
        }
    }
}
