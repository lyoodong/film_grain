import SwiftUI
import Photos
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import GameplayKit
import SpriteKit

// MARK: - ViewModel ---------------------------------------------------------
extension EditingViewModel: ViewModelType {
    struct State {
        var grainAlpha: Double = 0.6
        var grainScale: Double = 1
        
        var originData: Data = Data() // 원본 이미지 데이터
        var originImage: UIImage?
        var displayImage: UIImage?
        
        var maxDimension: CGFloat = 0
        var noise: CIImage?
    }
    
    enum Action {
        case photoSelected(PhotosPickerItem)
        
        case saveButtonTapped
        
        case grainAlphaChanged(Float)
        case grainScaleChanged(Float)
        
        case previewWidthUpdated(CGFloat)
    }
}

final class EditingViewModel: toVM<EditingViewModel> {
    private lazy var context: CIContext = {
        if let dev = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: dev)
        }
        return CIContext(options: nil)
    }()
    
    override func reduce(state: inout State, action: Action) {
        
        let refresh: () -> Void = { [weak self] in
            guard let self else { return }
            let state = self.state
            guard let base = state.originImage else { return }
            
            Task.detached(priority: .userInitiated) {
                let out = self.applyGrain(
                    noise: state.noise,
                    base: base,
                    alpha: state.grainAlpha,
                    grainScale: state.grainScale,
                    maxDimension: state.maxDimension
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
                    maxDimension: state.maxDimension
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
                refresh()
            }
            
        case .grainScaleChanged(let v):
            let rounded = (Double(v) * 100).rounded() / 100
            if state.grainScale != rounded {
                state.grainScale = CGFloat(rounded)
                refresh()
            }
            
        case .saveButtonTapped:
            if let img = state.displayImage {
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            }
            
        case .previewWidthUpdated(let w):
            state.maxDimension = w
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
