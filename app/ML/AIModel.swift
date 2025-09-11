import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision
import CoreML

struct AnalyzedFeature {
    let avgLuma:         Float   // 평균 명도
    let rmsContrast:     Float   // RMS 대비
    let colorVar:        Float   // RGB 분산 평균
    let satStdDev:       Float   // 채도 표준편차
    let highlights:      Float   // 하이라이트 픽셀 비율
    let shadows:         Float   // 섀도 픽셀 비율
    let midtoneRatio:    Float   // 중간톤 비율
    let meanHue:         Float   // 평균 색조
    let hueVariance:     Float   // 색조 분산
}

struct FredictedFeature {
    let grainAlpha: Double
    let grainscale: Double
    let contrast: Double
    let temperature: Double
    let threshold: Double
    let brightAlpha: Double
    let darkAlpha: Double
}


// MARK: – 메인 함수
func analyzeFeatures(from ui: UIImage) -> AnalyzedFeature? {
    guard let cg = ui.cgImage else { return nil }
    let ci  = CIImage(cgImage: cg)
    let ctx = CIContext()

    // ── 1) 썸네일 축소 (최대 한 변 128px)
    let scale = 128.0 / max(ci.extent.width, ci.extent.height)
    let thumb = ci.applyingFilter("CILanczosScaleTransform", parameters: [
        "inputScale": scale,
        "inputAspectRatio": 1.0
    ])

    // ── 2) 평균 명도
    let avgF = CIFilter.areaAverage()
    avgF.inputImage = thumb
    avgF.extent     = thumb.extent
    guard let avgImg = avgF.outputImage,
          let avgPix = ctx.renderPixel(from: avgImg) else { return nil }
    let avgLuma = avgPix.red

    // ── 3) 히스토그램 (밝기 기반)
    let binCount = 64
    let histF = CIFilter(name: "CIAreaHistogram", parameters: [
        kCIInputImageKey: thumb,
        "inputExtent":    CIVector(cgRect: thumb.extent),
        "inputCount":     binCount,
        "inputScale":     1
    ])!
    guard let histImg = histF.outputImage else { return nil }

    let floatsPerPixel = 4
    var histBuffer = [Float](repeating: 0, count: binCount * floatsPerPixel)
    ctx.render(histImg,
               toBitmap: &histBuffer,
               rowBytes: MemoryLayout<Float>.size * floatsPerPixel * binCount,
               bounds: CGRect(x: 0, y: 0, width: binCount, height: 1),
               format: .RGBAf,
               colorSpace: nil)
    let counts = (0..<binCount).map { histBuffer[$0 * floatsPerPixel] }
    let total  = counts.reduce(0, +)
    guard total > 0 else { return nil }

    // ── 4) RMS 대비
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

    // ── 5) RGB 컬러 분산 평균
    let colorVar = 0.33 * (
        channelVariance(thumb, ctx, r: .init(x:1,y:0,z:0,w:0)) +
        channelVariance(thumb, ctx, r: .init(x:0,y:1,z:0,w:0)) +
        channelVariance(thumb, ctx, r: .init(x:0,y:0,z:1,w:0))
    )

    // ── 6) 채도 표준편차
    let satStdDev = computeSatStdDev(from: thumb, ctx: ctx)

    // ── 7) 하이라이트·섀도우·중간톤 비율
    let highlights = ratio(ci: thumb, ctx: ctx, th: 0.9, above: true)
    let shadows    = ratio(ci: thumb, ctx: ctx, th: 0.1, above: false)
    let midtoneRatio = max(0, 1.0 - highlights - shadows)

    // ── 8) Hue 분석
    guard let hsvImg = convertToHSV(ci: thumb) else { return nil }
    let (meanHue, hueVariance) = computeHueStats(from: hsvImg, ctx: ctx)

    return .init(
        avgLuma: avgLuma,
        rmsContrast: rmsContrast,
        colorVar: colorVar,
        satStdDev: satStdDev,
        highlights: highlights,
        shadows: shadows,
        midtoneRatio: midtoneRatio,
        meanHue: meanHue,
        hueVariance: hueVariance
    )
}

// 채널별 분산 계산
func channelVariance(_ img: CIImage, _ ctx: CIContext, r: CIVector) -> Float {
    let mat = img.applyingFilter("CIColorMatrix", parameters: [
        "inputRVector": r,
        "inputGVector": CIVector(x:0,y:0,z:0,w:0),
        "inputBVector": CIVector(x:0,y:0,z:0,w:0)
    ])
    let hF = CIFilter(name: "CIAreaHistogram", parameters: [
        kCIInputImageKey: mat,
        "inputExtent": CIVector(cgRect: mat.extent),
        "inputCount": 32,
        "inputScale": 1
    ])!
    guard let hImg = hF.outputImage else { return 0 }
    var buf = [Float](repeating: 0, count: 32 * 4)
    ctx.render(hImg,
               toBitmap: &buf,
               rowBytes: MemoryLayout<Float>.size * 4 * 32,
               bounds: CGRect(x:0, y:0, width:32, height:1),
               format: .RGBAf,
               colorSpace: nil)
    let counts = (0..<32).map { buf[$0 * 4] }
    let total = counts.reduce(0,+)
    guard total > 0 else { return 0 }
    var mean: Float = 0
    for (i,c) in counts.enumerated() { mean += Float(i)/31 * c }
    mean /= total
    var varc: Float = 0
    for (i,c) in counts.enumerated() {
        let val = Float(i)/31
        let d = val - mean
        varc += d*d*c
    }
    return varc/total
}

