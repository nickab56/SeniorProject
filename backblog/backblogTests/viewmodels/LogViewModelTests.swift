//
//  LogViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/25/24.
//

import XCTest
@testable import backblog
import CoreData

class LogViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var mockMSSuccced: MockMovieService!
    var logVMSucceed: LogViewModel!
    
    var mockFBError: MockFirebaseService!
    var mockMSError: MockMovieService!
    var logVMError: LogViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        
        mockMSSuccced = MockMovieService()
        mockMSError = MockMovieService()
        mockMSError.shouldSucceed = false
        
        // Default log
        let localLogData = LocalLogData(context: PersistenceController.shared.container.viewContext)
        let log = LogType.localLog(localLogData)
        
        logVMSucceed = LogViewModel(log: log, fb: mockFBSucceed, movieService: mockMSSuccced)
        logVMError = LogViewModel(log: log, fb: mockFBError, movieService: mockMSError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        logVMSucceed = nil
        mockMSSuccced = nil
        mockFBError = nil
        logVMError = nil
        mockMSError = nil
        super.tearDown()
    }
    
    func testCanSwipeToMarkWatchedUnwatched() {
        // Local
        let result = logVMSucceed.canSwipeToMarkWatchedUnwatched()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
        
        // Firebase Log (is not owner)
        let u = "mockUserId"
        var logData = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: nil, movieIds: [], watchedIds: [], collaborators: [u], order: [:])
        logVMSucceed.log = LogType.log(logData)
        let result2 = logVMSucceed.canSwipeToMarkWatchedUnwatched()
        let expectation2 = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result2 == true
            }), object: nil)
        wait(for: [expectation2], timeout: 5)
        
        // Firebase Log (is not collaborator)
        let o = Owner(userId: "mockUserId", priority: 1)
        logData = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: o, movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(logData)
        let result3 = logVMSucceed.canSwipeToMarkWatchedUnwatched()
        let expectation3 = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result3 == true
            }), object: nil)
        wait(for: [expectation3], timeout: 5)
        
        // Firebase Log (is neither)
        logData = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: nil, movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(logData)
        let result4 = logVMSucceed.canSwipeToMarkWatchedUnwatched()
        let expectation4 = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result4 == false
            }), object: nil)
        wait(for: [expectation4], timeout: 5)
    }
    
    private func resetAllLogs() {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
    }
    
}

