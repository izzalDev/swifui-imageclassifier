import SwiftUI

struct HomeView: View {
  @ObserveInjection var injection
  @State private var croppedImage: UIImage?
  @State private var show: Bool = false
  var body: some View {
    NavigationStack {
      VStack {
        if let croppedImage {
          Image(uiImage: croppedImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 300)
            .background(.black)
        } else {
          Text("No Image is Selected")
            .font(.caption)
            .foregroundColor(.gray)
        }
      }
      .navigationTitle("Crop Image Picker")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            show = true
          } label: {
            Image(systemName: "photo.on.rectangle.angled")
              .font(.callout)
          }
        }
      }
      .cropImagePicker(
        options: [.circle, .square, .rectangle],
        show: $show,
        croppedImage: $croppedImage)
    }
    .enableInjection()
  }
}
