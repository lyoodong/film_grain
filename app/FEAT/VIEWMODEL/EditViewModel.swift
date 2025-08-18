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
        
        //Temperature
        var temperature: Double = 6500
        
        // Image
        var originData: Data = Data()
        var originImage: UIImage?
        var displayImage: UIImage?
        var selectedItem: PhotosPickerItem?
        
        // etc
        var maxScale: CGFloat = 0
        var grain: CIImage?
        var filter: Filter = .init()
    }
    
    enum Action {
        case onAppear(CGFloat)
        
        case photoSelected(PhotosPickerItem)
        
        case saveButtonTapped
        case aiButtonTapped
        
        case grainAlphaChanged(Double)
        case grainScaleChanged(Double)
        
        case contrastChanged(Double)
        
        case temperatureChanged(Double)
        
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
            
            //MARK: -TMP
            guard var base = state.originImage else { return }
            guard let ciIn = CIImage(image: base) else { return }
            
            guard let tmpF = state.filter.applyTemperture(ciIn, temperature: state.temperature) else { return }
            
            if state.isColorGrading {
                guard let ciout = state.filter.applyColorGrading(
                    tmpF,
                    darkAlpha: state.darkAlpha,
                    bringtAlpha: state.brightAlpha,
                    threshold: state.threshold
                ) else { return }
                
                guard let cg = state.filter.context.createCGImage(ciout, from: ciout.extent)
                else { return }
                
                base =  UIImage(cgImage: cg)
            } else {
                guard let cg = state.filter.context.createCGImage(tmpF, from: tmpF.extent)
                else { return }
                
                base =  UIImage(cgImage: cg)
            }
            
            //MARK: -TMP

            Task.detached(priority: .userInitiated) {
                let out = self.applyFilter(
                    grain: state.grain,
                    base: base,
                    filter: state.filter,
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
                
                guard let image = downsample(
                    data: data,
                    maxDimension: state.maxScale
                ) else {
                    return
                }
                
                let grain = self.state.filter.applyGrain(size: image.size)
                
                await self.update { $0.originData = data }
                await self.update { $0.grain = grain }
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
            
        case .temperatureChanged(let v):
            //TODO: 원본에 대한 색감 분석이 필요
            state.temperature = v
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

    private func applyFilter(
        grain: CIImage?,
        base: UIImage,
        filter: Filter,
        alpha: Double,
        grainScale: CGFloat,
        maxDimension: CGFloat
    ) -> UIImage? {
        guard let baseCI = CIImage(image: base) else { return nil }
        
        let alphaF = filter.applyAlpha(grain, alpha: alpha)
        let scaleF = filter.applyScale(alphaF, scale: grainScale, maxScale: maxDimension)
        let blend = filter.blend(input: scaleF, background: baseCI)
        
        guard let out = blend,
              let cg = filter.context.createCGImage(out, from: baseCI.extent) else { return nil }
        
        return UIImage(cgImage: cg)
    }
}
