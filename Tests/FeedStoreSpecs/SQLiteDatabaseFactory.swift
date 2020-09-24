//
//  SQLiteDatabaseFactory.swift
//  Tests
//
//  Created by Danil Vassyakin on 9/24/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import FeedStoreChallenge
import SQLite

internal struct SQLiteDatabaseFactory {
        
    static func create(dbPath: String) -> SQLite.Connection? {
        return try? Connection(dbPath, readonly: false)
    }
    
}
