//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import SQLite

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
	
    //  ***********************
    //
    //  Follow the TDD process:
    //
    //  1. Uncomment and run one test at a time (run tests with CMD+U).
    //  2. Do the minimum to make the test pass and commit.
    //  3. Refactor if needed and commit again.
    //
    //  Repeat this process until all tests are passing.
    //
    //  ***********************

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
    private func makeSUT(withExpectingError expectingError: FeedStoreOperationError? = nil) -> FeedStore {
        let connection: SQLite.Connection = SQLiteDatabaseFactory.create(dbPath: dbPath)!
         
        let feedStore = try! SQLiteFeedStore(
            connection: SQLiteConnectionDecorator(decoratee: connection, operationError: expectingError)
        )
        
        trackForMemoryLeak(feedStore)
        return feedStore
	}
    
    private var cachesPath: String {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    
    private var dbPath: String {
        cachesPath.appending("SQLiteFeedStore.db")
    }
    
    private func setupEmptyStoreState() {
        deleteDatabaseFromDisk()
    }

    private func undoStoreSideEffects() {
        deleteDatabaseFromDisk()
    }
    
    private func deleteDatabaseFromDisk() {
        try? FileManager.default.removeItem(atPath: dbPath)
    }
    
}

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {

    func test_retrieve_deliversFailureOnRetrievalError() {
        let sut = makeSUT(withExpectingError: .read)

        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let sut = makeSUT(withExpectingError: .read)

        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }

}

extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {

    func test_insert_deliversErrorOnInsertionError() {
        let sut = makeSUT(withExpectingError: .insert)

        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let sut = makeSUT(withExpectingError: .insert)

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }

}

extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {

    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(withExpectingError: .delete)

        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let sut = makeSUT(withExpectingError: .delete)

        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }

}
