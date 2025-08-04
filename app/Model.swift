import CoreML

final class GrainModels {
  static let shared = GrainModels()

  let alphaModel: GrainAlphaRegressor
  let scaleModel: GrainScaleRegressor
  let contrastModel: ContrastRegressor

  private init() {
    alphaModel = try! GrainAlphaRegressor(configuration: .init())
    scaleModel = try! GrainScaleRegressor(configuration: .init())
    contrastModel = try! ContrastRegressor(configuration: .init())
  }
}
