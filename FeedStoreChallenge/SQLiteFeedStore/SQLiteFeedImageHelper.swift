//
//  SQLiteFeedImageHelper.swift
//  FeedStoreChallenge
//
//  Created by Danil Vassyakin on 9/23/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import SQLite

internal struct SQLiteFeedImageHelper {
  
    internal static func insert(model: SQLiteFeedImage, into table: Table) -> Insert {
        table.insert(
            model.id.column <- model.id.value,
            model.description.column <- model.description.value,
            model.location.column <- model.location.value,
            model.url.column <- model.url.value,
            model.timestamp.column <- model.timestamp.value
        )
    }
    
    internal static var prepareTable: (TableBuilder) -> Void {
        let block: (TableBuilder) -> Void = { table in
            table.column(SQLiteFeedImage.C_ID, primaryKey: true)
            table.column(SQLiteFeedImage.C_DESCRIPTION)
            table.column(SQLiteFeedImage.C_LOCATION)
            table.column(SQLiteFeedImage.C_URL)
            table.column(SQLiteFeedImage.C_TIMESTAMP)
        }
        return block
    }
    
}