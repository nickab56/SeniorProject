//
//  LogRepositoryTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class LogRepositoryTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var logRepoSucceed: LogRepository!
    
    var mockFBError: MockFirebaseService!
    var logRepoError: LogRepository!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        logRepoSucceed = LogRepository(fb: mockFBSucceed)
        
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        logRepoError = LogRepository(fb: mockFBError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        logRepoSucceed = nil
        mockFBError = nil
        logRepoSucceed = nil
        super.tearDown()
    }
    
    func testAddLogSuccess() async {
        let logName = "MyLog123"
        let isVisible = true
        let ownerId = "mockUserId"
        
        do {
            let result = try await logRepoSucceed.addLog(name: logName, isVisible: isVisible, ownerId: ownerId).get()
            
            XCTAssert(result == "MockDocumentID")
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testAddLogThrowsError() async {
        let logName = "MyLog123"
        let isVisible = true
        let ownerId = "mockUserId"
        
        do {
            _ = try await logRepoError.addLog(name: logName, isVisible: isVisible, ownerId: ownerId).get()
            
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetLogSuccess() async {
        let ownerData = Owner(userId: "mockUserId", priority: 0)
        let logData = LogData(logId: "log123", name: "My Log", creationDate: "old", lastModifiedDate: "now", isVisible: true, owner: ownerData, movieIds: [], watchedIds: [],
                              collaborators: [], order: [:])
        
        do {
            let result = try await logRepoSucceed.getLog(logId: logData.logId ?? "").get()
            
            XCTAssertEqual(result.logId, logData.logId)
            XCTAssertEqual(result.name, logData.name)
            XCTAssertEqual(result.creationDate, logData.creationDate)
            XCTAssertEqual(result.lastModifiedDate, logData.lastModifiedDate)
            XCTAssertEqual(result.isVisible, logData.isVisible)
            XCTAssertEqual(result.owner, logData.owner)
            XCTAssertEqual(result.movieIds, logData.movieIds)
            XCTAssertEqual(result.watchedIds, logData.watchedIds)
            XCTAssertEqual(result.collaborators, logData.collaborators)
            XCTAssertEqual(result.order, logData.order)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetLogThrowsError() async {
        let ownerData = Owner(userId: "mockUserId", priority: 0)
        let logData = LogData(logId: "log123", name: "My Log", creationDate: "old", lastModifiedDate: "now", isVisible: true, owner: ownerData, movieIds: [], watchedIds: [],
                              collaborators: [], order: [:])
        
        do {
            _ = try await logRepoError.getLog(logId: logData.logId ?? "").get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetLogsWithPrivateSuccess() async {
        let userId = "mockUserId"
        let showPrivate = true
        
        do {
            let result = try await logRepoSucceed.getLogs(userId: userId, showPrivate: showPrivate).get()
            
            XCTAssert(result.count == 4)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetLogsOnlyPublicSuccess() async {
        let userId = "mockUserId"
        let showPrivate = false
        
        do {
            let result = try await logRepoSucceed.getLogs(userId: userId, showPrivate: showPrivate).get()
            
            XCTAssert(result.count == 4)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetLogsThrowsError() async {
        let userId = "mockUserId"
        let showPrivate = false
        
        do {
            _ = try await logRepoError.getLogs(userId: userId, showPrivate: showPrivate).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateLogSuccess() async {
        let updateData: [String: Any] = ["name": "My Log"]
        let logId = "mockLogId"
        
        do {
            let result = try await logRepoSucceed.updateLog(logId: logId, updateData: updateData).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateLogThrowsError() async {
        let updateData: [String: Any] = ["name": "My Log"]
        let logId = "mockLogId"
        
        do {
            _ = try await logRepoError.updateLog(logId: logId, updateData: updateData).get()
            
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testDeleteLogSuccess() async {
        let logId = "mockLogId"
        
        do {
            let result = try await logRepoSucceed.deleteLog(logId: logId).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testDeleteLogThrowsError() async {
        let logId = "mockLogId"
        
        do {
            _ = try await logRepoError.deleteLog(logId: logId).get()
            
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateUserLogOrderSuccess() async {
        let userId = "mockUserId"
        let logIds = [("mockLogId", true), ("mockLogId2", false)]
        
        do {
            let result = try await logRepoSucceed.updateUserLogOrder(userId: userId, logIds: logIds).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateUserLogOrderThrowsError() async {
        let userId = "mockUserId"
        let logIds = [("mockLogId", true), ("mockLogId2", false)]
        
        do {
            _ = try await logRepoError.updateUserLogOrder(userId: userId, logIds: logIds).get()
            
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testAddCollaboratorsSuccess() async {
        let logId = "mockLogId"
        let collaborators = ["mockUserId", "nickabegg", "joshaltmeyer"]
        
        do {
            let result = try await logRepoSucceed.addCollaborators(logId: logId, collaborators: collaborators).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testAddCollaboratorsThrowsError() async {
        let logId = "mockLogId"
        let collaborators = ["mockUserId", "nickabegg", "joshaltmeyer"]
        
        do {
            _ = try await logRepoError.addCollaborators(logId: logId, collaborators: collaborators).get()
            
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testRemoveCollaboratorsSuccess() async {
        let logId = "mockLogId"
        let collaborators = ["mockUserId", "nickabegg", "joshaltmeyer"]
        
        do {
            let result = try await logRepoSucceed.removeCollaborators(logId: logId, collaborators: collaborators).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testRemoveCollaboratorsThrowsError() async {
        let logId = "mockLogId"
        let collaborators = ["mockUserId", "nickabegg", "joshaltmeyer"]
        
        do {
            _ = try await logRepoError.removeCollaborators(logId: logId, collaborators: collaborators).get()
            
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
}
