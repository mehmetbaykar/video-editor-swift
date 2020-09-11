import SwiftUI
import AVKit

struct ContentView: View {
//    @State private var showImagePicker: Bool = false
//    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State var videoUrl: URL?
    @State var player: AVPlayer?
    @State var montageInstance = Montage()
    @State var playerController = AVPlayerViewController()
    @State var previewAsset: AVAsset?
    // todo how to use var direct from PreviewControlView?
    @State var isPlay: Bool = false
    @State var effectState: EffectState = EffectState("SpiderAttack-preview")

    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    //@State private var offset: CGPoint = .zero
    //var scrollPosition: CGFloat = .zero
    @State private var offset: CGFloat = .zero

//    @State private var image: UIImage?
    private var isSimulator: Bool = false

    init() {
        #if targetEnvironment(simulator)
            // your simulator code
            initTestVideoForSimulator()
            print("Document directory", DownloadTestContent.getDocumentsDirectory())
            self.isSimulator = true
            //DownloadTestContent.downloadAll()
        #else
            // your real device code
            self.isSimulator = false
        #endif

        UINavigationBar.appearance().largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
        ]

        self.playerController.showsPlaybackControls = false
    }

    func initTestVideoForSimulator() {
        let fileUrl = DownloadTestContent.getFilePath("test-files/1VideoBig.mov")
        print("previewAsset")
        self.previewAsset = AVAsset(url: fileUrl)
        self.videoUrl = fileUrl
        self.playerController.player = self.makeSimplePlayer(url: fileUrl)

        self.playerController.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { (_) in
            print("OBSERVE")
            /*self.value = self.getSliderValue()
             
             if self.value == 1.0{
             
             self.isplaying = false
             }*/
        }
    }

    func getSliderValue() -> Float {
        return Float(self.playerController.player!.currentTime().seconds / (self.playerController.player!.currentItem?.duration.seconds)!)
    }

    func makeCropPlayer(url: URL) -> AVPlayer {
        _ = montageInstance.setVideoSource(url: url)
        let size = montageInstance.getCorrectSourceSize()
        //print("size", size)
        let rect = CGRect(x: (size.width / 2) + 180, y: 0, width: (size.width / 2) - 180, height: size.height)
        var player: AVPlayer?
        do {
            let item = try montageInstance
                .setTopPart(startTime: 1, endTime: 3)
                .setBottomPart(startTime: 3, endTime: 12)
                .cropTopPart(rect: rect)
                .getAVPlayerItem()

            player = AVPlayer(playerItem: item)
        } catch {
            print("Smth not ok")
        }

        return player!
    }

    func makeSimplePlayer(url: URL) -> AVPlayer {
        _ = montageInstance.setVideoSource(url: url)

        var player: AVPlayer?
        do {
            let item = try montageInstance
            //.setTopPart(startTime: 1, endTime: 12)
            .setBottomPart(startTime: 3, endTime: 11)
                .getAVPlayerItem()

            player = AVPlayer(playerItem: item)
        } catch {
            print("Something not ok")
        }

        return player!
    }

    func onScroll(r: CGFloat) -> Void {
        if (self.offset == r) {
            //print("STORED scroll offset")
            return
        } else {
            self.offset = r
        }
        print("Scroll percent", r)
        //print("OK RES 2", r)
        /*let duration = (self.playerController.player?.currentItem?.duration)!
         print("duration", duration)
         let toTime=CMTimeMultiplyByRatio(duration, multiplier: 9,divisor: 100000)*/
        //print("toTime", toTime)
        //self.playerController.player?.seek(to: CMTimeMakeWithSeconds(5, preferredTimescale: 60))
        let percentCoeff = Float(r / 100)
        let duration = Float((self.playerController.player?.currentItem?.duration.seconds)!)
        let sec = Double(percentCoeff * duration)

        let toTime = CMTime(seconds: sec, preferredTimescale: 1000)
        print(percentCoeff, duration, sec)
        self.playerController.player?.seek(to: toTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    var body: some View {
        NavigationView {
            VStack {
                /*Image(systemName: "square.and.arrow.down.fill")
                 .padding(.vertical)
                 .frame(width: 30.0, height: 100.0)
                 .font(.system(size: 30))
                 .foregroundColor(SwiftUI.Color.white)
                 .onTapGesture {
                 print("Export file")
                 }*/

                CustomPlayer(url: $videoUrl, isPlay: $isPlay, montage: $montageInstance, playerController: $playerController)
                    .frame(height: UIScreen.main.bounds.height / 2)


                /*ScrollPreviewView() { (result) -> () in
                 // do stuff with the result
                 self.onScroll(r: result)
                 //print("IT WORKS", result)
                 //print("IT WORKS 2", result)
                 //self.playerController.player?.seek(to: CMTimeMakeWithSeconds(10, preferredTimescale: 60))
                 }*/

                VideoRangeSliderView(asset: $previewAsset, duration: 10, effectState: self.$effectState, onResize: { result in
                    print(result)
                }, onChangeCursorPosition: { result in
                        print(result)
                    })

                EffectSelectorView(onEffectSelected: { result in
                    //print(result)
                    self.effectState = EffectState(result.previewUrl)
                    return
                })

                PreviewControlView(isSimulator: isSimulator,
                    onPlayPause: { result in
                        self.isPlay = result
                    },
                    onContentChanged: { result in
                        self.videoUrl = result
                        self.playerController.player = self.makeSimplePlayer(url: result)
                    })

                Spacer()
            }

                .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))

            // for NavigationView. Two properties for removing space from top
            // https://stackoverflow.com/questions/57517803/how-to-remove-the-default-navigation-bar-space-in-swiftui-navigiationview
            .navigationBarTitle("")
                .navigationBarHidden(true)
        }


        // for View
//        .sheet(isPresented: $showImagePicker) {
//            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomPlayer: UIViewControllerRepresentable {
    @Binding var url: URL?
    @Binding var isPlay: Bool
    @Binding var montage: Montage
    @Binding var playerController: AVPlayerViewController


    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomPlayer>) -> AVPlayerViewController {

        return playerController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<CustomPlayer>) {
        print("updateUIViewController")

        if isPlay {
            uiViewController.player?.play()
        } else {
            uiViewController.player?.pause()
        }
    }

}

