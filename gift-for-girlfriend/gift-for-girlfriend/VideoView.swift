import SwiftUI
import AVKit

struct VideoView: View {
    @Binding var isPresented: Bool
    @State private var player: AVPlayer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                        .aspectRatio(contentMode: .fill)
                        .onAppear {
                            if let currentItem = player.currentItem {
                                currentItem.videoComposition = nil
                                currentItem.asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
                                    DispatchQueue.main.async {
                                        player.play()
                                    }
                                }
                            }
                        }
                }
                
                // 添加返回按钮
                VStack {
                    HStack {
                        Button(action: {
                            player?.pause()
                            isPresented = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(.black.opacity(0.15))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.top, 10)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
        .onAppear {
            // 通知 ContentView 暂停背景音乐
            NotificationCenter.default.post(name: NSNotification.Name("PauseBackgroundMusic"), object: nil)
            // 使用视频文件
            if let videoURL = Bundle.main.url(forResource: "love_moive_2_row", withExtension: "mp4") {
                // 创建 AVPlayerItem 时设置视频属性
                let asset = AVAsset(url: videoURL)
                let playerItem = AVPlayerItem(asset: asset)
                
                // 设置视频输出
                playerItem.videoComposition = nil
                
                player = AVPlayer(playerItem: playerItem)
                
                // 添加视频播放完成的观察者
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem,
                    queue: .main
                ) { _ in
                    isPresented = false
                }
            }
        }
        .onDisappear {
            // 通知 ContentView 继续播放背景音乐
            NotificationCenter.default.post(name: NSNotification.Name("ResumeBackgroundMusic"), object: nil)
            player?.pause()
            player = nil
        }
    }
} 