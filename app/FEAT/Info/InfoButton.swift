import SwiftUI

enum InfoType {
    case privacy
    case terms
    case review
    case email
    
    var image: Image {
        switch self {
        case .privacy:
            Image(systemName: "lock.shield")
        case .terms:
            Image(systemName: "doc.text")
        case .review:
            Image(systemName: "star.fill")
        case .email:
            Image(systemName: "envelope")
        }
    }
    
    var title: String {
        switch self {
        case .privacy:
            return "Privacy Policy"
        case .terms:
            return "Terms of Service"
        case .review:
            return "Leave a Review"
        case .email:
            return "Support Email"
        }
    }
}

struct InfoButton: View {
    let type: InfoType
    let action: () -> Void
    
    private let font = Poppin.regular.font(size: 16)
    private let diameter: CGFloat = 40
    
    var body: some View {
        Button(action: action, label: label)
    }
    
    private func label() -> some View {
        HStack {
            icon
            text
            Spacer()
            arrowIcon
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(background)
    }
    
    private var icon: some View {
        type.image
            .frame(width: diameter, height: diameter)
            .font(font)
            .foregroundColor(.white)
    }
    
    private var text: some View {
        Text(type.title)
            .font(font)
            .foregroundColor(.white)
    }
    
    private var arrowIcon: some View {
        Image(systemName: "chevron.right")
            .frame(width: diameter, height: diameter)
            .font(font)
            .foregroundColor(.gray)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
    }
}
