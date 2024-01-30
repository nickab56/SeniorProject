//
//  ExtensionUtility.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//
//  Description:
//  ExtensionUtility contains extensions to existing Swift and SwiftUI types
//  to enhance functionality. This file specifically includes an extension
//  for the SwiftUI Color structure, enabling initialization with hexadecimal color values.

import SwiftUI
// Extension to the SwiftUI Color structure.
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000ff) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
