//
//  LogSelectionViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 4/04/24.
//

import XCTest
import CoreData
@testable import backblog

class LogSelectionViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var mockMSSuccced: MockMovieService!
    var logSelectionVMSucceed: LogSelectionViewModel!
    
    var mockFBError: MockFirebaseService!
    var mockMSError: MockMovieService!
    var logSelectionVMError: LogSelectionViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        
        mockMSSuccced = MockMovieService()
        mockMSError = MockMovieService()
        mockMSError.shouldSucceed = false
        
        let movieId = 11
        let isComingFromLog = true
        let log: LogType? = nil
        logSelectionVMSucceed = LogSelectionViewModel(selectedMovieId: movieId, fb: mockFBSucceed, movieService: mockMSSuccced)
        logSelectionVMError = LogSelectionViewModel(selectedMovieId: movieId, fb: mockFBError, movieService: mockMSError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        logSelectionVMSucceed = nil
        mockFBError = nil
        logSelectionVMError = nil
        super.tearDown()
    }
    
    func testGetLogsSuccess() {
        logSelectionVMSucceed.getLogs()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                !self.logSelectionVMSucceed.logs.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetLogsError() {
        logSelectionVMError.getLogs()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logSelectionVMError.logs.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetLocalLogsSuccess() {
        addNewLocalLog()
        
        mockFBSucceed.validUserId = false
        logSelectionVMSucceed.userId = nil
        logSelectionVMSucceed.getLogs()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                !self.logSelectionVMSucceed.logs.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
        
        resetAllLogs()
    }
    
    private func addNewLocalLog() {
        let viewContext = PersistenceController.shared.container.viewContext
        let newLog = LocalLogData(context: viewContext)
        newLog.name = "My Log"
        newLog.log_id = Int64(UUID().hashValue)
        
        let movieData = LocalMovieData(context: viewContext)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        let movieData2 = LocalMovieData(context: viewContext)
        movieData2.movie_id = "131"
        movieData2.movie_index = 1
        
        newLog.addToMovie_ids(movieData)
        newLog.addToMovie_ids(movieData2)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
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
