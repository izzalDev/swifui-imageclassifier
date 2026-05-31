import PhotosUI
import SwiftUI

extension View {
  @ViewBuilder
  func cropImagePicker(
    options: [Crop],
    show: Binding<Bool>,
    croppedImage: Binding<UIImage?>
  ) -> some View {
    CustomImagePicker(
      options: options,
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
  var options: [Crop]
  @Binding var show: Bool
  @Binding var croppedImage: UIImage?
  @State private var photosItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var showDialog: Bool = false
  @State private var selectedCroptype: Crop = .circle
  @State private var showCropView: Bool = false

  init(
    options: [Crop], show: Binding<Bool>, croppedImage: Binding<UIImage?>,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.content = content()
    self._show = show
    self._croppedImage = croppedImage
    self.options = options
  }
  var body: some View {
    content
      .photosPicker(isPresented: $show, selection: $photosItem)
      .onChange(of: photosItem) { oldValue, newValue in
        if let newValue {
          Task {
            if let imageData = try? await newValue.loadTransferable(type: Data.self),
              let image =
                UIImage(data: imageData)
            {
              await MainActor.run(body: {
                selectedImage = image
                showDialog.toggle()
              })
            }
          }
        }
      }
      .sheet(isPresented: $showDialog) {
        VStack {
          ForEach(options.indices, id: \.self) { index in
            Button(options[index].name()) {
              selectedCroptype = options[index]
              showCropView.toggle()
              showDialog = false
            }
            .padding()
          }
        }
        .presentationDetents([.height(200)])
      }
      .enableInjection()
  }
}
