import SwiftUI

struct UploadButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "arrow.up")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Capsule().fill(Color.orange))
        }
        .buttonStyle(ScaleOnPressButtonStyle())
    }
}

struct ScaleOnPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
    }
}
