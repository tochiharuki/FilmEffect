//
//  StartView.swift
//  FilmEffect
//
//  Created by Tochishita Haruki on 2025/10/19.
//

import SwiftUI
import PhotosUI

struct StartView: View {
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var navigateToEditor = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Text("FilmEffect")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Select a photo to begin editing")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                Button {
                    showPicker = true
                } label: {
                    Text("Choose Photo")
                        .font(.headline)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .sheet(isPresented: $showPicker) {
                PhotoPicker(image: $selectedImage)
            }
            .navigationDestination(isPresented: $navigateToEditor) {
                if let image = selectedImage {
                    EditView(image: image)
                }
            }
            // 写真が選択されたら自動で遷移
            .onChange(of: selectedImage) { newValue in
                if newValue != nil {
                    navigateToEditor = true
                }
            }
        }
    }
}