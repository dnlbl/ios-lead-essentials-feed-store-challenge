//
//  SQLiteFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

final public class SQLiteFeedStore: FeedStore {
    
    private let db: Connection
    
    public init() {
        self.db = try! Connection("SQLiteFeedStore", readonly: false)
        prepareTables()
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
}

private extension SQLiteFeedStore {
    
    func prepareTables() {
        let feedTable = Table("feedStore")
        let id = Expression<String>("id")
        let description = Expression<String>("description")
        let location = Expression<String>("location")
        let url = Expression<String>("url")

        _ = try? db.run(feedTable.create(block: { table in
            table.column(id, primaryKey: true)
            table.column(description)
            table.column(location)
            table.column(url)
        }))
    }

}
