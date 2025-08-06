import SwiftUI
import Photos
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import GameplayKit
import SpriteKit
import Vision

extension EditViewModel: ViewModelType {
    struct State {
        // Grain
        var grainAlpha: Double = 0.6
        var grainScale: Double = 1
        
        // Contrast
        var contrast: Double = 1
        var contrastValue: Double = 0
        
        // ColorGrading
        var isColorGrading = false
        var brightAlpha: Double = 0
        var darkAlpha: Double = 0
        var threshold: Double = 0.5
        
        // Image
        var originData: Data = Data()
        var originImage: UIImage?
        var displayImage: UIImage?
        var selectedItem: PhotosPickerItem?
        
        // etc
        var maxScale: CGFloat = 0
        var noise: CIImage?
    }
    
    enum Action {
        case onAppear(CGFloat)
        
        case photoSelected(PhotosPickerItem)
        
        case saveButtonTapped
        case aiButtonTapped
        
        case grainAlphaChanged(Double)
        case grainScaleChanged(Double)
        
        case contrastChanged(Double)
        
        case isOnColorGrading(Bool)
        case brightAlphaChanged(Double)
        case darkAlphaChanged(Double)
        case thresholdChanged(Double)
    }
}

final class EditViewModel: toVM<EditViewModel> {
    private lazy var context: CIContext = {
        if let dev = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: dev)
        }
        return CIContext(options: nil)
    }()
    
    override func reduce(state: inout State, action: Action) {
        
        let refresh: (_ state: State) -> Void = { [weak self] state in
            guard let self else { return }
            guard var base = state.originImage else { return }
        
            if state.isColorGrading {
                base = applyColorGrading(image: base, tealAlpha: state.darkAlpha, orangeAlpha: state.brightAlpha, threshold: state.threshold)!
            }
            
            Task.detached(priority: .userInitiated) {
                let out = self.applyGrain(
                    noise: state.noise,
                    base: base,
                    alpha: state.grainAlpha,
                    grainScale: state.grainScale,
                    maxDimension: state.maxScale
                )
                
                await self.update { $0.displayImage = out }
            }
        }
        
        switch action {
        case .photoSelected(let item):
            let state = self.state
            
            Task.detached(priority:.userInitiated) { [weak self] in
                guard let self else { return }
                
                guard let data = await item.toData() else { return }
                await self.update { $0.originData = data }
                
                guard let image = downsample(
                    data: data,
                    maxDimension: state.maxScale
                ) else {
                    return
                }
                
                
                //MARK: - CHANGE
                await self.update { $0.noise = NoiseFactory.shared.perlinNoise(size: image.size) }
                await self.update { $0.displayImage = image }
                await self.update { $0.originImage = image }
            }
            
        case .grainAlphaChanged(let v):
            let rounded = (Double(v) * 100).rounded() / 100
            if state.grainAlpha != rounded {
                state.grainAlpha = rounded
                refresh(state)
            }
            
        case .brightAlphaChanged(let v):
            let rounded = (Double(v) * 100).rounded() / 100
            if state.brightAlpha != rounded {
                state.brightAlpha = rounded
                refresh(state)
            }
            
        case .darkAlphaChanged(let v):
            let rounded = (Double(v) * 100).rounded() / 100
            if state.darkAlpha != rounded {
                state.darkAlpha = rounded
                refresh(state)
            }
            
        case .grainScaleChanged(let v):
            let rounded = (Double(v) * 100).rounded() / 100
            if state.grainScale != rounded {
                state.grainScale = CGFloat(rounded)
                refresh(state)
            }
            
        case .contrastChanged(let v):
            state.contrast = pow(2, Double(v) / 50)
            state.contrastValue = Double(v)
            refresh(state)
            
        case .thresholdChanged(let v):
            state.threshold = v
            refresh(state)
            
        case .isOnColorGrading(let isOn):
            state.isColorGrading = isOn
            refresh(state)
            
        case .saveButtonTapped:
            if let img = state.displayImage {
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            }
            
        case .aiButtonTapped:
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                var state = self.state
                if let base = state.originImage {
                    guard let rec  = self.predictPreset(for: base) else { return }
                    
                    await self.update {
                        $0.grainAlpha = rec.alpha
                        $0.grainScale = rec.scale
                        $0.contrast   = pow(2, Double(rec.contrast) / 50)
                        $0.contrastValue = rec.contrast
                        refresh($0)
                    }
                }
            }
            
        case .onAppear(let w):
            state.maxScale = w
        }
    }
    
    private func downsample(data: Data, maxDimension: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary // 캐싱 적용 여부
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    private func applyGrain(
        noise: CIImage?,
        base: UIImage,
        alpha: Double,
        grainScale: CGFloat,
        maxDimension: CGFloat
    ) -> UIImage? {
        guard let noise,
              let baseCI = CIImage(image: base) else { return nil }
        
        let grayF = CIFilter.minimumComponent()
        grayF.inputImage = noise
        
        let alphaF = CIFilter.colorMatrix()
        alphaF.inputImage = grayF.outputImage
        alphaF.aVector = CIVector(x: 0, y: 0, z: 0, w: alpha)
        
        let scaleF = CIFilter.pixellate()
        let pixelSize = max(1, baseCI.extent.width / maxDimension)
        scaleF.inputImage = alphaF.outputImage
        scaleF.center = .init(x: baseCI.extent.midX, y: baseCI.extent.midY)
        scaleF.scale = Float(pixelSize * grainScale)
        
        let blend = CIFilter.softLightBlendMode()
        blend.inputImage = scaleF.outputImage
        blend.backgroundImage = baseCI
        
        guard let out = blend.outputImage,
              let cg = context.createCGImage(out, from: baseCI.extent) else { return nil }
        
        return UIImage(cgImage: cg)
    }
    
    // ── 기존 ContrastPreset 에서는 색상만 보관 ─────────────────
    struct ContrastPreset {
        let name: String
        let threshold: CGFloat
        let darkBase: CIColor    // Teal 계열 R/G/B 값만
        let brightBase: CIColor  // Orange 계열 R/G/B 값만
    }

    let presets = ContrastPreset(
        name:       "Teal ↔︎ Orange 기본",
        threshold:  0.1,
        darkBase:   CIColor(red: 0.0, green: 0.8, blue: 0.7, alpha: 1.0),
        brightBase: CIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    )

    // ── colorGradingKernel 은 그대로 재사용 ─────────────────
    private static let colorGradingKernel: CIColorKernel = {
        let src = """
        kernel vec4 contrastOverlay(__sample img, float threshold,
                                    __color darkC, __color brightC) {
            float l = dot(img.rgb, vec3(0.299,0.587,0.114));
            return (l < threshold) ? darkC : brightC;
        }
        """
        return CIColorKernel(source: src)!
    }()

    // ── 알파 값을 파라미터로 받아 적용 ─────────────────────────
    private func applyColorGrading(
        image: UIImage,
        tealAlpha:   CGFloat,
        orangeAlpha: CGFloat,
        threshold: Double
    ) -> UIImage? {
        guard let ciIn = CIImage(image: image) else { return nil }

        // presets.darkBase.rgb + tealAlpha
        let darkColor = CIColor(
          red:   presets.darkBase.red,
          green: presets.darkBase.green,
          blue:  presets.darkBase.blue,
          alpha: tealAlpha
        )

        // presets.brightBase.rgb + orangeAlpha
        let brightColor = CIColor(
          red:   presets.brightBase.red,
          green: presets.brightBase.green,
          blue:  presets.brightBase.blue,
          alpha: orangeAlpha
        )

        // 커널 적용
        guard let overlay = Self.colorGradingKernel.apply(
          extent:   ciIn.extent,
          arguments: [ciIn,
                      threshold,
                      darkColor,
                      brightColor]
        ) else { return nil }

        // 원본 위에 오버레이
        let comp = overlay.composited(over: ciIn)
        guard let cg = context.createCGImage(comp, from: comp.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

final class NoiseFactory {
    static let shared = NoiseFactory()
    private init() {}
    
    func perlinNoise(size: CGSize, colored: Bool = false) -> CIImage? {
        let w = Int(size.width)
        let h = Int(size.height)
        
        func gray(seed: Int32) -> CIImage? {
            let perlin = GKPerlinNoiseSource(
                frequency:   128,
                octaveCount: 6,
                persistence: 0.5,
                lacunarity:  2.0,
                seed: 1
            )
            
            let noise   = GKNoise(perlin)
            
            let map = GKNoiseMap(
                noise,
                size:        vector_double2(Double(w), Double(h)),
                origin:      .zero,
                sampleCount: vector_int2(Int32(w), Int32(h)),
                seamless:    true
            )
            
            let cgNoise = SKTexture(noiseMap: map).cgImage()
            return CIImage(cgImage: cgNoise)
        }
        
        guard let base = gray(seed: Int32.random(in: .min ... .max)) else { return nil }
        return base
    }
}

private final class GrainCache {
    static let shared = GrainCache()
    private let cache = NSCache<NSString, CIImage>()
    
    func key(_ name: String) -> NSString {
        return name as NSString
    }
    
    func get(_ name: String) -> CIImage? {
        return cache.object(forKey: key(name))
    }
    
    func set(_ name: String, ci: CIImage) {
        return cache.setObject(ci, forKey: key(name))
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

import SwiftUI
import CoreML

extension EditViewModel {
  /// ML 예측 호출 (Float → Double 변환 주의)
  private func predictPreset(for uiImage: UIImage) -> (alpha: Double, scale: Double, contrast: Double)? {
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

