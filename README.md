<img src="https://github.com/user-attachments/assets/72df26ce-d411-4ecf-9da0-71e46dc73fdc" width="30%" align="center" />
<img src="https://github.com/user-attachments/assets/a5223852-c2f5-4079-8088-40464f288487" width="30%" align="center" />
<img src="https://github.com/user-attachments/assets/0b51ed56-0c67-45d0-9fac-14be5c04b78d" width="30%" align="center" />

# Film-Grain 

> 핵심 기능
- CoreML 프레임워크의 MLRegressor를 활용해, AI 필터 기능 구현
- GameplayKit, SpriteKit 프레임워크 이용한 그레인 필터 구현
- CoreImage 프레미워크의 CIFiter를 활용해 '컬러 그레이딩', '색온도', '대비' 필터 구현
- PhotosUI 프레임워크의 PhotosPicker를 활용해 이미지 피커 구현
- 이미지 다운샘플링을 통해 성능 최적화

---

> 기술 스택
- **언어**: Swift
- **프레임워크**: SwiftUI, CoreML, CoreImage, GameplayKit, SpriteKit
- **아키텍처**: MVI
- **비동기처리**: Swift Concurrency

---

> 서비스
- **최소 버전**: iOS 18.0
- **개발 인원**: 1인
- **개발 기간** : 2025.7.25 ~ 2025.09.18, 현재 지속적으로 서비스 운영 중
- **iOS 앱스토어:** [필름그레인 바로가기](https://apps.apple.com/kr/app/film-grain/id6749135152)
---

### 트러블 슈팅

**1. 사진에 특성에 맞는 최적의 빈티지 필터 프리셋 제공**

**Issue**
- 서버 비용 절감, 관리 편의성을 위해, On-Deivce 형태의 AI 활용이 필요
- 회귀 학습을 위한 샘플 사진과 정답 데이터 확보

**Solution**
- CoreML의 MLRegressor를 활용해, 모델 지도 학습 진행
- CoreImage를 활용해 입력 받은 이미지에 대해서 아래의 8개의 특성 분석
- 10장의 샘플 이미지에 대한 유저 편집 결과 값 수집
- 모델 학습 후, 프로젝트에 통합

**Result**
- CoreImage를 통해 분석한 이미지 특성
```swift
import Foundation

struct AnalyzedFeature {
    let avgLuma:         Float   // 평균 명도
    let rmsContrast:     Float   // RMS 대비
    let colorVar:        Float   // RGB 분산 평균
    let satStdDev:       Float   // 채도 표준편차
    let highlights:      Float   // 하이라이트 픽셀 비율
    let shadows:         Float   // 섀도 픽셀 비율
    let midtoneRatio:    Float   // 중간톤 비율
    let meanHue:         Float   // 평균 색조
    let hueVariance:     Float   // 색조 분산
}
```

- PlayGround에서 모델 학습 진행
```swift
import Foundation
import CreateML

do {
    // 1) CSV 로드
    let csvURL = URL(fileURLWithPath: "/Users/...")
    let data   = try MLDataTable(contentsOf: csvURL)

    // 2) 80%/20% 분할
    // 80%는 학습용
    // 20%는 검증용
    let (trainTable, testTable) = data.randomSplit(by: 0.8, seed: 42)

    // 3) 공통 피처 열 이름
    let featureCols = [
        "avgLuma",
        "rmsContrast",
        "colorVar",
        "satStdDev",
        "highlights",
        "shadows",
        "midtoneRatio",
        "meanHue",
        "hueVariance"
    ]

    // 4) 회귀 모델 학습 헬퍼
    func trainRegression(
        targetColumn: String,
        modelName:    String
    ) throws {
        let regressor = try MLRegressor(
            trainingData:   trainTable,
            targetColumn:   targetColumn,
            featureColumns: featureCols
        )
        
        // 검증용 데이터로 학습된 모델 평가
        // 0에 가까울 수록 완벽한 예측
        let metrics = regressor.evaluation(on: testTable)
        print("\(targetColumn) RMSE:", metrics.rootMeanSquaredError)

        let metadata = MLModelMetadata(
            author: "Your Name",
            shortDescription: "Predicts \(targetColumn) for film grain presets",
            license: "MIT",
            version: "1.0"
        ) 

        let outURL = URL(fileURLWithPath: "/Users/dongwanryoo/Downloads/\(modelName).mlmodel")
        try regressor.write(to: outURL, metadata: metadata)
    }

    // 6) 회귀 타깃 모델들
    try trainRegression(targetColumn: "grainAlpha",  modelName: "GrainAlphaRegressor")
    try trainRegression(targetColumn: "grainScale",  modelName: "GrainScaleRegressor")
    try trainRegression(targetColumn: "contrast",    modelName: "ContrastRegressor")
    try trainRegression(targetColumn: "temperture",  modelName: "TemperatureRegressor")
    try trainRegression(targetColumn: "threshold",   modelName: "ThresholdRegressor")
    try trainRegression(targetColumn: "brightAlpha", modelName: "BrightAlphaRegressor")
    try trainRegression(targetColumn: "darkAlpha",   modelName: "DarkAlphaRegressor")

} catch {
    print("❌ Model training failed:", error)
    exit(1)
}
```
- 생성된 `.mlmodel` 프로젝트에 통합
<img width="482" height="146" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202025-09-11%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010 39 16" src="https://github.com/user-attachments/assets/06741e41-1a57-4eaa-b9be-90fe952f91a6" />

**Lessons & Learned**
- 간단한 지도 학습을 통해 생선한 소형 모델은 On-Device 형태로 편리하게 사용 가능하다.
- 서버 호출에 의한 여러 가지 제약 사항을 극복할 수 있었음
 - 서버 지연 없음
 - offline 상태에도 사용 가능
 - 유지 비용 없음


---

**2. 필름 사진에 있는 그레인 효과처럼 불규칙한 그레인 노이즈 생성**

**Issue**

- 모의 면접 화면에서 사용자가 질문에 대한 숙련도를 수정할 수 있음

**Solution**

- `onCompleted` 시점을 아래와 같이 적용
  1. 다음 질문으로 이동 → `nextButtonTapped()`

**Result**

- 불필요한 DB 연산 제거, **마지막으로 방출한 값만 DB에 저장**

```swift

```
---

**Lessons & Learned**


> 📒 커밋 메시지 형식

| 유형      | 설명                                                    | 예시                                |
|-----------|---------------------------------------------------------|-------------------------------------|
| FIX       | 버그 또는 오류 해결                                     | [FIX] #10 - 콜백 오류 수정            |
| ADD       | 새로운 코드, 라이브러리, 뷰, 또는 액티비티 추가        | [ADD] #11 - LoginActivity 추가         |
| FEAT      | 새로운 기능 구현                                        | [FEAT] #11 - Google 로그인 추가         |
| DEL       | 불필요한 코드 삭제                                      | [DEL] #12 - 불필요한 패키지 삭제        |
| REMOVE    | 파일 삭제                                               | [REMOVE] #12 - 중복 파일 삭제         |
| REFACTOR  | 내부 로직은 변경하지 않고 코드 개선 (세미콜론, 줄바꿈 포함) | [REFACTOR] #15 - MVP 아키텍처를 MVVM으로 변경 |
| CHORE     | 그 외의 작업 (버전 코드 수정, 패키지 구조 변경, 파일 이동 등) | [CHORE] #20 - 불필요한 패키지 삭제      |
| DESIGN    | 화면 디자인 수정                                         | [DESIGN] #30 - iPhone 12 레이아웃 조정  |
| COMMENT   | 필요한 주석 추가 또는 변경                               | [COMMENT] #30 - 메인 뷰컨 주석 추가     |
| DOCS      | README 또는 위키 등 문서 내용 추가 또는 변경            | [DOCS] #30 - README 내용 추가          |
| TEST      | 테스트 코드 추가                                        | [TEST] #30 - 로그인 토큰 테스트 코드 추가  |
