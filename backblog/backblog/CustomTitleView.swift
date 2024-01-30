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
    var title: String

    var body: some View {
        Text(title)
            .font(.largeTitle)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clear)
    }
}
