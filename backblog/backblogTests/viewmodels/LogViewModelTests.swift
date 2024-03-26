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
    
    func testGetOwnerDataLocalLog() {
        logVMSucceed.getOwnerData()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.ownerData == nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetOwnerDataSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.getOwnerData()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.ownerData?.userId == "mockUserId"
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetOwnerDataNilUserId() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: nil, movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.getOwnerData()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.ownerData == nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetOwnerDataError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMError.log = LogType.log(log)
        logVMError.getOwnerData()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMError.ownerData == nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetCollaboratorAvatarLocalLog() {
        let result = logVMSucceed.getCollaboratorAvatars()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetCollaboratorAvatarSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let ownerData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: [:], blocked: [:])
        let collaborators = [UserData(userId: "mockUserId2", username: "mockUsername2", joinDate: "now", avatarPreset: nil, friends: [:], blocked: [:]), UserData(userId: "mockUserId3", username: "mockUsername3", joinDate: "now", avatarPreset: 1, friends: [:], blocked: [:])]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.ownerData = ownerData
        logVMSucceed.collaborators = collaborators
        let result = logVMSucceed.getCollaboratorAvatars()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result.count == 3
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetCollaboratorAvatarNilUserAvatar() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        let result = logVMSucceed.getCollaboratorAvatars()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result.count == 1
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testUpdateCollaboratorsLocalLog() {
        logVMSucceed.updateCollaborators(collaborators: [])
    }
    
    func testUpdateCollaboratorsInvalidLogId() {
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.updateCollaborators(collaborators: [])
    }
    
    func testUpdateCollaboratorsSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let collaborators = [UserData(userId: "mockUserId2", username: "mockUsername2", joinDate: "now", avatarPreset: nil, friends: [:], blocked: [:]), UserData(userId: "mockUserId3", username: "mockUsername3", joinDate: "now", avatarPreset: 1, friends: [:], blocked: [:])]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.collaborators = collaborators
        logVMSucceed.updateCollaborators(collaborators: ["mockUserId4", "mockUserId3"])
    }
    
    func testUpdateCollaboratorsError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let collaborators = [UserData(userId: "mockUserId2", username: "mockUsername2", joinDate: "now", avatarPreset: nil, friends: [:], blocked: [:]), UserData(userId: "mockUserId3", username: "mockUsername3", joinDate: "now", avatarPreset: 1, friends: [:], blocked: [:])]
        logVMError.log = LogType.log(log)
        logVMError.collaborators = collaborators
        logVMError.updateCollaborators(collaborators: ["mockUserId4", "mockUserId3"])
    }
    
    func testGetCollaboratorsLocalLog() {
        logVMSucceed.getCollaborators()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.collaborators == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetCollaboratorsSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.getCollaborators()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.collaborators == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetCollaboratorsNilLogId() {
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.getCollaborators()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.collaborators == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetCollaboratorsError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMError.log = LogType.log(log)
        logVMError.getCollaborators()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMError.collaborators == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetFriendsLocalLog() {
        logVMSucceed.getFriends()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.friends == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetFriendsSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.getFriends()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.friends.count == 2
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetFriendsNilUserId() {
        mockFBSucceed.validUserId = false
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.getFriends()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.friends == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetFriendsError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMError.log = LogType.log(log)
        logVMError.getFriends()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMError.friends == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testShuffleUnwatchedMoviesSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.movies = [(MovieData(), "test")]
        logVMSucceed.shuffleUnwatchedMovies()
    }
    
    func testShuffleUnwatchedMoviesNilUserId() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        mockFBSucceed.validUserId = false
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.shuffleUnwatchedMovies()
    }
    
    func testShuffleUnwatchedMoviesNilLogId() {
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.shuffleUnwatchedMovies()
    }
    
    func testShuffleUnwatchedMoviesError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMError.log = LogType.log(log)
        logVMError.shuffleUnwatchedMovies()
    }
    
    func testShuffleUnwatchedMoviesLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        log.addToMovie_ids(movieData)
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.shuffleUnwatchedMovies()
        
        resetAllLogs()
    }
    
    func testShuffleUnwatchedMoviesLocalNilMovieIds() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.shuffleUnwatchedMovies()
        
        resetAllLogs()
    }
    
    func testSaveChangesSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test")]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.saveChanges(draftLogName: "New Log Name", movies: movies)
    }
    
    func testSaveChangesNilUserId() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        mockFBSucceed.validUserId = false
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.saveChanges(draftLogName: "New Log Name", movies: [])
    }
    
    func testSaveChangesNilLogId() {
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.saveChanges(draftLogName: "New Log Name", movies: [])
    }
    
    func testSaveChangesError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test")]
        logVMError.log = LogType.log(log)
        logVMError.saveChanges(draftLogName: "New Log Name", movies: movies)
    }
    
    func testSaveChangesLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        log.addToMovie_ids(movieData)
        
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test")]
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.saveChanges(draftLogName: "", movies: movies)
        
        resetAllLogs()
    }
    
    func testSaveChangesLocalDraftNameSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        log.addToMovie_ids(movieData)
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.saveChanges(draftLogName: "New Log Name", movies: [])
        
        resetAllLogs()
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

