//
//  SQLiteFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

struct SQLiteColumnWrap<T> {
    let value: T
    let column: Expression<T>
}

struct SQLiteFeedImage {

    let id: SQLiteColumnWrap<String>
    let description: SQLiteColumnWrap<String?>
    let location: SQLiteColumnWrap<String?>
    let url: SQLiteColumnWrap<String>
    
    internal init(id: String, description: String?, location: String?, url: String) {
        self.id = SQLiteColumnWrap(value: id, column: .init("id"))
        self.description = SQLiteColumnWrap(value: description, column: .init("description"))
        self.location = SQLiteColumnWrap(value: location, column: .init("location"))
        self.url = SQLiteColumnWrap(value: url, column: .init("url"))
    }
    
    init(fromLocal local: LocalFeedImage) {
        let id = local.id.uuidString
        let description = local.description
        let location = local.location
        let url = local.url.absoluteString
        
        self = .init(id: id, description: description, location: location, url: url)
    }
    
    var toLocal: LocalFeedImage {
        let id = UUID(uuidString: self.id.value)!
        let description = self.description.value
        let location = self.location.value
        let url =  URL(string: self.url.value)!
        
        return LocalFeedImage(id: id,
                              description: description,
                              location: location,
                              url: url)
    }
    
}
