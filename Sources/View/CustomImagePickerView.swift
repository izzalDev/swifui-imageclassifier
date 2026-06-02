import SwiftUI
import UniformTypeIdentifiers

extension View {
  @ViewBuilder
  func cropImagePicker(
    show: Binding<Bool>,
    croppedImage: Binding<UIImage?>
  ) -> some View {
    CustomImagePicker(
      show: show,
      croppedImage: croppedImage
    ) {
      self
    }
  }
}

private struct CustomImagePicker<Content: View>: View {
  @ObserveInjection var injection
  var content: Content

  @Binding var show: Bool
  @Binding var croppedImage: UIImage?

  @State private var imageToCrop: UIImage?
  @State private var showCropView: Bool = false

  init(
    show: Binding<Bool>, croppedImage: Binding<UIImage?>,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.content = content()
    self._show = show
    self._croppedImage = croppedImage
  }

  var body: some View {
    content
      .fileImporter(
        isPresented: $show,
        allowedContentTypes: [.image],
        allowsMultipleSelection: false
      ) { result in
        if case .success(let urls) = result, let url = urls.first {
          let gotAccess = url.startAccessingSecurityScopedResource()
          if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            self.imageToCrop = image
            self.showCropView = true
          }
          if gotAccess { url.stopAccessingSecurityScopedResource() }
        }
      }
      .fullScreenCover(isPresented: $showCropView) {
        if let image = imageToCrop {
          CropView(image: image) { result, status in
            if status {
              croppedImage = result
            }
            imageToCrop = nil
          }
        }
      }
      .enableInjection()
  }
}
