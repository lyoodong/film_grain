import SwiftUI

extension Color {
    static var mainGray: Self = .init(hex: "8D8D8D")
    static var mainWhite: Self = .init(hex: "F3F5F7")
    static var mainBlack: Self = .init(hex: "101010")
    
    static var sheetGray: Self = .init(hex: "181818")
    static var textGray: Self = .init(hex: "777777")
    static var sheeTextGray: Self = .init(hex: "616161")
    
    static var pointRed: Self = .init(hex: "FF4A17")
    
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit, e.g. #F90)
            (r, g, b, a) = (
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17,
                255
            )
        case 6: // RGB (24-bit, e.g. #FF9900)
            (r, g, b, a) = (
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF,
                255
            )
        case 8: // ARGB (32-bit, e.g. #FFFF9900)
            (r, g, b, a) = (
                int >> 24 & 0xFF,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            (r, g, b, a) = (1, 1, 1, 1) // fallback: white
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

