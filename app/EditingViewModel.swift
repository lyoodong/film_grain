import SwiftUI
import Photos
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

extension EditingViewModel: ViewModelType {
    struct State {
        var originalData: Data?
        var originImage: UIImage?
        var displayedImage: UIImage?
        var imageType: UTType = .jpeg
        var previewPixelWidth: CGFloat = 0
    }
    
    enum Action {
        case photoSelected(PhotosPickerItem)
        case saveButtonTapped
        case grainSliderChanged(Float)
        case previewWidthUpdated(CGFloat)
    }
}

final class EditingViewModel: toVM<EditingViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case let .photoSelected(item):
            state.imageType = item.loadPreferredType()
            
            Task { [weak self] in
                guard let self else { return }
                async let rawData  = try? await item.loadTransferable(type: Data.self)
                async let uiImage  = item.toImage()
                
                guard let img = await uiImage,
                      let raw = await rawData else { return }
                
                await update { state in
                    state.originImage    = img
                    state.displayedImage = img
                    state.originalData   = raw
                }
            }
            
        case .previewWidthUpdated(let px):
            state.previewPixelWidth = px
            
        case .saveButtonTapped:
            saveImage(
                    state.displayedImage,
                    originalUTType: state.imageType,
                    originalData:  state.originalData
                )
            
        case .grainSliderChanged(let intensity):
            guard let originImage = state.originImage else { return }
            state.displayedImage = applyFilter(image: originImage, grainIntensity: Double(intensity), previewPixelWidth: state.previewPixelWidth)
        }
    }
    
    private lazy var context = CIContext()
    
    private func applyFilter(
        image: UIImage,
        grainIntensity: Double,
        previewPixelWidth: CGFloat
    ) -> UIImage? {
        guard var noise = CIFilter.randomGenerator().outputImage,
              let base  = CIImage(image: image) else { return nil }

        // ── ① 노이즈 스케일 고정 ─────────────────────────────
        //     원본 해상도 / 화면 표시 해상도 = 스케일
        let pixelSize = max(1, base.extent.width / previewPixelWidth)
        let pix       = CIFilter.pixellate()
        pix.inputImage = noise
        pix.scale      = Float(pixelSize)
        noise          = pix.outputImage?.cropped(to: base.extent) ?? noise

        // ── ② 루미넌스 + 불투명도 조절 ───────────────────────
        let lum = CIFilter.minimumComponent()
        lum.inputImage = noise

        let alpha = CIFilter.colorMatrix()
        alpha.inputImage = lum.outputImage
        alpha.aVector    = CIVector(x: 0, y: 0, z: 0,
                                    w: CGFloat(grainIntensity * 1.5))

        // ── ③ 블렌딩 (Soft‑Light) ────────────────────────────
        let blend = CIFilter.softLightBlendMode()
        blend.inputImage      = alpha.outputImage
        blend.backgroundImage = base

        guard let out = blend.outputImage,
              let cg  = context.createCGImage(out, from: base.extent) else { return nil }

        return UIImage(cgImage: cg)
    }
    
    func saveImage(
        _ image: UIImage?,
        originalUTType: UTType?,
        originalData: Data?
    ) {
        guard let img = image else { return }
        guard let type = originalUTType else { return }
        guard let originalData = originalData else { return }

        let data = img.encodedData(utType: type, from: originalData, quality: 0.9)

        guard let encoded = data else { return }

        PHPhotoLibrary.shared().performChanges {
            let req = PHAssetCreationRequest.forAsset()
            let opt = PHAssetResourceCreationOptions()
            opt.uniformTypeIdentifier = type.identifier
            req.addResource(with: .photo, data: encoded, options: opt)
        }
    }
    
}

