//
//  SQLiteFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

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
