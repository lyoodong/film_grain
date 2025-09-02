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
                state.filter.param.isGrainMute = canceled
            case .tone:
                state.filter.param.isToneMute = canceled
            case .adjust:
                state.filter.param.isAdjustMute = canceled
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
            state.filter.param.grainAlpha = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .grainAlphaEnded(let value):
            state.filter.param.grainAlpha = value
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
        case .grainScaleChanged(let value):
            state.filter.param.grainScale = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .grainScaleEnded(let value):
            state.filter.param.grainScale = value
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
        case .contrastChanged(let value):
            state.filter.param.contrast = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .contrastEnded(let value):
            state.filter.param.contrast = value
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
        case .tempertureChanged(let value):
            state.filter.param.temperture = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .tempertureEnded(let value):
            print("tempertureEnded")
            state.filter.param.temperture = value
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
        case .thresholdChanged(let value):
            state.filter.param.threshold = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .thresholdEnded(let value):
            print("thresholdEnded")
            state.filter.param.threshold = value
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
        case .brightColorAlphaChanged(let value):
            state.filter.param.brightAlpha = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .brightColorAlphaEnded(let value):
            print("brightColorAlphaEnded")
            state.filter.param.brightAlpha = value
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
        case .darkColorAlphaChanged(let value):
            state.filter.param.darkAlpha = value
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .darkColorAlphaEnded(let value):
            print("darkColorAlphaEnded")
            state.filter.param.darkAlpha = value
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
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
                state.filter.param.grainAlpha = res.alpha
                state.filter.param.grainScale = res.scale
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
            state.filter.param.isOnBrightColor = isOn
            let filter = state.filter
            
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .shadowToggle(let isOn):
            state.filter.param.isOndarkColor = isOn
            let filter = state.filter
            
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .highlightColorButtonTapped(let color):
            state.filter.param.brightColor = color
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .shadowColorButtonTapped(let color):
            state.filter.param.darkColor = color
            state.filter.pushDeque()
            print(state.filter.paramDeque.count)
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .undoButtonTapped:
            state.filter.undo()
            state.filter.param = state.filter.currentParam()
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let image = filter.refresh()
                effect(.filteredImageLoaded(image))
            }
            
        case .redoButtonTapped:
            state.filter.redo()
            state.filter.param = state.filter.currentParam()
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let image = filter.refresh()
                effect(.filteredImageLoaded(image))
            }
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
