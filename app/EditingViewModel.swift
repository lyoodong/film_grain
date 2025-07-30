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
        var grainAlpha: Double = 0
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
                async let rawData  = try? await item.loadTransferable(type: Data.self)
                async let uiImage  = item.toImage()
                
                guard let img = await uiImage,
                      let raw = await rawData else { return }
                
                let resized = img.resized512()
                
                await update { state in
                    state.originImage    = resized
                    state.displayedImage = self.applyGrain(image: resized, alpha: state.grainAlpha)
                    state.originalData   = raw
                }
            }

        case .saveButtonTapped:
            saveImage(state.displayedImage)

        case .grainSliderChanged(let alpha):
            state.grainAlpha = Double(alpha)
            guard let originImage = state.originImage else { return }
            state.displayedImage = applyGrain(image: originImage, alpha: state.grainAlpha)
        }
    }

    private lazy var context = CIContext()

    private func applyGrain(
        image: UIImage,
        alpha: Double
    ) -> UIImage? {
        guard let base  = CIImage(image: image) else { return nil }

        let grainF = CIFilter.randomGenerator()

        let grayF = CIFilter.minimumComponent()
        grayF.inputImage = grainF.outputImage

        let alphaF = CIFilter.colorMatrix()
        alphaF.inputImage = grayF.outputImage
        alphaF.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(alpha))

        let blend = CIFilter.softLightBlendMode()
        blend.inputImage = alphaF.outputImage
        blend.backgroundImage = base

        guard let out = blend.outputImage,
              let cg  = context.createCGImage(out, from: base.extent) else { return nil }

        return UIImage(cgImage: cg)
    }

    func saveImage(
        _ image: UIImage?
    ) {
        guard let img = image else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}


