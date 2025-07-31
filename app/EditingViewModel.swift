import SwiftUI
import Photos
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

extension EditingViewModel: ViewModelType {
    struct State {
        var originImage: UIImage?
        var displayedImage: UIImage?
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
            let alpha = state.grainAlpha

            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                async let uiImage = item.toUIImage()
                guard let img = await uiImage else { return }


                var filtered: UIImage?

                // autoreleasepool 으로 동기적으로 CI/CG 리소스 해제 관리
                autoreleasepool {
                    filtered = self.applyGrain(image: img, alpha: alpha)
                }

                await self.update { state in
                    state.originImage    = img
                    state.displayedImage = filtered
                }
            }

        case .saveButtonTapped:
            let image = state.displayedImage
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                self.saveImage(image)
            }

        case .grainSliderChanged(let alpha):
            state.grainAlpha = Double(alpha)
            let alpha = Double(alpha)
            guard let originImage = state.originImage else { return }
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                var filtered: UIImage?
                
                autoreleasepool {
                    filtered = self.applyGrain(image: originImage, alpha: alpha)
                }
                
                await self.update { $0.displayedImage = filtered }
            }
        }
    }
    
    lazy var context: CIContext = {
      if let dev = MTLCreateSystemDefaultDevice() {
        return CIContext(mtlDevice: dev)
      }
      return CIContext(options: nil)
    }()

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