// 채도 표준편차
func computeSatStdDev(from img: CIImage, ctx: CIContext) -> Float {
    let satImg = img.applyingFilter("CIColorControls", parameters: ["inputSaturation": 2.0])
    let satF = CIFilter(name: "CIAreaHistogram", parameters: [
        kCIInputImageKey: satImg,
        "inputExtent": CIVector(cgRect: satImg.extent),
        "inputCount": 32,
        "inputScale": 1
    ])!
    guard let satImgOut = satF.outputImage else { return 0 }
    var satBuf = [Float](repeating: 0, count: 32*4)
    ctx.render(satImgOut,
               toBitmap: &satBuf,
               rowBytes: MemoryLayout<Float>.size*4*32,
               bounds: CGRect(x:0, y:0, width:32, height:1),
               format: .RGBAf,
               colorSpace: nil)
    let counts = (0..<32).map { satBuf[$0*4] }
    let total = counts.reduce(0,+)
    guard total > 0 else { return 0 }
    var mean: Float = 0
    for (i,c) in counts.enumerated() { mean += Float(i)/31 * c }
    mean /= total
    var varc: Float = 0
    for (i,c) in counts.enumerated() {
        let val = Float(i)/31
        let d = val - mean
        varc += d*d*c
    }
    return sqrt(varc/total)
}

// 특정 임계값 이상/이하 비율
func ratio(ci: CIImage, ctx: CIContext, th: Float, above: Bool) -> Float {
    let t = CGFloat(th)
    let minV = CIVector(x: above ? t : 0, y: above ? t : 0, z: above ? t : 0, w: 1)
    let maxV = CIVector(x: above ? 1 : t, y: above ? 1 : t, z: above ? 1 : t, w: 1)
    let clamp = ci.applyingFilter("CIColorClamp", parameters: [
        "inputMinComponents": minV,
        "inputMaxComponents": maxV
    ])
    let hf = CIFilter(name: "CIAreaHistogram", parameters: [
        kCIInputImageKey: clamp,
        "inputExtent": CIVector(cgRect: clamp.extent),
        "inputCount": 2,
        "inputScale": 1
    ])!
    guard let hImg = hf.outputImage else { return 0 }
    var buf = [Float](repeating: 0, count: 2*4)
    ctx.render(hImg,
               toBitmap: &buf,
               rowBytes: MemoryLayout<Float>.size*4*2,
               bounds: CGRect(x:0, y:0, width:2, height:1),
               format: .RGBAf,
               colorSpace: nil)
    let counts = (0..<2).map { buf[$0*4] }
    guard let last = counts.last else { return 0 }
    let pixelCount = Float(ci.extent.width * ci.extent.height)
    return last / pixelCount
}

// RGB → Hue 변환
func convertToHSV(ci: CIImage) -> CIImage? {
    let kernelString = """
    kernel vec4 rgbToHue(__sample s) {
        float r = s.r, g = s.g, b = s.b;
        float maxC = max(r, max(g, b));
        float minC = min(r, min(g, b));
        float delta = maxC - minC;

        float hue = 0.0;
        if (delta > 0.0) {
            if (maxC == r) {
                hue = mod((g - b) / delta, 6.0);
            } else if (maxC == g) {
                hue = ((b - r) / delta) + 2.0;
            } else {
                hue = ((r - g) / delta) + 4.0;
            }
            hue /= 6.0;
            if (hue < 0.0) { hue += 1.0; }
        }
        return vec4(hue, 0.0, 0.0, 1.0);
    }
    """
    guard let kernel = try? CIColorKernel(source: kernelString) else { return nil }
    return kernel.apply(extent: ci.extent, arguments: [ci])
}

// Hue 통계치 (평균/분산)
func computeHueStats(from img: CIImage, ctx: CIContext, binCount: Int = 36) -> (Float, Float) {
    let histF = CIFilter(name: "CIAreaHistogram", parameters: [
        kCIInputImageKey: img,
        "inputExtent": CIVector(cgRect: img.extent),
        "inputCount": binCount,
        "inputScale": 1
    ])!
    guard let histImg = histF.outputImage else { return (0,0) }
    var buf = [Float](repeating: 0, count: binCount*4)
    ctx.render(histImg,
               toBitmap: &buf,
               rowBytes: MemoryLayout<Float>.size*4*binCount,
               bounds: CGRect(x:0, y:0, width:binCount, height:1),
               format: .RGBAf,
               colorSpace: nil)
    let counts = (0..<binCount).map { buf[$0*4] }
    let total = counts.reduce(0,+)
    guard total > 0 else { return (0,0) }

    var meanHue: Float = 0
    for (i,c) in counts.enumerated() { meanHue += Float(i)/Float(binCount) * c }
    meanHue /= total
    var variance: Float = 0
    for (i,c) in counts.enumerated() {
        let h = Float(i)/Float(binCount)
        let d = h - meanHue
        variance += d*d*c
    }
    variance /= total
    return (meanHue, variance)
}

final class GrainModels {
    static let shared = GrainModels()

    let alphaModel: GrainAlphaRegressor
    let scaleModel: GrainScaleRegressor
    let contrastModel: ContrastRegressor
    let temperatureModel: TemperatureRegressor
    let thresholdModel: ThresholdRegressor
    let brightAlphaModel: BrightAlphaRegressor
    let darkAlphaModel: DarkAlphaRegressor

    private init() {
        alphaModel      = try! GrainAlphaRegressor(configuration: .init())
        scaleModel      = try! GrainScaleRegressor(configuration: .init())
        contrastModel   = try! ContrastRegressor(configuration: .init())
        temperatureModel = try! TemperatureRegressor(configuration: .init())
        thresholdModel   = try! ThresholdRegressor(configuration: .init())
        brightAlphaModel = try! BrightAlphaRegressor(configuration: .init())
        darkAlphaModel   = try! DarkAlphaRegressor(configuration: .init())
    }
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
