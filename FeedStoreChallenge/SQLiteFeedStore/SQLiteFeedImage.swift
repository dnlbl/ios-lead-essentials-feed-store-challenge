//
//  SQLiteFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

internal struct SQLiteColumnWrap<T> {
    let value: T
    let column: Expression<T>
}

internal struct SQLiteFeedImage {
    
    internal let id: SQLiteColumnWrap<String>
    internal let description: SQLiteColumnWrap<String?>
    internal let location: SQLiteColumnWrap<String?>
    internal let url: SQLiteColumnWrap<String>
    internal let timestampRawData: SQLiteColumnWrap<Blob>
    internal let timestamp: Date

    internal init?(from row: Row) {
        let id = row[SQLiteFeedImage.C_ID]
        let description = row[SQLiteFeedImage.C_DESCRIPTION]
        let location = row[SQLiteFeedImage.C_LOCATION]
        let url = row[SQLiteFeedImage.C_URL]
        let timestampRawData = row[SQLiteFeedImage.C_TIMESTAMP]
        
        guard let decodedTimestamp = try? SQLiteFeedImageHelper.decode(
            timestampRawData: timestampRawData)
        else { return nil }

        self = .init(id: id, description: description, location: location, url: url, timestampRawData: timestampRawData, timestamp: decodedTimestamp)
    }
    
    internal init(id: String, description: String?, location: String?, url: String, timestampRawData: Blob, timestamp: Date) {
        self.id = SQLiteColumnWrap(value: id, column: SQLiteFeedImage.C_ID)
        self.description = SQLiteColumnWrap(value: description, column: SQLiteFeedImage.C_DESCRIPTION)
        self.location = SQLiteColumnWrap(value: location, column: SQLiteFeedImage.C_LOCATION)
        self.url = SQLiteColumnWrap(value: url, column: SQLiteFeedImage.C_URL)
        self.timestampRawData = SQLiteColumnWrap(value: timestampRawData, column: SQLiteFeedImage.C_TIMESTAMP)
        self.timestamp = timestamp
    }
    
    internal init?(fromLocal local: LocalFeedImage, timestamp: Date) {
        guard let encodedTimestamp = try? JSONEncoder().encode(timestamp) else { return nil }

        let id = local.id.uuidString
        let description = local.description
        let location = local.location
        let url = local.url.absoluteString
        
        self = .init(id: id, description: description, location: location, url: url, timestampRawData: encodedTimestamp.datatypeValue, timestamp: timestamp)
    }
    
    internal var toLocal: LocalFeedImage {
        let id = UUID(uuidString: self.id.value)!
        let description = self.description.value
        let location = self.location.value
        let url = URL(string: self.url.value)!
        
        return LocalFeedImage(id: id,
                              description: description,
                              location: location,
                              url: url)
    }
    
}

//MARK: - Columns
internal extension SQLiteFeedImage {
    
    static let C_ID = Expression<String>("id")
    static let C_DESCRIPTION = Expression<String?>("description")
    static let C_LOCATION = Expression<String?>("location")
    static let C_URL = Expression<String>("url")
    static let C_TIMESTAMP = Expression<Blob>("timestamp")

}
