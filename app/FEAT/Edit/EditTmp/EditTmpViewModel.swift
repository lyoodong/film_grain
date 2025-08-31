import SwiftUI
import Photos
import PhotosUI

extension EditTmpViewModel: ViewModelType {
    struct State {
        var image: UIImage
        var displayImage: UIImage?
        
        var selectedTap: ToolType? = nil
        
        var isAIAnalyzing: Bool = false
        var hadAIbuttonTextAnimated: Bool = false
        
        func toolButtonTextColor(_ type: ToolType) -> Color {
            return type == selectedTap ? .mainWhite : .sheeTextGray
        }
        
        var initialEditSheetHeight: CGFloat = 0.0
        var movedEditSheetHeight: CGFloat = 0.0
        
        var filter: Filter = .init()
        var colorGradingItems = ColorGradingItems.preset()
        var selectedIndex: Int?
        var isHiddenColorSlider: Bool = true
    }
    
    enum Action {
        //View LifeCycle
        case onAppear
        case onTextAnimationEnded
        
        //load Image
        case dataLoaded(Data)
        case imageLoaded(UIImage?)
        case filteredImageLoaded(UIImage?)
        
        case tapSelected(ToolType?)
        case dragToolOnChanged(CGFloat)
        case dragToolOnEnded(CGFloat)
        
        case grainAlphaChanged(Double)
        case grainScaleChanged(Double)
        
        case contrastChanged(Double)
        case tempertureChanged(Double)
        
        case thresholdChanged(Double)
        case brightColorAlphaChanged(Double)
        case darkColorAlphaChanged(Double)
        
        case aiAnalyzeCompleted((alpha: Double, scale: Double, contrast: Double)?)
        
        case noneButtonTapped
        case colorButtonTapped(Int)
        case customButtonTapped
        case aiButtonTapped
        
        case saveButtonTapped
        
        case initialEditSheetHeightChnaged(CGFloat)
    }
}

final class EditTmpViewModel: toVM<EditTmpViewModel> {
    
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            state.displayImage = state.image
            state.filter.grainCI = state.filter.createGrainFilter(size: state.image.size)
            state.filter.baseCI = CIImage(image: state.image)
            
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                effect(.onTextAnimationEnded)
            }
            
        case .onTextAnimationEnded:
            state.hadAIbuttonTextAnimated = true
            
        case .dataLoaded(let data):
            print("dataLoaded")
        
            
        case .imageLoaded(let image):
            print("imageLoaded")
            
        case .filteredImageLoaded(let image):
            state.displayImage = image

        case .tapSelected(let type):
            if let type = type {
                state.selectedTap = type
            }
            
        case .initialEditSheetHeightChnaged(let height):
            state.initialEditSheetHeight = height
            state.movedEditSheetHeight = height
            
        case .dragToolOnChanged(let moved):
            if moved > 60 {
                state.selectedTap = nil
            }
            
            
        case .dragToolOnEnded(let moved):
            if moved > 60 {
                state.selectedTap = nil
            }
            
        case .grainAlphaChanged(let value):
            state.filter.grainAlpha = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .grainScaleChanged(let value):
            state.filter.grainScale = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .contrastChanged(let value):
            state.filter.contrast = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .tempertureChanged(let value):
            state.filter.temperture = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .thresholdChanged(let value):
            state.filter.threshold = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .brightColorAlphaChanged(let value):
            state.filter.brightAlpha = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
        case .darkColorAlphaChanged(let value):
            state.filter.darkAlpha = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .noneButtonTapped:
            state.selectedIndex = nil
            state.isHiddenColorSlider = true
            state.filter.brightColor = .clear
            state.filter.darkColor = .clear
            
            let filter = state.filter
            
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .colorButtonTapped(let index):
            state.selectedIndex = index
            state.filter.brightColor = state.colorGradingItems[index].bright
            state.filter.darkColor = state.colorGradingItems[index].dark
            state.isHiddenColorSlider = false
            
        case .customButtonTapped:
            state.selectedIndex = nil
            state.isHiddenColorSlider = true
            
        case .aiButtonTapped:
            state.isAIAnalyzing = true
            let image = state.image
            
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let res = predictPreset(for: image)
                try await Task.sleep(for: .seconds(0.8))
                effect(.aiAnalyzeCompleted(res))
            }
            
        case .aiAnalyzeCompleted(let res):
            if let res = res {
                state.filter.grainAlpha = res.alpha
                state.filter.grainScale = res.scale
                state.isAIAnalyzing = false
                
                let filter = state.filter
                Task.detached(priority: .userInitiated) { [weak self] in
                    guard let self else { return }
                    let iamge = filter.refresh()
                    effect(.filteredImageLoaded(iamge))
                }
            }

        case .saveButtonTapped:
            if let image = state.displayImage {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
    
    private func downsample(data: Data) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: UIScreen.targetPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
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
