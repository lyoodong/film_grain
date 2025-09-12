import Foundation

enum Url {
    case privacy
    case terms
    
    var value: URL {
        switch self {
        case .privacy:
            return URL(string: "https://www.notion.so/lyoodong/Privacy-Policy-26b10412f59780829cb0cc74c68a70e5?source=copy_link")!
        case .terms:
            return URL(string: "https://www.notion.so/lyoodong/Terms-of-Service-26b10412f5978065a39ddc812931f3f2?source=copy_link")!
        }
    }
}
