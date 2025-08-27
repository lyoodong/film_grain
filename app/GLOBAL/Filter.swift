import SwiftUI
import CoreImage
import GameplayKit
import SpriteKit

class Filter {
    private(set) var context = CIContext(options: [.cacheIntermediates: true])
    
    var baseCI: CIImage?
    var grainCI: CIImage?
    
    var grainAlpha: Double = 0
    var grainScale: Double = 1
    
    var contrast: Double = 1
    var temperture: Double = 6500
    
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
    
    func createGrainFilter(size: CGSize) -> CIImage? {
        let w = Int(size.width)
        let h = Int(size.height)
        
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
    
    func applyGrainAlpha(_ input: CIImage?, alpha: Double) -> CIImage? {
        let alphaF = CIFilter.colorMatrix()
        alphaF.inputImage = input
        alphaF.aVector = CIVector(x: 0, y: 0, z: 0, w: alpha)
        
        return alphaF.outputImage
    }
    
    func applyGrainScale(_ input: CIImage?, scale: CGFloat, maxScale: CGFloat = 0) -> CIImage? {
        guard let input = input else { return nil }
        
        let scaleValue  = Float(scale)
        let centerPoint = CGPoint(x: input.extent.midX, y: input.extent.midY)
        
        let scaleF = CIFilter.pixellate()
        scaleF.inputImage = input
        scaleF.scale      = scaleValue
        scaleF.center     = centerPoint
        
        return scaleF.outputImage
    }
    
    func applyColorGrading(_ input: CIImage?, darkAlpha: CGFloat, bringtAlpha: CGFloat, threshold: CGFloat) -> CIImage? {
        
        guard let input else { return nil }
       
        let darkColor = CIColor(red: 0.0, green: 0.8, blue: 0.7, alpha: darkAlpha)
        let brightColor = CIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: bringtAlpha)
        
        guard let overlay = Self.colorGradingKernel.apply(
          extent: input.extent,
          arguments: [input, threshold, darkColor, brightColor]
        ) else { return nil }

        let comp = overlay.composited(over: input)
        return comp
    }
    
    func applyContrast(_ input: CIImage?, contrast: Double) -> CIImage? {
        guard let input = input else { return nil }
        
        let contrastF = CIFilter.colorControls()
        contrastF.inputImage = input
        contrastF.contrast = Float(contrast)
        
        return contrastF.outputImage
    }
    
    func applyTemperture(_ input: CIImage?, temperature: Double) -> CIImage? {
        guard let input = input else { return nil }
    
        let tmpF = CIFilter.temperatureAndTint()
        tmpF.inputImage = input
        
        let orignTint = tmpF.neutral.y
        tmpF.neutral = CIVector(x: CGFloat(temperature), y: orignTint)
        
        return tmpF.outputImage
    }
    
    
    func blend(input: CIImage?, background: CIImage?) -> CIImage? {
        let blend = CIFilter.softLightBlendMode()
        blend.inputImage = input
        blend.backgroundImage = background
        
        return blend.outputImage
    }
    
    func refresh() -> UIImage? {
        guard let baseCI,
              let grainCI else { return nil }
        
        let contrastCI = applyContrast(baseCI, contrast: contrast)
        let tempertureCI = applyTemperture(contrastCI, temperature: temperture)
        let baseAdjustedCI = tempertureCI

        let grainAlphaCI = applyGrainAlpha(grainCI, alpha: grainAlpha)
        let grainScaleCI = applyGrainScale(grainAlphaCI, scale: grainScale)
        let grainAdjustedCI = grainScaleCI
        
        let blendCI = blend(input: grainAdjustedCI, background: baseAdjustedCI)
        
        guard let out = blendCI,
              let cg = context.createCGImage(out, from: baseCI.extent) else { return nil }
        
        return UIImage(cgImage: cg)
    }
}
