//
//  EditView.swift
//  FilmEffect
//
//  Created by Tochishita Haruki on 2025/10/19.
//

import SwiftUI
import Photos

struct EditView: View {
    let image: UIImage
    @State private var selectedFrame: String? = nil
    @State private var showSaveAlert = false
    @State private var saveError: String? = nil

    let frames = ["frame01", "frame02"]

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let aspect = image.size.width / image.size.height

                ZStack {
                    // 背景画像
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(aspect, contentMode: .fit)

                    // フレーム
                    if let frameName = selectedFrame {
                        Image(frameName)
                            .resizable()
                            .aspectRatio(aspect, contentMode: .fit)
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: geometry.size.width,
                       height: geometry.size.width / aspect)
                .clipped()
                .position(x: geometry.size.width / 2,
                          y: geometry.size.height / 2)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: ImageFrameKey.self, value: geo.frame(in: .global))
                    }
                )
            }
            .padding()

            // フレーム選択ボタン群
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

            // ダウンロードボタン
            Button(action: saveImageToPhotos) {
                Label("Save to Photos", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Edit Photo")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showSaveAlert) {
            if let error = saveError {
                return Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
            } else {
                return Alert(title: Text("Saved!"), message: Text("Your edited photo has been saved."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveImageToPhotos() {
        guard let rendered = renderCombinedImage() else {
            saveError = "Failed to create image."
            showSaveAlert = true
            return
        }
    
        // 写真ライブラリの権限確認
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(rendered, nil, nil, nil)
                    saveError = nil
                    showSaveAlert = true
                case .denied, .restricted:
                    saveError = "写真ライブラリのアクセスが拒否されています。設定から許可してください。"
                    showSaveAlert = true
                case .notDetermined:
                    // 初回はリクエスト後、次回以降は自動で上記に分岐
                    break
                @unknown default:
                    saveError = "不明なエラーが発生しました。"
                    showSaveAlert = true
                }
            }
        }
    }


    // MARK: - 合成画像を生成
    private func renderCombinedImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            // 背景
            image.draw(in: CGRect(origin: .zero, size: image.size))

            // フレームを重ねる
            if let frameName = selectedFrame, let overlay = UIImage(named: frameName) {
                overlay.draw(in: CGRect(origin: .zero, size: image.size), blendMode: .normal, alpha: 1.0)
            }
        }
    }
}

// MARK: - Geometry PreferenceKey（将来用）
private struct ImageFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}