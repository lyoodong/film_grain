import SwiftUI
import Photos
import PhotosUI

extension EditTmpViewModel: ViewModelType {
    struct State {
        var selectedId: String
    }
    
    enum Action {
        case onAppear(CGFloat)
    }
}

final class EditTmpViewModel: toVM<EditTmpViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear(let size):
            print(size)
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
}
