//
//  SQLiteConnectionDecorator.swift
//  Tests
//
//  Created by Danil Vassyakin on 9/24/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import FeedStoreChallenge
import SQLite

internal enum FeedStoreOperationError: Error {
    case read
    case delete
    case insert
}

internal class SQLiteConnectionDecorator: SQLiteConnectionProtocol {

    private let decoratee: SQLite.Connection
    private let operationError: FeedStoreOperationError?
    
    init(decoratee: SQLite.Connection, operationError: FeedStoreOperationError? = nil) {
        self.decoratee = decoratee
        self.operationError = operationError
    }
    
    func scalar<V>(_ query: Select<V>) throws -> V where V : Value {
        try decoratee.scalar(query)
    }
    
    func run(_ statement: String, _ bindings: Binding?...) throws -> Statement {
        try decoratee.run(statement, bindings)
    }
    
    func run(_ query: Delete) throws -> Int {
        if let operationError = operationError, operationError == .delete {
            throw operationError
        }
        return try decoratee.run(query)
    }
    
    func run(_ query: Insert) throws -> Int64 {
        if let operationError = operationError, operationError == .insert {
            throw operationError
        }
        return try decoratee.run(query)
    }
    
    func prepare(_ query: QueryType) throws -> AnySequence<Row> {
        if let operationError = operationError, operationError == .read {
            throw operationError
        }
        return try decoratee.prepare(query)
    }
    
}
