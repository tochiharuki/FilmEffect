//
//  EditView.swift
//  FilmEffect
//
//  Created by Tochishita Haruki on 2025/10/19.
//

import SwiftUI
import Photos

enum WhiteFrameType {
    case none
    case vertical   // 左右に白枠
    case horizontal // 上下に白枠
}

struct EditView: View {
    let image: UIImage
    @State private var selectedFrame: String? = nil
    @State private var showSaveAlert = false
    @State private var saveError: String? = nil
    @State private var whiteFrameType: WhiteFrameType = .none

    let frames = ["frame01", "frame02"]

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let aspect = image.size.width / image.size.height

                ZStack {
                    // 元画像（縮小しない）
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(aspect, contentMode: .fit)
                
                    GeometryReader { geo in
                        let ratio: CGFloat = 1 / 15
                        let w = geo.size.width
                        let h = geo.size.height
                
                        if whiteFrameType == .horizontal {
                            VStack {
                                Color.white
                                    .frame(height: h * ratio)
                
                                Spacer()
                
                                Color.white
                                    .frame(height: h * ratio)
                            }
                        }
                
                        if whiteFrameType == .vertical {
                            HStack {
                                Color.white
                                    .frame(width: w * ratio)
                
                                Spacer()
                
                                Color.white
                                    .frame(width: w * ratio)
                            }
                        }
                    }
                    .allowsHitTesting(false)
                
                    // 既存フレーム画像
                    if let frameName = selectedFrame {
                        Image(frameName)
                            .resizable()
                            .aspectRatio(aspect, contentMode: .fit)
                            .allowsHitTesting(false)
                    }
                }
                .clipped()
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
            
            // 白枠フレーム選択
            HStack(spacing: 16) {
                Button("白枠なし") {
                    whiteFrameType = .none
                }
            
                Button("縦白枠") {
                    whiteFrameType = .vertical
                }
            
                Button("横白枠") {
                    whiteFrameType = .horizontal
                }
            }
            .padding(.top, 10)

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
    
        return renderer.image { _ in
            // 元画像
            image.draw(in: CGRect(origin: .zero, size: image.size))
    
            let ratio: CGFloat = 1 / 15
    
            if whiteFrameType == .horizontal {
                let h = image.size.height * ratio
    
                UIColor.white.setFill()
                UIRectFill(CGRect(x: 0, y: 0, width: image.size.width, height: h))
                UIRectFill(CGRect(
                    x: 0,
                    y: image.size.height - h,
                    width: image.size.width,
                    height: h
                ))
            }
    
            if whiteFrameType == .vertical {
                let w = image.size.width * ratio
    
                UIColor.white.setFill()
                UIRectFill(CGRect(x: 0, y: 0, width: w, height: image.size.height))
                UIRectFill(CGRect(
                    x: image.size.width - w,
                    y: 0,
                    width: w,
                    height: image.size.height
                ))
            }
    
            // 既存フレーム
            if let frameName = selectedFrame,
               let overlay = UIImage(named: frameName) {
                overlay.draw(in: CGRect(origin: .zero, size: image.size))
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