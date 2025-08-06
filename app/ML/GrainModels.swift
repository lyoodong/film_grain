import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreML
import Vision

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

// MARK: – 8차원 피처 결과물
struct GrainFeatures {
    let avgLuma:     Float   // 평균 명도
    let rmsContrast: Float   // RMS 대비
    let entropy:     Float   // Shannon 엔트로피
    let edgeDensity: Float   // 컨투어 밀도
    let colorVar:    Float   // RGB 분산 평균
    let satStdDev:   Float   // 채도 표준편차
    let highlights:  Float   // 하이라이트 픽셀 비율
    let shadows:     Float   // 섀도 픽셀 비율
}

func extractFeatures(from ui: UIImage) -> GrainFeatures? {
    guard let cg = ui.cgImage else { return nil }
    let ci  = CIImage(cgImage: cg)
    let ctx = CIContext()
    
    // ── 1) 썸네일 (최대 한 변 128px)
    let scale = 128.0 / max(ci.extent.width, ci.extent.height)
    let thumb = ci.applyingFilter("CILanczosScaleTransform", parameters: [
        "inputScale": scale,
        "inputAspectRatio": 1.0
    ])
    
    // ── 2) 평균 명도 (areaAverage)
    let avgF = CIFilter.areaAverage()
    avgF.inputImage = thumb
    avgF.extent     = thumb.extent
    guard let avgImg = avgF.outputImage,
          let avgPix = ctx.renderPixel(from: avgImg) else { return nil }
    let avgLuma = avgPix.red
    
    // ── 3) 64-bin 히스토그램 생성
    let binCount = 64
    let histF = CIFilter(name: "CIAreaHistogram", parameters: [
        kCIInputImageKey: thumb,
        "inputExtent":    CIVector(cgRect: thumb.extent),
        "inputCount":     binCount,
        "inputScale":     1
    ])!
    guard let histImg = histF.outputImage else { return nil }
    
    // ── 4) 히스토그램 → Float 버퍼 (.RGBAf)
    let floatsPerPixel = 4
    var histBuffer = [Float](repeating: 0, count: binCount * floatsPerPixel)
    ctx.render(histImg,
               toBitmap: &histBuffer,
               rowBytes: MemoryLayout<Float>.size * floatsPerPixel * binCount,
               bounds: CGRect(x: 0, y: 0, width: binCount, height: 1),
               format: .RGBAf,
               colorSpace: nil)
    // R 채널(카운트)만 추출
    let counts = (0..<binCount).map { histBuffer[$0 * floatsPerPixel] }
    let total  = counts.reduce(0, +)
    guard total > 0 else { return nil }
    
    // ── 5) 평균 · 분산 · RMS 대비 계산
    var mean: Float = 0
    for (i, c) in counts.enumerated() {
        let intensity = Float(i) / Float(binCount - 1)
        mean += intensity * c
    }
    mean /= total
    
    var variance: Float = 0
    for (i, c) in counts.enumerated() {
        let intensity = Float(i) / Float(binCount - 1)
        let d = intensity - mean
        variance += d * d * c
    }
    variance /= total
    
    let rmsContrast = sqrt(variance)
    
    // ── 6) Shannon 엔트로피 계산
    var entropy: Float = 0
    for c in counts where c > 0 {
        let p = c / total
        entropy -= p * log2(p)
    }
    
    // ── 7) 에지 밀도 (Contour 수 / 전체 픽셀 수)
    let thumbExtent = thumb.extent
    let edgeReq = VNDetectContoursRequest()
    try? VNImageRequestHandler(ciImage: thumb).perform([edgeReq])
    let contours   = edgeReq.results?.first?.contourCount ?? 0
    let pixelCount = Float(thumbExtent.width * thumbExtent.height)
    let edgeDensity = Float(contours) / pixelCount
    
    // ── 8) 컬러 분산 (채널별 분산 평균)
    func channelVariance(r: CIVector, g: CIVector, b: CIVector) -> Float {
        let mat = thumb.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": r,
            "inputGVector": g,
            "inputBVector": b
        ])
        let hF = CIFilter(name: "CIAreaHistogram", parameters: [
            kCIInputImageKey: mat,
            "inputExtent":    CIVector(cgRect: mat.extent),
            "inputCount":     32,
            "inputScale":     1
        ])!
        guard let hImg = hF.outputImage else { return 0 }
        var buf = [Float](repeating: 0, count: 32 * floatsPerPixel)
        ctx.render(hImg,
                   toBitmap: &buf,
                   rowBytes: MemoryLayout<Float>.size * floatsPerPixel * 32,
                   bounds: CGRect(x:0, y:0, width:32, height:1),
                   format: .RGBAf,
                   colorSpace: nil)
        let cts = (0..<32).map { buf[$0 * floatsPerPixel] }
        let tot = cts.reduce(0, +); guard tot>0 else { return 0 }
        var m: Float = 0
        for (i, c) in cts.enumerated() {
            m += Float(i) / 31 * c
        }
        m /= tot
        var v: Float = 0
        for (i, c) in cts.enumerated() {
            let val = Float(i) / 31
            let d = val - m
            v += d * d * c
        }
        return v / tot
    }
    let colorVar = channelVariance(
        r: .init(x:1,y:0,z:0,w:0),
        g: .init(x:0,y:1,z:0,w:0),
        b: .init(x:0,y:0,z:1,w:0)
    )
    
    // ── 9) 채도 표준편차
    let satImg = thumb.applyingFilter("CIColorControls", parameters: ["inputSaturation": 2.0])
    let satF = CIFilter(name: "CIAreaHistogram", parameters: [
        kCIInputImageKey: satImg,
        "inputExtent":    CIVector(cgRect: satImg.extent),
        "inputCount":     32,
        "inputScale":     1
    ])!
    guard let satImgOut = satF.outputImage else { return nil }
    var satBuf = [Float](repeating: 0, count: 32 * floatsPerPixel)
    ctx.render(satImgOut,
               toBitmap: &satBuf,
               rowBytes: MemoryLayout<Float>.size * floatsPerPixel * 32,
               bounds: CGRect(x:0, y:0, width:32, height:1),
               format: .RGBAf,
               colorSpace: nil)
    let satCounts = (0..<32).map { satBuf[$0 * floatsPerPixel] }
    let satTot    = satCounts.reduce(0, +)
    var meanS: Float = 0
    for (i, c) in satCounts.enumerated() {
        meanS += Float(i) / 31 * c
    }
    meanS /= satTot
    var varS: Float = 0
    for (i, c) in satCounts.enumerated() {
        let val = Float(i) / 31
        let d = val - meanS
        varS += d * d * c
    }
    let satStdDev = sqrt(varS / satTot)
    
    // ── 10) 하이라이트·섀도우 비율
    func ratio(th: Float, above: Bool) -> Float {
        let t    = CGFloat(th)
        let zero = CGFloat(0), one = CGFloat(1)
        let minV = CIVector(x: above ? t : zero,
                            y: above ? t : zero,
                            z: above ? t : zero,
                            w: one)
        let maxV = CIVector(x: above ? one : t,
                            y: above ? one : t,
                            z: above ? one : t,
                            w: one)
        let clamp = thumb.applyingFilter("CIColorClamp", parameters: [
            "inputMinComponents": minV,
            "inputMaxComponents": maxV
        ])
        let hf = CIFilter(name: "CIAreaHistogram", parameters: [
            kCIInputImageKey: clamp,
            "inputExtent":    CIVector(cgRect: clamp.extent),
            "inputCount":     2,
            "inputScale":     1
        ])!
        guard let hImg = hf.outputImage else { return 0 }
        var buf2 = [Float](repeating: 0, count: 2 * floatsPerPixel)
        ctx.render(hImg,
                   toBitmap: &buf2,
                   rowBytes: MemoryLayout<Float>.size * floatsPerPixel * 2,
                   bounds: CGRect(x:0, y:0, width:2, height:1),
                   format: .RGBAf,
                   colorSpace: nil)
        let cts2 = (0..<2).map { buf2[$0 * floatsPerPixel] }
        guard let last = cts2.last else { return 0 }
        return last / pixelCount
    }
    let highlights = ratio(th: 0.9, above: true)
    let shadows    = ratio(th: 0.1, above: false)
    
    return GrainFeatures(
        avgLuma:     avgLuma,
        rmsContrast: rmsContrast,
        entropy:     entropy,
        edgeDensity: edgeDensity,
        colorVar:    colorVar,
        satStdDev:   satStdDev,
        highlights:  highlights,
        shadows:     shadows
    )
}

