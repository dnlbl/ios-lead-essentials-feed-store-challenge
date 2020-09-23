//
//  SQLiteFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

struct SQLiteFeedImage: Encodable {

    let id: String
    let description: String?
    let location: String?
    let url: String
    
    internal init(id: String, description: String?, location: String?, url: String) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
    
    init(fromLocal local: LocalFeedImage) {
        self.id = local.id.uuidString
        self.description = local.description
        self.location = local.location
        self.url = local.url.absoluteString
    }
    
    var toLocal: LocalFeedImage {
        .init(id: UUID(uuidString: id)!, description: description, location: location, url: URL(string: url)!)
    }
}

final public class SQLiteFeedStore: FeedStore {
    
    private let db: Connection
    private let feedTable = Table("feedStore")
    private let id = Expression<String>("id")
    private let description = Expression<String?>("description")
    private let location = Expression<String?>("location")
    private let url = Expression<String>("url")
    private let timestampColumn = Expression<TimeInterval>("timestamp")

    public init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = "\(documentsPath)/SQLiteFeedStore"
        self.db = try! Connection(dbPath, readonly: false)
        prepareTables()
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        var retrievedImages = [SQLiteFeedImage]()
        var timestamps = [TimeInterval]()
        for feedImage in try! db.prepare(feedTable) {
            let idValue = feedImage[id]
            let descValue = feedImage[description]
            let locationValue = feedImage[location]
            let urlValue = feedImage[url]
            let timestamp = feedImage[timestampColumn]
            timestamps.append(timestamp)
            retrievedImages.append(.init(id: idValue, description: descValue, location: locationValue, url: urlValue))
        }
        
        switch retrievedImages.count {
        case 0:
            completion(.empty)
        default:
            completion(.found(feed: retrievedImages.map { $0.toLocal }, timestamp: Date(timeIntervalSince1970: timestamps[0])))
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let sqliteFeed = feed.map(SQLiteFeedImage.init)

        sqliteFeed.forEach {
            try! db.run(feedTable.insert(
                id <- $0.id,
                description <- $0.description,
                location <- $0.location,
                url <- $0.url,
                timestampColumn <- timestamp.timeIntervalSince1970)
            )
        }
        completion(nil)
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
}

private extension SQLiteFeedStore {
    
    func prepareTables() {
        _ = try? db.run(feedTable.create(block: { table in
            table.column(id, primaryKey: true)
            table.column(description)
            table.column(location)
            table.column(url)
            table.column(timestampColumn)
        }))
    }

}