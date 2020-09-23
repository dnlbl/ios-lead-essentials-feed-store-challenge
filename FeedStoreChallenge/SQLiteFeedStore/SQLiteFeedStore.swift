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
    private let feedTable: Table
    private let workingQueue: DispatchQueue
    
    public init(db: Connection) {
        self.db = db
        self.feedTable = Table("feed")
        self.workingQueue = DispatchQueue(
            label: "SQLiteFeedStore",
            qos: .utility, attributes: .concurrent)
        prepareTables()
    }
    
    private func prepareTables() {
        _ = try? db.run(feedTable.create(block: SQLiteFeedImageHelper.prepareTable))
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        workingQueue.async { [weak self] in
            guard let self = self else { return }
            completion(self.performRetrieve())
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        workingQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.db.run(self.feedTable.delete())
                self.performInsert(feed, timestamp: timestamp, completion: completion)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        workingQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.db.run(self.feedTable.delete())
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func performRetrieve() -> RetrieveCachedFeedResult {
        do {
            var retrieved = [SQLiteFeedImage]()
            for row in try self.db.prepare(self.feedTable) {
                retrieved.append(SQLiteFeedImage(from: row))
            }
            
            guard !retrieved.isEmpty else { return .empty }
           
            let localFeed = retrieved.map { $0.toLocal }
            let timestamp = Date(timeIntervalSince1970: retrieved.timestamp)
            return .found(feed: localFeed, timestamp: timestamp)
        } catch {
            return .failure(error)
        }
    }

    private func performInsert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let sqliteFeed = feed.map {
            SQLiteFeedImage(fromLocal: $0, timestamp: timestamp.timeIntervalSince1970)
        }
        
        do {
            try sqliteFeed.forEach {
                try db.run(
                    SQLiteFeedImageHelper.insert(model: $0, into: feedTable)
                )
            }
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
}

//MARK: - Helpers
private extension Array where Element == SQLiteFeedImage {
    
    var timestamp: TimeInterval {
        guard !isEmpty else { return 0 }
        return sorted(by: { $0.timestamp.value < $1.timestamp.value })[0].timestamp.value
    }
    
}
