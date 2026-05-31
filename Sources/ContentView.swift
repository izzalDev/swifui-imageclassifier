import SwiftUI

struct ContentView: View {
  @ObserveInjection var injection

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello World")
        .padding(10)
        .background(.black)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.yellow)
    .enableInjection()
  }
}
