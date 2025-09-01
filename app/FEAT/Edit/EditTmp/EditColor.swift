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


//MARK: - REFACTORING

struct EditColorTmp: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            if editVM.filter.isOnBrightColor || editVM.filter.isOndarkColor {
                EditTmpSlider(
                    type: .threshold,
                    value: editVM.filter.threshold
                ) {
                    editVM.send(.thresholdChanged($0))
                }
            }
            
            ColorToggleStack(
                title: "Highlight",
                isOn: Binding(
                    get: { editVM.filter.isOnBrightColor },
                    set: { editVM.send(.highlightToggle($0)) }
                )
            )
            
            if editVM.filter.isOnBrightColor {
                EditTmpSlider(
                    type: .brightColorAlpha,
                    value: editVM.filter.brightAlpha,
                    color: editVM.filter.brightColor,
                    colorSelected: { editVM.send(.highlightColorButtonTapped($0)) },
                    onChanged: { editVM.send(.brightColorAlphaChanged($0)) }
                )
            }
            
            ColorToggleStack(
                title: "Shadow",
                isOn: Binding(
                    get: { editVM.filter.isOndarkColor },
                    set: { editVM.send(.shadowToggle($0)) }
                )
            )
            
            if editVM.filter.isOndarkColor {
                EditTmpSlider(
                    type: .darkColorAlpha,
                    value: editVM.filter.darkAlpha,
                    color: editVM.filter.darkColor,
                    colorSelected: { editVM.send(.shadowColorButtonTapped($0)) },
                    onChanged: { editVM.send(.darkColorAlphaChanged($0)) }
                )
            }
        }
    }
}

struct ColorToggleStack: View {
    let title: String
    @Binding var isOn: Bool
    
    private let font = Poppin.semiBold.font(size: 12)
    
    var body: some View {
        HStack() {
            text
            Spacer()
            toggle
        }
        .padding(.horizontal, 16)
    }
    
    private var text: some View {
        Text(title)
            .font(font)
    }
    
    private var toggle: some View {
        Toggle(isOn: $isOn, label: { })
            .labelsHidden()
            .tint(.white.opacity(0.6))
            .scaleEffect(0.9)
    }
}

