import SwiftUI
import Photos
import PhotosUI

extension EditViewModel: ViewModelType {
    struct State {
        var image: UIImage
        var displayImage: UIImage?
        var selectedTap: ToolType = .none
        var toast: Toast = .init()
        var filter: Filter = .init()
    }
    
    enum Action {
        case onAppear
        
        // Image
        case filteredImageLoaded(UIImage?)
        
        // Grain
        case grainAlphaChanged(Double)
        case grainScaleChanged(Double)
        
        // Adjust
        case contrastChanged(Double)
        case tempertureChanged(Double)
        
        // Tone
        case thresholdChanged(Double)
        case brightColorAlphaChanged(Double)
        case darkColorAlphaChanged(Double)
        case highlightToggle(Bool)
        case shadowToggle(Bool)
        case highlightColorButtonTapped(Color)
        case shadowColorButtonTapped(Color)
        
        // AI
        case aiButtonTapped
        case aiAnalyzeCompleted((alpha: Double, scale: Double, contrast: Double)?)
        
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
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            let originImage = state.image
            state.displayImage = originImage
            
            let size = originImage.size
            state.filter.grainCI = state.filter.createGrainFilter(size: size)
            
            state.filter.baseCI = CIImage(image: state.image)
            
        case .filteredImageLoaded(let image):
            state.displayImage = image

        case .tapSelected(let type):
            let canceled = (state.selectedTap == type && type != .none)
            state.selectedTap = canceled ? .none : type

            switch type {
            case .grain:
                state.filter.isGrainMute = canceled
            case .tone:
                state.filter.isToneMute = canceled
            case .adjust:
                state.filter.isAdjustMute = canceled
            default:
                break
            }
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
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
            
        case .aiButtonTapped:
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
                state.toast.show("AI Completed")
                
                let filter = state.filter
                Task.detached(priority: .userInitiated) { [weak self] in
                    guard let self else { return }
                    let iamge = filter.refresh()
                    effect(.filteredImageLoaded(iamge))
                }
                
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    effect(.dismissToast)
                }
            }

        case .saveButtonTapped:
            if let image = state.displayImage {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
        case .dismissToast:
            state.toast.clear()
            
        case .highlightToggle(let isOn):
            state.filter.isOnBrightColor = isOn
            let filter = state.filter
            
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .shadowToggle(let isOn):
            state.filter.isOndarkColor = isOn
            let filter = state.filter
            
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .highlightColorButtonTapped(let color):
            state.filter.brightColor = color
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .shadowColorButtonTapped(let color):
            state.filter.darkColor = color
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .undoButtonTapped:
            print("undoButtonTapped")
            
        case .redoButtonTapped:
            print("redoButtonTapped")
            
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