// MARK: – 단일 픽셀 RGBA8 읽기 헬퍼
extension CIContext {
    func renderPixel(from img: CIImage) -> (red: Float, green: Float, blue: Float, alpha: Float)? {
        var buf = [UInt8](repeating: 0, count: 4)
        render(img,
               toBitmap: &buf,
               rowBytes: 4,
               bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
               format: .RGBA8,
               colorSpace: CGColorSpaceCreateDeviceRGB())
        return (
            Float(buf[0]) / 255,
            Float(buf[1]) / 255,
            Float(buf[2]) / 255,
            Float(buf[3]) / 255
        )
    }
}


extension EditViewModel {
  /// ML 예측 호출 (Float → Double 변환 주의)
  func predictPreset(for uiImage: UIImage) -> (alpha: Double, scale: Double, contrast: Double)? {
    guard let feats = extractFeatures(from: uiImage) else { return nil }

    // 공통 피처를 Double로 변환
    let avg   = Double(feats.avgLuma)
    let rms   = Double(feats.rmsContrast)
    let ent   = Double(feats.entropy)
    let edge  = Double(feats.edgeDensity)
    let colv  = Double(feats.colorVar)
    let sat   = Double(feats.satStdDev)
    let high  = Double(feats.highlights)
    let shad  = Double(feats.shadows)

    // ➊ grainAlpha 예측
    let alphaInput = GrainAlphaRegressorInput(
      avgLuma:     avg,
      rmsContrast: rms,
      entropy:     ent,
      edgeDensity: edge,
      colorVar:    colv,
      satStdDev:   sat,
      highlights:  high,
      shadows:     shad
    )
    guard let alphaOut = try? GrainModels.shared.alphaModel.prediction(input: alphaInput) else {
      return nil
    }

    // ➋ grainScale 예측
    let scaleInput = GrainScaleRegressorInput(
      avgLuma:     avg,
      rmsContrast: rms,
      entropy:     ent,
      edgeDensity: edge,
      colorVar:    colv,
      satStdDev:   sat,
      highlights:  high,
      shadows:     shad
    )
    guard let scaleOut = try? GrainModels.shared.scaleModel.prediction(input: scaleInput) else {
      return nil
    }

    // ➌ contrast 예측
    let contrastInput = ContrastRegressorInput(
      avgLuma:     avg,
      rmsContrast: rms,
      entropy:     ent,
      edgeDensity: edge,
      colorVar:    colv,
      satStdDev:   sat,
      highlights:  high,
      shadows:     shad
    )
    guard let contrastOut = try? GrainModels.shared.contrastModel.prediction(input: contrastInput) else {
      return nil
    }

    return (
      alpha:    alphaOut.grainAlpha,
      scale:    scaleOut.grainScale,
      contrast: contrastOut.contrast
    )
  }
}

