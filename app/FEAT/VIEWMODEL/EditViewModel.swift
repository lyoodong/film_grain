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
