import SwiftUI
import Photos
import PhotosUI
import CoreML

extension EditViewModel: ViewModelType {
    struct State {
        var imageAsset: ImageAsset
        var displayImage: UIImage?
        var selectedTap: ToolType = .none
        var toast: Toast = .init()
        var filter: Filter = .init()
    }
    
    enum Action {
        case onAppear
        
        // Image
        case filteredImageLoaded(UIImage?)
        case originCILoaded(CIImage?)
        case savedImageLoaded(UIImage?)
        
        // Grain
        case grainAlphaChanged(Double)
        case grainAlphaEnded(Double)
        
        case grainScaleChanged(Double)
        case grainScaleEnded(Double)
        
        // Adjust
        case contrastChanged(Double)
        case contrastEnded(Double)
        case tempertureChanged(Double)
        case tempertureEnded(Double)
        
        // Tone
        case thresholdChanged(Double)
        case thresholdEnded(Double)
        case brightColorAlphaChanged(Double)
        case brightColorAlphaEnded(Double)
        case darkColorAlphaChanged(Double)
        case darkColorAlphaEnded(Double)
        case highlightToggle(Bool)
        case shadowToggle(Bool)
        case highlightColorButtonTapped(Color)
        case shadowColorButtonTapped(Color)
        
        // AI
        case aiAnalyzeCompleted(FredictedFeature?)
        
        // Status
        case undoButtonTapped
        case redoButtonTapped
        
        // ETC
        case tapSelected(ToolType)
        case saveButtonTapped
        case dismissToast
    }
}

final class EditViewModel: toVM<EditViewModel> {
    
    private var throttler = Throttler(for: 0.06)
    
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            let downsampledImage = state.imageAsset.downsampledImage
            state.displayImage = downsampledImage
            
            let size = downsampledImage.size
            state.filter.grainCI = state.filter.createGrainFilter(size: size)
            
            state.filter.baseCI = CIImage(image: downsampledImage)
            
        case .filteredImageLoaded(let image):
            state.displayImage = image

        case .tapSelected(let type):
            let canceled = (state.selectedTap == type && type != .none)
            state.selectedTap = canceled ? .none : type

            switch type {
            case .grain:
                state.filter.param.isGrainMute = canceled
            case .tone:
                state.filter.param.isToneMute = canceled
            case .adjust:
                state.filter.param.isAdjustMute = canceled
            case .ai:
                let downsampledImage = state.imageAsset.downsampledImage
                
                Task {
                    let res = predictPreset(for: downsampledImage)
                    try await Task.sleep(for: .seconds(0.8))
                    effect(.aiAnalyzeCompleted(res))
                }
            default:
                break
            }
            
            throttleRefresh(state.filter)

        case .grainAlphaChanged(let value):
            state.filter.param.grainAlpha = value
            throttleRefresh(state.filter)
            
        case .grainAlphaEnded(let value):
            state.filter.param.grainAlpha = value
            state.filter.pushDeque()
            
        case .grainScaleChanged(let value):
            state.filter.param.grainScale = value
            throttleRefresh(state.filter)
            
        case .grainScaleEnded(let value):
            state.filter.param.grainScale = value
            state.filter.pushDeque()
            
        case .contrastChanged(let value):
            state.filter.param.contrast = value
            throttleRefresh(state.filter)
            
        case .contrastEnded(let value):
            state.filter.param.contrast = value
            state.filter.pushDeque()
            
        case .tempertureChanged(let value):
            state.filter.param.temperture = value
            throttleRefresh(state.filter)
            
        case .tempertureEnded(let value):
            state.filter.param.temperture = value
            state.filter.pushDeque()
            
        case .thresholdChanged(let value):
            state.filter.param.isThresholdChanging = true
            state.filter.param.threshold = value
            throttleRefresh(state.filter)
            
        case .thresholdEnded(let value):
            state.filter.param.isThresholdChanging = false
            state.filter.param.threshold = value
            state.filter.pushDeque()
            throttleRefresh(state.filter)
            
        case .brightColorAlphaChanged(let value):
            state.filter.param.brightAlpha = value
            throttleRefresh(state.filter)
            
