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
    
    func testMoveDraftMovies() {
        let movies = [
            (MovieData(id:11), "image"),
            (MovieData(id: 1), "image"),
            (MovieData(id: 3), "image")
        ]
        let indexSet = IndexSet(integer: 0)
        let result = logVMSucceed.moveDraftMovies(movies: movies, from: indexSet, to: 2)
        XCTAssert(result.count > 2 && result[1].0.id == 11)
    }
    
    func testDeleteDraftMovie() {
        let movies = [
            (MovieData(id:11), "image"),
            (MovieData(id: 1), "image"),
            (MovieData(id: 3), "image")
        ]
        let indexSet = IndexSet(integer: 1)
        let result = logVMSucceed.deleteDraftMovie(movies: movies, at: indexSet)
        XCTAssert(result.count == 2)
    }
    
    func testRemoveMovieSuccess() {
        let removedMovieId = 3
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test"), (MovieData(id: removedMovieId), "test2")]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.movies = movies
        logVMSucceed.removeMovie(movieId: removedMovieId)
    }
    
    func testRemoveMovieNotFoundInMovies() {
        let removedMovieId = 3
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test")]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.movies = movies
        logVMSucceed.removeMovie(movieId: removedMovieId)
    }
    
    func testRemoveMovieNilUserId() {
        let removedMovieId = 3
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test"), (MovieData(id: removedMovieId), "test2")]
        mockFBSucceed.validUserId = false
        logVMSucceed.movies = movies
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.removeMovie(movieId: removedMovieId)
    }
    
    func testRemoveMovieNilLogId() {
        let removedMovieId = 3
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test"), (MovieData(id: removedMovieId), "test2")]
        logVMSucceed.movies = movies
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.removeMovie(movieId: removedMovieId)
    }
    
    func testRemoveMovieError() {
        let removedMovieId = 3
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test"), (MovieData(id: removedMovieId), "test2")]
        logVMError.log = LogType.log(log)
        logVMError.movies = movies
        logVMError.removeMovie(movieId: removedMovieId)
    }
    
    func testRemoveMovieLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        let removedMovieId = 3
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "3"
        log.addToMovie_ids(movieData)
        
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test"), (MovieData(id: removedMovieId), "test2")]
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.movies = movies
        logVMSucceed.removeMovie(movieId: removedMovieId)
        
        resetAllLogs()
    }
    
    func testRemoveMovieLocalNilMovieIds() {
        let context = PersistenceController.shared.container.viewContext
        let removedMovieId = 3
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test"), (MovieData(id: removedMovieId), "test2")]
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.movies = movies
        logVMSucceed.removeMovie(movieId: removedMovieId)
        
        resetAllLogs()
    }
    
    func testRemoveMovieLocalMovieNotFoundInList() {
        let context = PersistenceController.shared.container.viewContext
        let removedMovieId = 3
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        log.addToMovie_ids(movieData)
        
        let movies = [(MovieData(), "test1"), (MovieData(id: 11), "test")]
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.movies = movies
        logVMSucceed.removeMovie(movieId: removedMovieId)
        
        resetAllLogs()
    }
    
    func testIsCollaborator() {
        _ = logVMSucceed.isCollaborator()
        
        // Collaborators is nil
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: [], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        _ = logVMSucceed.isCollaborator()
        
        // Nil user id
        mockFBSucceed.validUserId = false
        _ = logVMSucceed.isCollaborator()
    }
    
    func testIsOwnerLocalLog() {
        _ = logVMSucceed.isOwner()
    }
    
    func testFetchMoviesSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.fetchMovies()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.movies.count == 3 &&
                self.logVMSucceed.watchedMovies.count == 3
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testFetchMoviesAlreadyContainsSome() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.movies = [(MovieData(id: 11), "backdrop.png")]
        logVMSucceed.watchedMovies = [(MovieData(id: 13), "backdrop.png")]
        logVMSucceed.fetchMovies()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.movies.count == 3 &&
                self.logVMSucceed.watchedMovies.count == 3
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testFetchMoviesLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        let movieData2 = LocalMovieData(context: context)
        movieData2.movie_id = "12"
        movieData2.movie_index = 1
        
        let movieData3 = LocalMovieData(context: context)
        movieData3.movie_id = "156"
        movieData3.movie_index = 2
        
        let watchedMovieData = LocalMovieData(context: context)
        movieData.movie_id = "1234"
        movieData.movie_index = 0
        
        let watchedMovieData2 = LocalMovieData(context: context)
        movieData2.movie_id = "13"
        movieData2.movie_index = 1
        
        let watchedMovieData3 = LocalMovieData(context: context)
        movieData3.movie_id = "1"
        movieData3.movie_index = 2
        
        log.addToMovie_ids(movieData)
        log.addToMovie_ids(movieData2)
        log.addToMovie_ids(movieData3)
        log.addToWatched_ids(watchedMovieData)
        log.addToWatched_ids(watchedMovieData2)
        log.addToWatched_ids(watchedMovieData3)
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.fetchMovies()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.movies.count == 3 &&
                self.logVMSucceed.watchedMovies.count == 3
            }), object: nil)
        wait(for: [expectation], timeout: 10)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsWatchedSuccess() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.movies = [(MovieData(id: movieId), "string.png")]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.markMovieAsWatched(movieId: movieId)
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.showingWatchedNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedNotFoundInMovies() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.markMovieAsWatched(movieId: movieId)
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.showingWatchedNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedNilUserId() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        mockFBSucceed.validUserId = false
        logVMSucceed.movies = [(MovieData(id: movieId), "string.png")]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.markMovieAsWatched(movieId: movieId)
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.showingWatchedNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedError() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        logVMError.movies = [(MovieData(id: movieId), "string.png")]
        logVMError.log = LogType.log(log)
        logVMError.markMovieAsWatched(movieId: movieId)
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMError.showingWatchedNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        let movieId = 11
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        log.addToMovie_ids(movieData)
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.movies = [(MovieData(id: movieId), "string.png")]
        logVMSucceed.markMovieAsWatched(movieId: movieId)
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.showingWatchedNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsWatchedLocalNotFoundInMovies() {
        let movieId = 11
        logVMSucceed.markMovieAsWatched(movieId: movieId)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsWatchedLocalNotFoundInMovieIds() {
        let movieId = 11
        logVMSucceed.movies = [(MovieData(id: movieId), "backdrop.png")]
        logVMSucceed.markMovieAsWatched(movieId: movieId)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsUnWatchedSuccess() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.watchedMovies = [(MovieData(id: movieId), "string.png")]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.markMovieAsUnwatched(movieId: movieId)
    }
    
    func testMarkMovieAsUnWatchedNotFoundInMovies() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.markMovieAsUnwatched(movieId: movieId)
    }
    
    func testMarkMovieAsUnWatchedNilUserId() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        mockFBSucceed.validUserId = false
        logVMSucceed.watchedMovies = [(MovieData(id: movieId), "string.png")]
        logVMSucceed.log = LogType.log(log)
        logVMSucceed.markMovieAsUnwatched(movieId: movieId)
    }
    
    func testMarkMovieAsUnWatchedError() {
        let movieId = 11
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMError.watchedMovies = [(MovieData(id: movieId), "string.png")]
        logVMError.log = LogType.log(log)
        logVMError.markMovieAsUnwatched(movieId: movieId)
    }
    
    func testMarkMovieAsUnWatchedLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        let movieId = 11
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        log.addToWatched_ids(movieData)
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.watchedMovies = [(MovieData(id: movieId), "string.png")]
        logVMSucceed.markMovieAsUnwatched(movieId: movieId)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsUnWatchedLocalNotFoundInWatchedMovies() {
        let movieId = 11
        logVMSucceed.markMovieAsUnwatched(movieId: movieId)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsUnWatchedLocalNotFoundInWatchedIds() {
        let movieId = 11
        logVMSucceed.watchedMovies = [(MovieData(id: movieId), "backdrop.png")]
        logVMSucceed.markMovieAsUnwatched(movieId: movieId)
        
        resetAllLogs()
    }
    
    func testLocalMovieDataMapping() {
        let context = PersistenceController.shared.container.viewContext
        
        // MovieSet is nil
        var result = logVMSucceed.localMovieDataMapping(movieSet: nil)
        XCTAssertEqual(result, [])
        
        // movies.count == 0
        result = logVMSucceed.localMovieDataMapping(movieSet: Set())
        XCTAssertEqual(result, [])
        
        // Movies Success
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        var movieSet = Set<LocalMovieData>()
        movieSet.insert(movieData)
        result = logVMSucceed.localMovieDataMapping(movieSet: movieSet)
        XCTAssertEqual(result.count, 1)
    }
    
    func testDeleteLocalLogSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        logVMSucceed.log = LogType.localLog(log)
        logVMSucceed.deleteLog()
        
        resetAllLogs()
    }
    
    func testDeleteLogSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        
        logVMSucceed.deleteLog()
    }
    
    func testDeleteLogNilUserId() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        mockFBSucceed.validUserId = false
        logVMSucceed.log = LogType.log(log)
        
        logVMSucceed.deleteLog()
    }
    
    func testDeleteLogNilLogId() {
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        
        logVMSucceed.deleteLog()
    }
    
    func testDeleteLogError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMError.log = LogType.log(log)
        
        logVMError.deleteLog()
    }
    
    func testFetchMoviePosterSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        
        logVMSucceed.fetchMoviePoster()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.posterURL != nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testFetchMoviePosterLogDoesntContainMovies() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: [], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMSucceed.log = LogType.log(log)
        
        logVMSucceed.fetchMoviePoster()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.isLoading == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testFetchMoviePosterError() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["1234", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        logVMError.log = LogType.log(log)
        
        logVMError.fetchMoviePoster()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMError.isLoading == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testFetchMoviePosterLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        log.addToMovie_ids(movieData)
        
        logVMSucceed.log = LogType.localLog(log)
        
        logVMSucceed.fetchMoviePoster()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.posterURL != nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testFetchMoviePosterLocalLogDoesntContainMovies() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        logVMSucceed.log = LogType.localLog(log)
        
        logVMSucceed.fetchMoviePoster()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logVMSucceed.isLoading == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testTruncateText() {
        let result = logVMSucceed.truncateText("1234")
        XCTAssertEqual(result, "1234")
        
        let greaterResult = logVMSucceed.truncateText("123456789012345678901")
        XCTAssertEqual(greaterResult, "12345678901234567890...")
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