/// See `View.onChange(of: value, perform: action)` for more information
struct ChangeObserver<Base: View, Value: Equatable>: View {
    let base: Base
    let value: Value
    let action: (Value)->Void

    @State var model = Model()

    var body: some View {
        if model.update(value: value) {
            DispatchQueue.main.async { self.action(self.value) }
        }
        return base
    }

    class Model {
        private var savedValue: Value?
        func update(value: Value) -> Bool {
            guard value != savedValue else { return false }
            savedValue = value
            return true
        }
    }
}

extension View {
    /// Adds a modifier for this view that fires an action when a specific value changes.
    ///
    /// You can use `onChange` to trigger a side effect as the result of a value changing, such as an Environment key or a Binding.
    ///
    /// `onChange` is called on the main thread. Avoid performing long-running tasks on the main thread. If you need to perform a long-running task in response to value changing, you should dispatch to a background queue.
    ///
    /// The new value is passed into the closure. The previous value may be captured by the closure to compare it to the new value. For example, in the following code example, PlayerView passes both the old and new values to the model.
    ///
    /// ```
    /// struct PlayerView : View {
    ///   var episode: Episode
    ///   @State private var playState: PlayState
    ///
    ///   var body: some View {
    ///     VStack {
    ///       Text(episode.title)
    ///       Text(episode.showTitle)
    ///       PlayButton(playState: $playState)
    ///     }
    ///   }
    ///   .onChange(of: playState) { [playState] newState in
    ///     model.playStateDidChange(from: playState, to: newState)
    ///   }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether to run the closure.
    ///   - action: A closure to run when the value changes.
    ///   - newValue: The new value that failed the comparison check.
    /// - Returns: A modified version of this view
    func onChange<Value: Equatable>(of value: Value, perform action: @escaping (_ newValue: Value)->Void) -> ChangeObserver<Self, Value> {
        ChangeObserver(base: self, value: value, action: action)
    }
}
