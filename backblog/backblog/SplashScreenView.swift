//
//  SplashScreenView.swift
//  backblog
//
//  Created by Nick Abegg on 2/2/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: View displaying the splash screen of the app.
//

import SwiftUI

/**
 View displaying the splash screen of the app.
 */
struct SplashScreenView: View {
    /**
     The body of the SplashScreenView that defines the SwiftUI content
     */
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                
                Text("BackBlog")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
    }
}