        case .brightColorAlphaEnded(let value):
            state.filter.param.brightAlpha = value
            state.filter.pushDeque()
            
        case .darkColorAlphaChanged(let value):
            state.filter.param.darkAlpha = value
            throttleRefresh(state.filter)
            
        case .darkColorAlphaEnded(let value):
            state.filter.param.darkAlpha = value
            state.filter.pushDeque()
            
        case .aiAnalyzeCompleted(let fredictedFeature):
            if let f = fredictedFeature {
                state.filter.param.grainAlpha = f.grainAlpha
                state.filter.param.grainScale = f.grainscale
                state.filter.param.contrast = f.contrast
                state.filter.param.temperture = f.temperature
                state.filter.param.threshold = f.threshold
                if f.darkAlpha != 0 {
                    state.filter.param.darkAlpha = f.darkAlpha
                    state.filter.param.isOndarkColor = true
                }
                
                if f.brightAlpha != 0 {
                    state.filter.param.brightAlpha = f.brightAlpha
                    state.filter.param.isOnBrightColor = true
                }
                
                if f.darkAlpha != 0 && f.brightAlpha != 0 {
                    state.filter.param.threshold = f.threshold
                }
                
                state.toast.show("AI Completed")
                state.filter.pushDeque()
                throttleRefresh(state.filter)
                dismissToast()
            }

        case .saveButtonTapped:
            loadOriginCIIImage(data: state.imageAsset.originData)

        case .originCILoaded(let originCI):
            guard let originCI else { return }
            state.filter.originCI = originCI
            state.filter.ratio = originCI.extent.size.width / state.imageAsset.downsampledImage.size.width
        
            loadSavedImage(filter: state.filter)
        
        case .savedImageLoaded(let image):
            guard let image else { return }
            UIImageWriteToSavedPhotosAlbum(image.withoutAlpha(), nil, nil, nil)
            state.toast.show("Save Completed")
            dismissToast()
    
        case .dismissToast:
            state.toast.clear()
            
        case .highlightToggle(let isOn):
            state.filter.param.isOnBrightColor = isOn
            state.filter.param.isToneMute = !state.filter.param.isOnBrightColor && !state.filter.param.isOndarkColor
            throttleRefresh(state.filter)
            
        case .shadowToggle(let isOn):
            state.filter.param.isOndarkColor = isOn
            state.filter.param.isToneMute = !state.filter.param.isOnBrightColor && !state.filter.param.isOndarkColor
            throttleRefresh(state.filter)
            
        case .highlightColorButtonTapped(let color):
            state.filter.param.brightColor = color
            state.filter.pushDeque()
            throttleRefresh(state.filter)
            
        case .shadowColorButtonTapped(let color):
            state.filter.param.darkColor = color
            state.filter.pushDeque()
            throttleRefresh(state.filter)
            
        case .undoButtonTapped:
            state.filter.undo()
            state.filter.param = state.filter.currentParam()
            throttleRefresh(state.filter)
            
