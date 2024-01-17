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
    // Initializes a Color using a hexadecimal color code.
    //
    // Parameters:
    //  - hex: A String representing a hexadecimal color code.
    //         Example format: "#FFFFFF" for white.
    //
    // The initializer parses the hex string, extracts the red, green, and blue
    // components, and then creates a Color instance with these RGB values.
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // Optional '#' character handling.

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue) // Parse the hex string into an integer value.

        // Extract the red, green, and blue components from the hex value.
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000ff) / 255.0

        // Initialize the Color with the extracted RGB values.
        self.init(red: r, green: g, blue: b)
    }
}
