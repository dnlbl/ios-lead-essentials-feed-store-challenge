//
//  SQLiteDatabaseFactory.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

public struct SQLiteDatabaseFactory {
    
    private static let dbFolderName = "SQLiteFeedStore"
    
    public static func create() -> Connection? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbPath = "\(documentsPath)/\(dbFolderName)"
        return try? Connection(dbPath, readonly: false)
    }
    
}
