import SwiftUI
import Photos
import PhotosUI

struct EditView: View {
    
    @ObservedObject var editVM: EditViewModel
    
    //photo picker를 위한 상태
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            if let image = editVM.displayImage {
                displayedImage(image)
                    .contrast(editVM.contrast)
                aiPreset
                grain
            }
        }
        
        HStack {
            photoPicker
            saveButton
        }
        .onAppear {
            let size = UIScreen.main.bounds.size
            let scale = UIScreen.main.scale
            let max = max(size.height, size.width)
            editVM.send(.previewWidthUpdated(max * scale))
        }
        .padding()
    }
    
    private var aiPreset: some View {
        Button("AI 추천") { editVM.send(.aiButtonTapped) }
    }
    
    private func displayedImage(_ image: UIImage) -> some View {
        ZoomableImage(image: image)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var grain: some View {
        VStack {
            HStack {
                Text("GrainAlpha \(Int(editVM.grainAlpha * 100))%")
                Slider(
                    value: Binding(
                        get: { Float(editVM.grainAlpha) },
                        set: { editVM.send(.grainAlphaChanged($0))}
                    ),
                    in: 0...1,
                    step: 0.01
                )
            }
            
            HStack {
                Text("GrainScale \(Int(editVM.grainScale * 100))%")
                
                Slider(
                    value: Binding(
                        get: { Float(editVM.grainScale) },
                        set: { editVM.send(.grainScaleChanged($0)) }
                    ),
                    in: 1...10,
                    step: 0.1
                )
            }
            
            HStack {
                Text("Contrast \(Int(editVM.contrastValue))%")
                
                Slider(
                    value: Binding(
                        get: { Float(editVM.contrastValue) },
                        set: { editVM.send(.contrastChanged($0)) }
                    ),
                    in: -100...100,
                    step: 1
                )
            }
            
            Toggle(isOn: Binding(get: { editVM.isColorGrading },
                                 set: { editVM.send(.colorGradingChanged($0))})) {
                Text("ColorGrading")
            }
            
            HStack {
                Text("ORANGE \(Int(editVM.orangeAlpha * 100))%")
                
                Slider(
                    value: Binding(
                        get: { Float(editVM.orangeAlpha) },
                        set: { editVM.send(.orangeAlphaChanged($0)) }
                    ),
                    in: 0...1,
                    step: 0.01
                )
            }
            
            HStack {
                Text("TEAL \(Int(editVM.tealAlpha * 100))%")
                
                Slider(
                    value: Binding(
                        get: { Float(editVM.tealAlpha) },
                        set: { editVM.send(.tealAlphaChanged($0)) }
                    ),
                    in: 0...1,
                    step: 0.01
                )
            }
            
            HStack {
                Text("CG threshold \(Int(editVM.threshold * 100))%")
                
                Slider(
                    value: Binding(
                        get: { editVM.threshold },
                        set: { editVM.send(.thresholdChanged($0)) }
                    ),
                    in: 0...1,
                    step: 0.01
                )
            }
        }
    }
    
    private var photoPicker: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ){ uploadLabel }
            .onChange(of: selectedItem) { _, picked in
                guard let picked else { return }
                
                guard let id = picked.itemIdentifier,
                      let asset = PHAsset.fetchAssets(
                        withLocalIdentifiers: [id], options: nil
                      ).firstObject else { return }
                
                let opts = PHImageRequestOptions()
                opts.isNetworkAccessAllowed = false
                
                PHImageManager.default().requestImageDataAndOrientation(
                    for: asset, options: opts
                ) { data, _, _, info in
                    let inCloud = (info?[PHImageResultIsInCloudKey] as? Bool) == true
                    print(inCloud
                          ? "☁️ 아직 iCloud에서 내려받는 중"
                          : "📁 로컬에 다운로드 완료")
                }
                
                editVM.send(.photoSelected(picked))
            }
    }
    
    private var uploadLabel: some View {
        Label("Upload", systemImage: "photo.on.rectangle")
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
    }
    
    private var saveButton: some View {
        Button {
            editVM.send(.saveButtonTapped)
        } label: {
            saveLabel
        }
    }
    
    private var saveLabel: some View {
        Label("Save", systemImage: "square.and.arrow.down")
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
    }
}

struct ZoomableImage: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    // 핀치 줌
                    MagnificationGesture()
                        .onChanged { value in
                            self.scale = self.lastScale * value
                        }
                        .onEnded { value in
                            let newScale = self.lastScale * value
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                if newScale < 1 {
                                    self.scale = 1
                                    self.lastScale = 1
                                    // 원래 크기로 돌아오면 드래그 오프셋도 초기화
                                    self.offset = .zero
                                    self.lastOffset = .zero
                                } else {
                                    self.scale = newScale
                                    self.lastScale = newScale
                                    // 확대 시 기본 오프셋 유지
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    // 드래그 제스처: scale > 1 일 때만 적용
                    DragGesture()
                        .onChanged { value in
                            guard self.lastScale > 1 else { return }
                            // 뷰보다 이미지가 넓은 경우에만 움직이도록 (간단 체크)
                            let imgWidth = proxy.size.width * self.lastScale
                            let imgHeight = proxy.size.height * self.lastScale
                            if imgWidth > proxy.size.width || imgHeight > proxy.size.height {
                                self.offset = CGSize(
                                    width: self.lastOffset.width + value.translation.width,
                                    height: self.lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            guard self.lastScale > 1 else {
                                // 축소 상태라면 중앙 복원
                                withAnimation {
                                    self.offset = .zero
                                    self.lastOffset = .zero
                                }
                                return
                            }
                            // 확대 상태라면 최종 오프셋 저장
                            self.lastOffset = self.offset
                        }
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
                .background(Color.black.opacity(0.001))
        }
    }
}
