//
//  EditView.swift
//  FilmEffect
//
//  Created by Tochishita Haruki on 2025/10/19.
//

import SwiftUI

struct EditView: View {
    let image: UIImage
    @State private var selectedFrame: String? = nil
    
    let frames = ["frame01", "frame02"] // アセット名

    var body: some View {
        VStack {
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
                        .allowsHitTesting(false)
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
        }
        .navigationTitle("Edit Photo")
        .navigationBarTitleDisplayMode(.inline)
    }
}