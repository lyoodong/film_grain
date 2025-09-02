import SwiftUI
import CoreImage
import GameplayKit
import SpriteKit
import Collections

struct FilterParam: Equatable {
    // Grain
    var grainAlpha: Double = 0.0
    var grainScale: Double = 1.0
    var isGrainMute: Bool = false

    // Adjust
    var contrast: Double = 1.0
    var temperture: Double = 6500.0
    var isAdjustMute: Bool = false

    // Tone
    var threshold: Double = 0.5
    var isOnBrightColor: Bool = false
    var brightColor: Color = .mainOrange
    var brightAlpha: Double = 0.5
    var isOndarkColor: Bool = false
    var darkColor: Color = .mainTeal
    var darkAlpha: Double = 0.5
    var isToneMute: Bool = false

    var isGrainChanged: Bool {
        let changed = grainAlpha != 0.0 || grainScale != 1.0
        return isGrainMute ? false : changed
    }
    var isAdjustChanged: Bool {
        let changed = contrast != 1.0 || temperture != 6500.0
        return isAdjustMute ? false : changed
    }
    var isToneChanged: Bool {
        let changed = threshold != 0.5 ||
        isOnBrightColor || brightColor != .mainOrange || brightAlpha != 0.5 ||
        isOndarkColor  || darkColor   != .mainTeal   || darkAlpha  != 0.5
        return isToneMute ? false : changed
    }

    static let `default` = FilterParam()
}


class Filter {
    private(set) var context = CIContext(options: [.cacheIntermediates: true])
    
    var baseCI: CIImage?
    var grainCI: CIImage?
    
    var param = FilterParam()
    var paramDeque: Deque<FilterParam> = [.init()]
    var index: Int = 0
    
    var disableUndo: Bool {
        return index < 1
    }
    
    var disableRedo: Bool {
        return  index >= paramDeque.count - 1
    }

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
    
    func refresh() -> UIImage? {
        guard let baseCI,
              let grainCI else { return nil }
        
        let brightColor = CIColor(param.brightColor)
        let darkColor = CIColor(param.darkColor)
        
        let colorCI = applyColorGrading(baseCI, threshold: param.threshold, brightColor: brightColor, brightAlpha: param.brightAlpha, darkColor: darkColor, darkAlpha: param.darkAlpha)
        let contrastCI = applyContrast(colorCI, contrast: param.contrast)
        let tempertureCI = applyTemperture(contrastCI, temperature: param.temperture)
        let baseAdjustedCI = tempertureCI
        
        let grainAlphaCI = applyGrainAlpha(grainCI, alpha: param.grainAlpha)
        let grainScaleCI = applyGrainScale(grainAlphaCI, scale: param.grainScale)
        let grainAdjustedCI = grainScaleCI
        
        let blendCI = blend(input: grainAdjustedCI, background: baseAdjustedCI)
        
        guard let out = blendCI,
              let cg = context.createCGImage(out, from: baseCI.extent) else { return nil }
        
        return UIImage(cgImage: cg)
    }
    
    func pushDeque() {
        if index != paramDeque.count - 1 {
            paramDeque.removeSubrange((index + 1)..<paramDeque.count)
        }
        
        if let last =  paramDeque.last {
            if last != param {
                paramDeque.append(param)
                index = paramDeque.count - 1
            }
        }
    }
    
    func undo() {
        
        guard index > 0 else { return }
        index -= 1
    }
    
    func redo() {
        guard index < paramDeque.count - 1 else { return }
        index += 1
    }
    
    func currentParam() -> FilterParam {
        return paramDeque[index]
    }
    
    private func applyGrainAlpha(
        _ input: CIImage?,
        alpha: Double
    ) -> CIImage? {
        let alphaF = CIFilter.colorMatrix()
        alphaF.inputImage = input
        alphaF.aVector = CIVector(x: 0, y: 0, z: 0, w: param.isGrainMute ? 0 : alpha)
        
        return alphaF.outputImage
    }
    
    private func applyGrainScale(
        _ input: CIImage?,
        scale: CGFloat,
        maxScale: CGFloat = 0
    ) -> CIImage? {
        guard let input = input else { return nil }
        
        let scaleValue  = Float(scale)
        let centerPoint = CGPoint(x: input.extent.midX, y: input.extent.midY)
        
        let scaleF = CIFilter.pixellate()
        scaleF.inputImage = input
        scaleF.scale      = scaleValue
        scaleF.center     = centerPoint
        
        return scaleF.outputImage
    }
    
    private func applyColorGrading(
        _ input: CIImage?,
        threshold: CGFloat,
        brightColor b: CIColor,
        brightAlpha: CGFloat,
        darkColor d: CIColor,
        darkAlpha: CGFloat
    ) -> CIImage? {
        guard let input else { return nil }
        
        let brightAlpha: CGFloat = param.isOnBrightColor && !param.isToneMute ? brightAlpha : 0
        let darkAlpha: CGFloat = param.isOndarkColor && !param.isToneMute ? darkAlpha : 0
        
        let brightColor = CIColor(red: b.red, green: b.green, blue: b.blue, alpha: brightAlpha)
        let darkColor = CIColor(red: d.red, green: d.green, blue: d.blue, alpha: darkAlpha)
        
        guard let overlay = Self.colorGradingKernel.apply(
            extent: input.extent,
            arguments: [input, threshold, darkColor, brightColor]
        ) else { return nil }
        
        let comp = overlay.composited(over: input)
        return comp
    }
    
    private func applyContrast(
        _ input: CIImage?,
        contrast: Double
    ) -> CIImage? {
        guard let input = input else { return nil }
        
        let contrastF = CIFilter.colorControls()
        contrastF.inputImage = input
        contrastF.contrast = Float(param.isAdjustMute ? 1 : contrast)
        
        return contrastF.outputImage
    }
    
    private func applyTemperture(
        _ input: CIImage?,
        temperature: Double
    ) -> CIImage? {
        guard let input = input else { return nil }
        
        let tmpF = CIFilter.temperatureAndTint()
        tmpF.inputImage = input
        
        let orignTint = tmpF.neutral.y
        let tmp = param.isAdjustMute ? 6500 : temperature
        tmpF.neutral = CIVector(x: CGFloat(tmp), y: orignTint)
        
        return tmpF.outputImage
    }
    
    
    private func blend(
        input: CIImage?,
        background: CIImage?
    ) -> CIImage? {
        let blend = CIFilter.softLightBlendMode()
        blend.inputImage = input
        blend.backgroundImage = background
        
        return blend.outputImage
    }
}
