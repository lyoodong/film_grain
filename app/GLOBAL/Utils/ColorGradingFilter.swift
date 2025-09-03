import Foundation
import CoreImage

public protocol CIColorGrading: AnyObject {
    var inputImage: CIImage? { get set }
    var threshold: CGFloat { get set }
    var brightColor: CIColor { get set }
    var darkColor: CIColor { get set }
}

final class ColorGradingFilter: CIFilter, CIColorGrading {
    var inputImage: CIImage?
    var threshold: CGFloat = 0.5
    var brightColor: CIColor = .clear
    var darkColor: CIColor = .clear
    
    // CIColorKernel: Core Image에서 픽셀 단위의 '색' 연산을 정의하는 객체
    // CIColorKernel()를 실행하면, 내부에 들어간 source를 컴파일해서 GPU가 실행 가능한 코드로 반환
    // Core Image Kernel Language -> 애플의 Core Image 프레임워크에서 실행 가능한 shading language
    // shader GPU에서 실행되는 그래픽 렌더링 프로그램
    
    private let source: String = """
    kernel vec4 contrastOverlay(__sample img, float threshold,
                                __color darkC, __color brightC) {
        float l = dot(img.rgb, vec3(0.299,0.587,0.114));
        return (l < threshold) ? darkC : brightC;
    }
    """
    
    private var kernel: CIColorKernel {
        return CIColorKernel(source: source)!
    }
    
    override var outputImage: CIImage? {
        guard let input = inputImage else { return nil }
        
        guard let overlay = kernel.apply(
            extent: input.extent,
            arguments: [input, threshold, darkColor, brightColor]
        ) else { return nil }
        return overlay.composited(over: input)
    }
}

public extension CIFilter {
    class func colorGrading() -> any CIFilter & CIColorGrading {
        ColorGradingFilter()
    }
}
