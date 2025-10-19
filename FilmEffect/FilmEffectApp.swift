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

// MARK: - 編集画面
struct EditView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedFrame: String? = nil
    @State private var isPickerPresented = false
    
    let frames = ["frame01", "frame02"] // アセット名
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                ZStack {
                    // 背景写真をアスペクトフィットで表示
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                    
                    // 選択中のフレーム画像を上に重ねる
                    if let frameName = selectedFrame {
                        Image(frameName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .allowsHitTesting(false) // タップを通す
                    }
                }
                .padding()
                
                // フレーム選択ボタン
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(frames, id: \.self) { frame in
                            Button {
                                selectedFrame = frame
                            } label: {
                                Image(frame)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedFrame == frame ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                // 写真が未選択のとき
                VStack(spacing: 20) {
                    Text("FilmEffect")
                        .font(.largeTitle)
                        .bold()
                    Button("Select Photo") {
                        isPickerPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .photosPicker(isPresented: $isPickerPresented, selection: Binding.constant(nil), matching: .images)
        .onChange(of: isPickerPresented) { _ in
            // Picker終了後に選択された画像を処理（↓に処理追加する）
        }
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