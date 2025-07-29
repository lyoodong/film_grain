import SwiftUI
import Photos
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

extension EditingViewModel: ViewModelType {
    struct State {
        var originImage: UIImage?
        var displayedImage: UIImage?
        var imageType: UTType = .jpeg
    }
    
    enum Action {
        case photoSelected(PhotosPickerItem)
        case saveButtonTapped
        case grainSliderChanged(Float)
    }
}

final class EditingViewModel: toVM<EditingViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case let .photoSelected(item):
            state.imageType = item.loadPreferredType()
            
            Task { [weak self] in
                guard let self else { return }
                guard let image = await item.toImage() else { return }
                
                await self.update { state in
                    state.displayedImage = image
                    state.originImage = image
                }
            }
            
        case .saveButtonTapped:
            saveImage(state.displayedImage, originalUTType: state.imageType)
            break
            
        case .grainSliderChanged(let intensity):
            guard let originImage = state.originImage else { return }
            state.displayedImage = applyFilter(image: originImage, grainIntensity: Double(intensity))
        }
    }
    
    private lazy var context = CIContext()
    
    private func applyFilter(image: UIImage, grainIntensity: Double) -> UIImage? {
        guard let base = CIImage(image: image) else { return nil }
        
        // ① 노이즈 생성 및 크롭
        guard let noiseImage = CIFilter.randomGenerator().outputImage?.cropped(to: base.extent) else { return nil }
        
        // ② 루미넌스 필터 적용
        let luminanceFilter = CIFilter.minimumComponent()
        luminanceFilter.inputImage = noiseImage
        guard let luminanceImage = luminanceFilter.outputImage else { return nil }
        
        // ③ 투명도 조절
        let alphaFilter = CIFilter.colorMatrix()
        alphaFilter.inputImage = luminanceImage
        alphaFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(grainIntensity * 1.5))
        guard let alphaNoise = alphaFilter.outputImage else { return nil }
        
        // ④ 블렌딩
        let blendFilter = CIFilter.softLightBlendMode()
        blendFilter.inputImage = alphaNoise
        blendFilter.backgroundImage = base
        guard let blendedCI = blendFilter.outputImage,
              let cgImage = context.createCGImage(blendedCI, from: base.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func saveImage(_ image: UIImage?, originalUTType: UTType?) {
        guard let image = image,
              let utType = originalUTType else {
            return
        }
        
        guard let data = image.encodedData(for: utType) else {
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.uniformTypeIdentifier = utType.identifier
                request.addResource(with: .photo, data: data, options: options)
            }
        }
    }
    
}

