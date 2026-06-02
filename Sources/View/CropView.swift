import SwiftUI

struct CropView: View {
  @ObserveInjection var injection
  var image: UIImage
  var onCrop: (UIImage?, Bool) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero

  private let cropSize: CGFloat = UIScreen.main.bounds.width

  var body: some View {
    NavigationStack {
      ZStack {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(width: cropSize, height: cropSize)
          .scaleEffect(scale)
          .offset(offset)
          .gesture(
            SimultaneousGesture(
              DragGesture().onChanged { value in
                offset = CGSize(
                  width: lastOffset.width + value.translation.width,
                  height: lastOffset.height + value.translation.height
                )
              }.onEnded { _ in lastOffset = offset },
              MagnificationGesture().onChanged { value in
                scale = max(1.0, lastScale * value)
              }.onEnded { _ in lastScale = scale }
            )
          )
          .frame(width: cropSize, height: cropSize)
          .clipped()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.black)
      .navigationTitle("Crop Image")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Crop") { cropImage() }
        }
      }
    }
    .enableInjection()
  }

  private func cropImage() {
    let renderer = ImageRenderer(
      content: Image(uiImage: image)
        .resizable()
        .aspectRatio(1, contentMode: .fit)
        .frame(width: cropSize, height: cropSize)
        .scaleEffect(scale)
        .offset(offset)
        .frame(width: cropSize, height: cropSize)
        .clipped()
    )
    renderer.scale = UIScreen.main.scale
    if let rendered = renderer.uiImage {
      onCrop(rendered, true)
    } else {
      onCrop(nil, false)
    }
    dismiss()
  }
}
