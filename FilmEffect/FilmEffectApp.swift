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
            TitleView()
        }
    }
}

// MARK: - タイトル画面
struct TitleView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                Text("FilmEffect")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink("Start") {
                    PhotoEditorView()
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - 写真編集画面
struct PhotoEditorView: View {
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var selectedFrameColor: Color = .clear

    var body: some View {
        VStack {
            if let image = selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    Rectangle()
                        .fill(selectedFrameColor.opacity(0.3))
                        .blendMode(.screen)
                }
            } else {
                Text("写真を選択してください")
                    .foregroundColor(.gray)
            }

            Spacer()

            Button("写真を選ぶ") {
                showPicker = true
            }
            .buttonStyle(.bordered)

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
        .sheet(isPresented: $showPicker) {
            PhotoPicker(image: $selectedImage)
        }
        .navigationTitle("Edit")
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