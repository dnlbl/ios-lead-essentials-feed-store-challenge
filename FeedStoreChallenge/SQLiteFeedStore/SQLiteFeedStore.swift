//
//  SQLiteFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

public protocol SQLiteConnectionProtocol {
    @discardableResult func run(_ statement: String, _ bindings: Binding?...) throws -> Statement
    @discardableResult func run(_ query: Delete) throws -> Int
    @discardableResult func run(_ query: Insert) throws -> Int64
    func prepare(_ query: QueryType) throws -> AnySequence<Row>
}

extension SQLite.Connection: SQLiteConnectionProtocol {}

final public class SQLiteFeedStore: FeedStore {
    
    private let connection: SQLiteConnectionProtocol
    private let feedTable: Table
    private let workingQueue: DispatchQueue
    
    public init(connection: SQLiteConnectionProtocol) {
        self.connection = connection
        self.feedTable = Table("feed")
        self.workingQueue = DispatchQueue(
            label: "SQLiteFeedStore",
            qos: .utility, attributes: .concurrent)
        prepareTables()
    }
    
    private func prepareTables() {
        _ = try? connection.run(feedTable.create(block: SQLiteFeedImageHelper.prepareTable))
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
                try self.connection.run(self.feedTable.delete())
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
                try self.connection.run(self.feedTable.delete())
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func performRetrieve() -> RetrieveCachedFeedResult {
        do {
            var retrieved = [SQLiteFeedImage]()
            for row in try connection.prepare(self.feedTable) {
                if let sqliteFeedImage = SQLiteFeedImage(from: row) {
                    retrieved.append(sqliteFeedImage)
                }
            }
            
            guard !retrieved.isEmpty else { return .empty }
           
            let localFeed = retrieved.map { $0.toLocal }
            let timestamp = retrieved.timestamp
            return .found(feed: localFeed, timestamp: timestamp)
        } catch {
            return .failure(error)
        }
    }

    private func performInsert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let sqliteFeed = feed.compactMap {
            SQLiteFeedImage(fromLocal: $0, timestamp: timestamp)
        }
        
        do {
            try sqliteFeed.forEach {
                try connection.run(
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
    
    var timestamp: Date {
        guard !isEmpty else { return Date() }
        return self[0].timestamp
    }
    
}
