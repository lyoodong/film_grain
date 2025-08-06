import SwiftUI
import CoreImage
import GameplayKit
import SpriteKit

class Filter {
    private(set) var context = CIContext(options: [.cacheIntermediates: true])
    
    func applyGrain(size: CGSize) -> CIImage? {
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
    
    func applyAlpha(_ input: CIImage?, alpha: Double) -> CIImage? {
        let alphaF = CIFilter.colorMatrix()
        alphaF.inputImage = input
        alphaF.aVector = CIVector(x: 0, y: 0, z: 0, w: alpha)
        
        return alphaF.outputImage
    }
    
    func applyScale(_ input: CIImage?, scale: CGFloat, maxScale: CGFloat) -> CIImage? {
        guard let input = input else { return nil }
        
        let pixelSize   = max(1, input.extent.width / maxScale)
        let scaleValue  = Float(pixelSize * scale)
        let centerPoint = CGPoint(x: input.extent.midX, y: input.extent.midY)
        
        let scaleF = CIFilter.pixellate()
        scaleF.inputImage = input
        scaleF.scale      = scaleValue
        scaleF.center     = centerPoint
        
        return scaleF.outputImage
    }
    
    
    func blend(input: CIImage?, background: CIImage?) -> CIImage? {
        let blend = CIFilter.softLightBlendMode()
        blend.inputImage = input
        blend.backgroundImage = background
        
        return blend.outputImage
    }
}
