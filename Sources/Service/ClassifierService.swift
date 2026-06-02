import CoreGraphics
import Foundation
import OnnxRuntimeBindings
import UIKit

enum ClassifierError: Error {
  case modelNotFound
  case preprocessingFailed
  case inferenceFailed(String)
}

struct ClassificationResult {
  let label: String
  let confidence: Float
}

final class ClassifierService: @unchecked Sendable {
  static let shared = ClassifierService()

  private let labels = ["Ak", "Kapadokya", "Nurlu", "Sira"]
  private let inputSize = 128
  private var session: ORTSession?

  private init() {
    do {
      guard let modelPath = Bundle.main.path(forResource: "cae_svm", ofType: "onnx") else {
        print("❌ Model not found in bundle")
        return
      }
      let env = try ORTEnv(loggingLevel: ORTLoggingLevel.warning)
      let options = try ORTSessionOptions()
      session = try ORTSession(env: env, modelPath: modelPath, sessionOptions: options)
      print("✅ ONNX session ready")
    } catch {
      print("❌ Failed to init session: \(error)")
    }
  }

  func classify(image: UIImage) throws -> [ClassificationResult] {
    guard let session else { throw ClassifierError.modelNotFound }

    guard let inputTensor = preprocess(image: image) else {
      throw ClassifierError.preprocessingFailed
    }

    let inputName = try session.inputNames().first ?? "input"

    let outputs = try session.run(
      withInputs: [inputName: inputTensor],
      outputNames: ["label", "probabilities"],
      runOptions: nil
    )

    if let labelTensor = outputs["label"] {
      let labelData = try labelTensor.tensorData() as Data
      let labelIndex = labelData.withUnsafeBytes { ptr in
        Array(ptr.bindMemory(to: Int64.self))
      }
      print("Predicted label index: \(labelIndex)")
    }

    guard let probTensor = outputs["probabilities"] else {
      throw ClassifierError.inferenceFailed("No probabilities output")
    }

    let probData = try probTensor.tensorData() as Data
    let probs = probData.withUnsafeBytes { ptr in
      Array(ptr.bindMemory(to: Float.self))
    }

    let results = zip(labels, probs).map { label, confidence in
      ClassificationResult(label: label, confidence: confidence)
    }.sorted { $0.confidence > $1.confidence }

    print("=== Classification Results ===")
    for result in results {
      print("\(result.label): \(String(format: "%.4f", result.confidence))")
    }
    print("==============================")

    return results
  }

  private func preprocess(image: UIImage) -> ORTValue? {
    guard let resized = image.resized(to: CGSize(width: inputSize, height: inputSize)),
      let cgImage = resized.cgImage
    else { return nil }

    let width = inputSize
    let height = inputSize
    let channels = 3
    let count = channels * height * width

    var floatData = [Float](repeating: 0, count: count)

    guard
      let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
      )
    else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let pixelData = context.data else { return nil }
    let pixels = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)

    for y in 0..<height {
      for x in 0..<width {
        let pixelIndex = (y * width + x) * 4
        let r = Float(pixels[pixelIndex]) / 255.0
        let g = Float(pixels[pixelIndex + 1]) / 255.0
        let b = Float(pixels[pixelIndex + 2]) / 255.0
        floatData[0 * height * width + y * width + x] = r
        floatData[1 * height * width + y * width + x] = g
        floatData[2 * height * width + y * width + x] = b
      }
    }

    let shape: [NSNumber] = [
      1,
      NSNumber(value: channels),
      NSNumber(value: height),
      NSNumber(value: width),
    ]
    let data = Data(bytes: floatData, count: count * MemoryLayout<Float>.size)

    return try? ORTValue(
      tensorData: NSMutableData(data: data),
      elementType: .float,
      shape: shape
    )
  }
}

extension UIImage {
  fileprivate func resized(to size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: size))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
