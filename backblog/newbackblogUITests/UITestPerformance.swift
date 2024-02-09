//
//  UITestPerformance.swift
//  backblog
//
//  Created by Nick Abegg on 2/9/24.
//

import XCTest

final class UITestPerformance: XCTestCase {
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch the app.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
