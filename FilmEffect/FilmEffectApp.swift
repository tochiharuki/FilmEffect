//
//  FilmEffectApp.swift
//  FilmEffect
//
//  Created by Tochishita Haruki on 2025/10/16.
//

import SwiftUI
import PhotosUI

@main
struct FilmEffectApp: App {
    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}

// MARK: - タイトル + 写真選択画面
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
                    PhotoEditorView(image: image)
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

// MARK: - 編集画面
struct PhotoEditorView: View {
    let image: UIImage
    @State private var selectedFrameColor: Color = .clear

    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                Rectangle()
                    .fill(selectedFrameColor.opacity(0.3))
                    .blendMode(.screen)
            }

            Spacer()

            Text("Choose a frame style")
                .font(.headline)
                .padding(.top)

            HStack {
                ForEach([Color.red, .orange, .white, .blue, .clear], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            selectedFrameColor = color
                        }
                        .overlay(
                            Circle().stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.vertical)
        }
        .padding()
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 写真ピッカー
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}