        case .redoButtonTapped:
            state.filter.redo()
            state.filter.param = state.filter.currentParam()
            throttleRefresh(state.filter)
        }
    }
    
    private func dismissToast() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            effect(.dismissToast)
        }
    }
    
    private func throttleRefresh(_ filter: Filter) {
        throttler { [weak self] in
            guard let self else { return }
            let image = filter.refresh()
            self.effect(.filteredImageLoaded(image))
        }
    }
    
    private func saveImage(image: UIImage) {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let _ = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
    
    
    private func loadData(id: String) async -> Data? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = assets.firstObject else { return nil }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, uti, orientation, info in
                continuation.resume(returning: data)
            }
        }
    }
    
    private func loadOriginCIIImage(data: Data) {
        Task {
            let originCI = CIImage(data: data, options: [.applyOrientationProperty: true])
            effect(.originCILoaded(originCI))
        }
    }
    
    private func loadSavedImage(filter: Filter) {
        Task {
            let image = filter.save()
            effect(.savedImageLoaded(image))
        }
    }
    
    private func predictPreset(for uiImage: UIImage) -> FredictedFeature? {
        guard let feats = analyzeFeatures(from: uiImage) else { return nil }

        // 공통 피처를 Double로 변환 (9차원)
        let avg   = Double(feats.avgLuma)
        let rms   = Double(feats.rmsContrast)
        let colv  = Double(feats.colorVar)
        let sat   = Double(feats.satStdDev)
        let high  = Double(feats.highlights)
        let shad  = Double(feats.shadows)
        let mid   = Double(feats.midtoneRatio)
        let hue   = Double(feats.meanHue)
        let hueV  = Double(feats.hueVariance)

        // ➊ grainAlpha 예측
        let alphaInput = GrainAlphaRegressorInput(
            avgLuma: avg,
            rmsContrast: rms,
            colorVar: colv,
            satStdDev: sat,
            highlights: high,
            shadows: shad,
            midtoneRatio: mid,
            meanHue: hue,
            hueVariance: hueV
        )
        guard let alphaOut = try? GrainModels.shared.alphaModel.prediction(input: alphaInput) else {
            return nil
        }

        // ➋ grainScale 예측
        let scaleInput = GrainScaleRegressorInput(
            avgLuma: avg,
            rmsContrast: rms,
            colorVar: colv,
            satStdDev: sat,
            highlights: high,
            shadows: shad,
            midtoneRatio: mid,
            meanHue: hue,
            hueVariance: hueV
        )
        guard let scaleOut = try? GrainModels.shared.scaleModel.prediction(input: scaleInput) else {
            return nil
        }

        // ➌ contrast 예측
        let contrastInput = ContrastRegressorInput(
            avgLuma: avg,
            rmsContrast: rms,
            colorVar: colv,
            satStdDev: sat,
            highlights: high,
            shadows: shad,
            midtoneRatio: mid,
            meanHue: hue,
            hueVariance: hueV
        )
        guard let contrastOut = try? GrainModels.shared.contrastModel.prediction(input: contrastInput) else {
            return nil
        }

        // ➍ temperature 예측
        let tempInput = TemperatureRegressorInput(
            avgLuma: avg,
            rmsContrast: rms,
            colorVar: colv,
            satStdDev: sat,
            highlights: high,
            shadows: shad,
            midtoneRatio: mid,
            meanHue: hue,
            hueVariance: hueV
        )
        guard let tempOut = try? GrainModels.shared.temperatureModel.prediction(input: tempInput) else {
            return nil
        }

        // ➎ threshold 예측
        let thInput = ThresholdRegressorInput(
            avgLuma: avg,
            rmsContrast: rms,
            colorVar: colv,
            satStdDev: sat,
            highlights: high,
            shadows: shad,
            midtoneRatio: mid,
            meanHue: hue,
            hueVariance: hueV
        )
        guard let thOut = try? GrainModels.shared.thresholdModel.prediction(input: thInput) else {
            return nil
        }

        // ➏ brightAlpha 예측
        let brightInput = BrightAlphaRegressorInput(
            avgLuma: avg,
            rmsContrast: rms,
            colorVar: colv,
            satStdDev: sat,
            highlights: high,
            shadows: shad,
            midtoneRatio: mid,
            meanHue: hue,
            hueVariance: hueV
        )
        guard let brightOut = try? GrainModels.shared.brightAlphaModel.prediction(input: brightInput) else {
            return nil
        }

        // ➐ darkAlpha 예측
        let darkInput = DarkAlphaRegressorInput(
            avgLuma: avg,
            rmsContrast: rms,
            colorVar: colv,
            satStdDev: sat,
            highlights: high,
            shadows: shad,
            midtoneRatio: mid,
            meanHue: hue,
            hueVariance: hueV
        )
        guard let darkOut = try? GrainModels.shared.darkAlphaModel.prediction(input: darkInput) else {
            return nil
        }

        return .init(
            grainAlpha: alphaOut.grainAlpha,
            grainscale: scaleOut.grainScale,
            contrast: contrastOut.contrast,
            temperature: tempOut.temperture,
            threshold: thOut.threshold,
            brightAlpha: brightOut.brightAlpha,
            darkAlpha: darkOut.darkAlpha
        )
    }
}
