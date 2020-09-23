//
//  SQLiteFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

final class SQLiteFeedStore: FeedStore {

    func retrieve(completion: @escaping RetrievalCompletion) {
        
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
}
