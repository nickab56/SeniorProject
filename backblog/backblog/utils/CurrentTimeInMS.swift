//
//  CurrentTimeInMS.swift
//  backblog
//
//  Created by Jake Buhite on 1/28/24.
//

import Foundation

func currentTimeInMS() -> Int {
    return Int(Date().timeIntervalSince1970 * 1000)
}
