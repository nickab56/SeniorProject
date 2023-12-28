//
//  CustomTitleView.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//
//  Description:
//  CustomTitleView is a reusable SwiftUI view component designed to display
//  a title in a stylized format. It can be used across different parts of the
//  BackBlog app where a consistent title appearance is required.

import SwiftUI

// A custom view for displaying titles.
struct CustomTitleView: View {
    // The title text to be displayed.
    var title: String

    // The body of the CustomTitleView.
    var body: some View {
        Text(title)
            .font(.largeTitle) // Uses a large title font style.
            .foregroundColor(.white) // Sets the text color to white.
            .padding() // Adds padding around the text.
            .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the leading edge.
            .background(Color.clear) // Sets a transparent background.
    }
}
