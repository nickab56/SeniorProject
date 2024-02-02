//
//  SpalshScreenView.swift
//  backblog
//
//  Created by Nick Abegg on 2/2/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Image("img_placeholder_backblog_logo")
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

