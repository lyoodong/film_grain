import SwiftUI

struct ColorGradingItems {
    static func preset() -> [ColorGrading] {
        //Teal and Orange
        let teal = CIColor(red: 0.0, green: 0.8, blue: 0.7)
        let orange = CIColor(red: 1.0, green: 0.6, blue: 0.0)
        
        return [ColorGrading(bright: teal, dark: orange)]
    }
}

struct ColorGrading {
    let bright: CIColor
    let dark: CIColor
}

struct EditColor: View {
    @ObservedObject var editVM: EditTmpViewModel
    @State private var selected: Int? = 0
    
    var body: some View {
        VStack {
            ColorGradingList(
                items: editVM.colorGradingItems,
                selectedIndex: editVM.selectedIndex,
                noneButtonTapped: { editVM.send(.noneButtonTapped) },
                colorButtonTapped: { editVM.send(.colorButtonTapped($0)) },
                customButtonTapped: { editVM.send(.customButtonTapped) }
            )
            
            if !editVM.isHiddenColorSlider {
                EditTmpSlider(type: .threshold, value: editVM.filter.threshold) {
                    editVM.send(.thresholdChanged($0))
                }
                
                EditTmpSlider(type: .brightColorAlpha, value: editVM.filter.brightAlpha) {
                    editVM.send(.brightColorAlphaChanged($0))
                }
                
                EditTmpSlider(type: .darkColorAlpha, value: editVM.filter.darkAlpha) {
                    editVM.send(.darkColorAlphaChanged($0))
                }
            }
        }
    }
}

struct ColorGradingList: View {
    let items: [ColorGrading]
    var selectedIndex: Int?
    var size: CGFloat = 40
    var spacing: CGFloat = 20
    
    var noneButtonTapped: () -> Void
    var colorButtonTapped: (Int) -> Void
    var customButtonTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            TitleStack(title: "Color")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    NoneButton(size: size, action: noneButtonTapped)
                    ColorButtonList(items: items, size: size, selectedIndex: selectedIndex, action: colorButtonTapped)
                    CustomButton(size: size, action: customButtonTapped)
                }
            }
        }
    }
}

fileprivate struct TitleStack: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
    }
}

fileprivate struct ColorButtonList: View {
    let items: [ColorGrading]
    let size: CGFloat
    let selectedIndex: Int?
    let action:(Int) -> Void
    
    var body: some View {
        ForEach(Array(items.enumerated()), id: \.offset) {idx, item in
            ColorButton(
                bright: Color(uiColor: .init(ciColor: item.bright)),
                dark: Color(uiColor: .init(ciColor: item.dark)),
                isSelected: selectedIndex == idx,
                size: size,
                action: { action(idx) }
            )
        }
    }
}


fileprivate struct ColorButton: View {
    let bright: Color
    let dark: Color
    let isSelected: Bool
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ColorCircle(bright: bright, dark: dark, isSelected: isSelected, size: size)
        }
    }
}

fileprivate struct ColorCircle: View {
    let bright: Color
    let dark: Color
    let isSelected: Bool
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(LinearGradient(colors: [bright, dark], startPoint: .leading, endPoint: .trailing))
            .overlay(Circle().stroke(isSelected ? .red : .black, lineWidth: 2))
            .frame(width: size, height: size)
    }
}

fileprivate struct CustomButton: View {
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            CustomCircle(size: size)
        }
    }
}

fileprivate struct NoneButton: View {
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            NoneCircle(size: size)
        }
    }
}

fileprivate struct CustomCircle: View {
    let size: CGFloat
    var body: some View {
        Circle()
            .fill(.red)
            .frame(width: size, height: size)
    }
}

fileprivate struct NoneCircle: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: size, height: size)
    }
}



struct EditColorTmp: View {
    @ObservedObject var editVM: EditTmpViewModel
    @State var isOn = true
    let iconFont = Poppin.semiBold.font(size: 12)
    
    var body: some View {
        VStack {
            colorStack
        }
    }
    
    private var colorStack: some View {
        VStack {
            HStack(spacing: 16) {
                text
                Spacer()
                toggle
            }
            .padding(.horizontal, 16)
            
            if isOn {
                EditTmpSlider(type: .grainAlpha, value: editVM.filter.grainAlpha) {
                    editVM.send(.grainAlphaChanged($0))
                }
            }
        }
    }
    
    private var text: some View {
        Text("Highlight")
            .font(iconFont)
    }
    
    private func colorCircle(color: Color) -> some View {
        Circle()
            .fill(.red)
            .frame(width: 31, height: 31)
    }
    
    private var toggle: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .tint(.white.opacity(0.6))
            .scaleEffect(0.9)
    }
}

