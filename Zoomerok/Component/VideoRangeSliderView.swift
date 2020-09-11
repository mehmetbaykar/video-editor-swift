import SwiftUI
import AVKit

struct VideoRangeSliderView: View {
    @Binding var asset: AVAsset?
    private var adapterAsset: Binding<AVAsset> {
        Binding<AVAsset>(get: {
            //self.willUpdate()
            print("---get adapter")
            return self.asset!
        }, set: {
                print("---set adapter")
                self.asset = $0
                //self.didModify()
            })
    }

    @State var widthLeft: CGFloat = 0
    @State var widthRight: CGFloat = UIScreen.main.bounds.width - 45

    var totalWidth = UIScreen.main.bounds.width - 45 // minus right left margins?
    var cornerSize = CGSize(width: 11, height: 53)
    var marginTopBottom: CGFloat = 3

    //var asset: AVAsset?
    var duration: CGFloat
    var onResize: (CGFloat) -> ()
    var onChangeCursorPosition: (CGFloat) -> ()

    init(
        asset: Binding<AVAsset?>,
        duration: CGFloat,
        @ViewBuilder onResize: @escaping (CGFloat) -> (),
        onChangeCursorPosition: @escaping (CGFloat) -> ()) {
        print("Video range INIT called")
        //self.asset = asset

        self._asset = asset
        self.duration = duration
        self.onResize = onResize
        self.onChangeCursorPosition = onChangeCursorPosition

        //print("asset", self.asset )
//        if self.asset != nil {
//            self.asset!.generateThumbnail { /*[weak self]*/ (image) in
//                DispatchQueue.main.async {
//                    print("image received")
//                    print(image as Any)
//                    //guard let image = image else { return }
//                    //self?.imageView.image = image
//                }
//            }
//        }
    }

    // todo округлять если маленькие граничные значения ( почти влево почти вправо)
    // сделать callback при движении ползунков
    // в каких ед передавать значения в callback? сек, проценты? Возможно сек, тогда будет легче делать seek
    // сделать минимальны зазор между ползунками
    // определить какой минимальный видос оно может обработать (3-2-1 сек?)
    // кто будет генерить preview? этот класс или нужен какой-то метод (превью могут загружаться не моментально. редактор должен работать, а превью грузиться)
    // как определить сколько preview нужно для полного заполнения?
    var body: some View {
        VStack {
//            Text("Value")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color.white)

//            Text("\(self.widthLeft / self.totalWidth) - \(self.widthRight / self.totalWidth)")
//                .foregroundColor(Color.white)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: cornerSize.height - marginTopBottom)
                    .offset(x: 3)

                Rectangle()
                    .fill(Color.white)
                    .border(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                    .frame(width: self.widthRight - self.widthLeft, height: cornerSize.height - marginTopBottom)
                    .offset(x: self.widthLeft + cornerSize.width)

                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color.red)
                        .frame(width: cornerSize.width, height: cornerSize.height)
                        .offset(x: self.widthLeft + 3)
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    if value.location.x >= 0 && value.location.x <= self.widthRight {
                                        self.widthLeft = value.location.x
                                    }

                                    self.onResize(111)
                                })
                        )

                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color.red)
                        .frame(width: cornerSize.width, height: cornerSize.height)
                        .offset(x: self.widthRight - 3)
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    if value.location.x <= self.totalWidth && value.location.x >= self.widthLeft {
                                        self.widthRight = value.location.x
                                    }

                                    self.onResize(222)
                                })
                        )
                }
            }
        }
            .padding()
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}

/*struct VideoRangeSliderView_Previews: PreviewProvider {
    static var previews: some View {
        VideoRangeSliderView(asset: Binding(AVAsset()), duration: 10, onResize: { result in
            print(result)
        },
                onChangeCursorPosition: { result in
                    print(result)
                })
    }
}*/

extension AVAsset {
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        print("generateThumbnail")
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    completion(nil)
                }
            })
        }
    }
}
