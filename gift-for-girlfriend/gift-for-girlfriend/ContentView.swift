//
//  ContentView.swift
//  gift-for-girlfriend
//
//  Created by 王昊 on 2024/12/31.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showVideo = false
    @State private var isAnimating = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isMusicPlaying = true // 添加音乐播放状态
    
    var body: some View {
        ZStack {
            // 背景
            Color.red.opacity(0.1)
                .ignoresSafeArea()
            
            // 漂浮的雪花效果
            ForEach(0..<30) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 5...15))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(0.6)
            }
            
            VStack(spacing: 30) {
                Text("新年快乐")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundColor(.red)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Button(action: {
                    withAnimation {
                        showVideo = true
                    }
                }) {
                    Text("点击获取小燕的礼物")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red)
                                .shadow(radius: 5)
                        )
                }
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            }
            
            // 添加音乐控制按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if isMusicPlaying {
                            audioPlayer?.pause()
                        } else {
                            audioPlayer?.play()
                        }
                        isMusicPlaying.toggle()
                    }) {
                        Image(systemName: isMusicPlaying ? "speaker.wave.3.fill" : "speaker.slash.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            isAnimating = true
            setupAudioPlayer()
        }
        .fullScreenCover(isPresented: $showVideo) {
            VideoView(isPresented: $showVideo)
        }
    }
    
    private func setupAudioPlayer() {
        if let audioURL = Bundle.main.url(forResource: "music_background", withExtension: "flac") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.numberOfLoops = -1 // 循环播放
                audioPlayer?.play()
            } catch {
                print("音频播放失败: \(error.localizedDescription)")
            }
        }
        
        // 添加通知观察者
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("PauseBackgroundMusic"),
            object: nil,
            queue: .main
        ) { _ in
            audioPlayer?.pause()
            isMusicPlaying = false
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ResumeBackgroundMusic"),
            object: nil,
            queue: .main
        ) { _ in
            audioPlayer?.play()
            isMusicPlaying = true
        }
    }
}

#Preview {
    ContentView()
}
