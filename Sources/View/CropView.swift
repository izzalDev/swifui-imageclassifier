import SwiftUI

struct CropView: View {
  @ObserveInjection var injection

  var crop: Crop
  var image: UIImage?
  var onCrop: (UIImage?, Bool) -> Void

  @Environment(\.dismiss) private var dismiss

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero

  var body: some View {
    NavigationStack {
      ImageView()
        .navigationTitle("Crop Image")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
              dismiss()
              onCrop(nil, false)
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Crop") {
              cropImage()
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .enableInjection()
    }
  }

  @ViewBuilder
  func ImageView() -> some View {
    let cropSize = crop.size()

    GeometryReader { proxy in
      let size = proxy.size

      ZStack {
        if let image {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cropSize.width, height: cropSize.height)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
              SimultaneousGesture(
                DragGesture()
                  .onChanged { value in
                    let newOffset = CGSize(
                      width: lastOffset.width + value.translation.width,
                      height: lastOffset.height + value.translation.height
                    )
                    offset = newOffset
                  }
                  .onEnded { _ in
                    lastOffset = offset
                  },
                MagnificationGesture()
                  .onChanged { value in
                    let newScale = lastScale * value
                    scale = max(1.0, newScale)
                  }
                  .onEnded { _ in
                    lastScale = scale
                  }
              )
            )
            .overlay(content: { Grids() })
            .frame(width: cropSize.width, height: cropSize.height)
            .clipShape(
              AnyShape(Rectangle())
            )
        }
      }
      .frame(width: size.width, height: size.height)
    }
  }

  @ViewBuilder
  func Grids() -> some View {
    ZStack {
      HStack {
        ForEach(1...5, id: \.self) { _ in
          Rectangle()
            .fill(.white.opacity(0.7))
            .frame(width: 1)
            .frame(maxWidth: .infinity)
        }
      }
      VStack {
        ForEach(1...5, id: \.self) { _ in
          Rectangle()
            .fill(.white.opacity(0.7))
            .frame(height: 1)
            .frame(maxHeight: .infinity)
        }
      }
    }
  }

  private func cropImage() {
    guard let image else {
      onCrop(nil, false)
      return
    }

    let cropSize = crop.size()
    let renderer = ImageRenderer(
      content:
        Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: cropSize.width, height: cropSize.height)
        .scaleEffect(scale)
        .offset(offset)
        .frame(width: cropSize.width, height: cropSize.height)
        .clipped()
    )

    renderer.scale = 3.0

    if let rendered = renderer.uiImage {
      if crop == .circle {
        let masked = rendered.circularMasked()
        onCrop(masked, true)
      } else {
        onCrop(rendered, true)
      }
    } else {
      onCrop(nil, false)
    }

    dismiss()
  }
}

extension UIImage {
  func circularMasked() -> UIImage {
    let size = CGSize(
      width: min(self.size.width, self.size.height),
      height: min(self.size.width, self.size.height))
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
      let rect = CGRect(origin: .zero, size: size)
      ctx.cgContext.addEllipse(in: rect)
      ctx.cgContext.clip()
      let xOffset = (size.width - self.size.width) / 2
      let yOffset = (size.height - self.size.height) / 2
      self.draw(at: CGPoint(x: xOffset, y: yOffset))
    }
  }
}
