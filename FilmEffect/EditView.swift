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
            GeometryReader { geometry in
                // 読み込んだ画像の縦横比を算出
                let aspect = image.size.width / image.size.height

                ZStack {
                    // 背景の写真
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(aspect, contentMode: .fit)

                    // フレーム（画像と同じ比率で重ねる）
                    if let frameName = selectedFrame {
                        Image(frameName)
                            .resizable()
                            .aspectRatio(aspect, contentMode: .fit)
                            .allowsHitTesting(false)
                    }
                }
                // 画面中央に表示
                .frame(width: geometry.size.width,
                       height: geometry.size.width / aspect)
                .clipped()
                .position(x: geometry.size.width / 2,
                          y: geometry.size.height / 2)
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
        }
        .navigationTitle("Edit Photo")
        .navigationBarTitleDisplayMode(.inline)
    }
}