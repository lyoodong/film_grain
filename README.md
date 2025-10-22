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

- 모의 면접 화면에서 사용자가 질문에 대한 숙련도를 수정할 수 있음

**Solution**

- `onCompleted` 시점을 아래와 같이 적용
  1. 다음 질문으로 이동 → `nextButtonTapped()`

**Result**

- 불필요한 DB 연산 제거, **마지막으로 방출한 값만 DB에 저장**

```swift

```

**Lessons & Learned**

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
