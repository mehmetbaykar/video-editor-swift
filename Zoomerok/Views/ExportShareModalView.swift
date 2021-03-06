import SwiftUI

struct ExportShareModalView: View {
    @Binding var isPaid: Bool
    @Binding var isHideWatermark: Bool

    @State var isInit = false

    var onSaveStart: () -> Void
    var onCancel: () -> Void
    var onOpenSubscription: () -> Void
    var onTiktokShare: () -> Void

    var body: some View {
        VStack {
            Text("Export or share video")
                .foregroundColor(.gray)
                .padding(.bottom, 150)

//            Toggle(isOn: self.$isHideWatermark) {
//                Text("Hide watermark (app name)")
//                    .foregroundColor(.white)
//            }
//                .padding()
//                .onReceive([self.isHideWatermark].publisher.first()) { (value) in
//                    if !self.isInit {
//                        self.isInit = true
//                        print("Jut init")
//                        return
//                    }
//
//                    print("Disable watermark New value is: \(value) \(self.isHideWatermark)")
//                    if value {
//                        if !self.isPaid {
//                            self.isHideWatermark = false
//                            self.onOpenSubscription()
//                        }
//                    }
//            }

            Button(action: {
                print("Share clicked")
                self.onTiktokShare()
            }) {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundColor(.white)
                    Text("Share to TikTok")
                }
                    .padding(8)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
                .padding()

            Button(action: {
                self.onSaveStart()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.white)
                    Text("Save to gallery")
                }
                    .padding(8)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }

            Color.black.edgesIgnoringSafeArea(.all)
            Spacer()

            Button("Close") {
                self.onCancel()
            }
                .padding()
                .foregroundColor(.white)
        }
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ExportShareModalView_Previews: PreviewProvider {
    @State static var isPaid: Bool = false
    @State static var isHideWatermark: Bool = true

    static var previews: some View {
        ExportShareModalView(
            isPaid: self.$isPaid,
            isHideWatermark: $isHideWatermark,
            onSaveStart: {
                print("onSaveStart")
            },
            onCancel: {
                print("onCancel")
            },
            onOpenSubscription: {

            },
            onTiktokShare: {

            })
    }
}
