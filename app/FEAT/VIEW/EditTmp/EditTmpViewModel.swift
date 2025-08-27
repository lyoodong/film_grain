import SwiftUI
import Photos
import PhotosUI

extension EditTmpViewModel: ViewModelType {
    struct State {
        var selectedId: String
        var originData: Data = Data()
        var originImage: UIImage?
        var displayImage: UIImage?
        
        var isLoad = true
        var selectedTap: ToolType? = nil
        
        var toolHeight: CGFloat = 60
        var toolMinHeight: CGFloat = 60
        var toolMaxHeight: CGFloat = 60
        var tapOpacity: Double = 0
    
        var isDraging = false
        
        func toolButtonTextColor(_ type: ToolType) -> Color {
            return type == selectedTap ? .red : .white
        }
        
        var filter: Filter = .init()
    }
    
    enum Action {
        //View LifeCycle
        case onAppear
        
        //load Image
        case dataLoaded(Data)
        case imageLoaded(UIImage?)
        case filteredImageLoaded(UIImage?)
        
        case tapSelected(ToolType?)
        case dragToolOnChanged(CGFloat)
        case dragToolOnEnded(CGFloat)
        
        case grainAlphaChanged(Double)
        case grainScaleChanged(Double)
    }
}

final class EditTmpViewModel: toVM<EditTmpViewModel> {
    
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            let id = state.selectedId
            
            Task(priority: .userInitiated) {[weak self] in
                guard let self else { return }
                if let data = await loadData(id: id) {
                    effect(.dataLoaded(data))
                }
            }
            
        case .dataLoaded(let data):
            state.originData = data
            
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let image = downsample(data: data)
                effect(.imageLoaded(image))
            }
            
        case .imageLoaded(let image):
            state.isLoad = false
            state.originImage = image
            state.displayImage = image
            
            if let image = image {
                state.filter.grainCI = state.filter.createGrainFilter(size: image.size)
                state.filter.baseCI = CIImage(image: image)
            }
            
        case .filteredImageLoaded(let image):
            state.displayImage = image

        case .tapSelected(let type):
            if let type = type {
                state.toolMaxHeight = type.maxViewHeight
                state.toolHeight = state.toolMaxHeight
                state.selectedTap = type
                state.tapOpacity = 1
            }
            
        case .dragToolOnChanged(let moved):
            state.isDraging = true
            let movedHeight = state.toolHeight - moved
            state.toolHeight = clamp(movedHeight, min: state.toolMinHeight, max: state.toolMaxHeight)
            
            
        case .dragToolOnEnded(let moved):
            state.isDraging = false
            let movedHeight = state.toolHeight - moved

            if movedHeight > state.toolHeight {
                state.toolHeight = state.toolMaxHeight
                state.tapOpacity = 1
            } else {
                state.toolHeight = state.toolMinHeight
                state.toolMaxHeight = state.toolMinHeight
                state.selectedTap = nil
                state.tapOpacity = 0
            }
            
        case .grainAlphaChanged(let alpha):
            state.filter.grainAlpha = alpha
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
            }
            
        case .grainScaleChanged(let scale):
            state.filter.grainScale = scale
            
            let filter = state.filter
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let iamge = filter.refresh()
                effect(.filteredImageLoaded(iamge))
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
    
    private func clamp(_ x: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(x, min), max)
    }
}
