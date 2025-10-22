<img src="https://github.com/user-attachments/assets/72df26ce-d411-4ecf-9da0-71e46dc73fdc" width="30%" align="center" />
<img src="https://github.com/user-attachments/assets/a5223852-c2f5-4079-8088-40464f288487" width="30%" align="center" />
<img src="https://github.com/user-attachments/assets/0b51ed56-0c67-45d0-9fac-14be5c04b78d" width="30%" align="center" />

# Film-Grain 

> 핵심 기능
- AVFoundation 프레임워크 기반 AudioPlayer, AudioRecorder를 통해
  **음성 녹음, 기록 재생 기능** 구현
- Speech 프레임워크 기반 speechRecognizer를 통해 녹음과 동시에
  **실시간 STT(Speech To Text)기능** 구현
- AVFoundation 프레임워크 기반 AVCaptureVideoPreviewLayer를 통해 실시간으로
  **말하는 표정, 동작을 확인**하는 기능 구현
- Realm DB를 활용해 **N:M 스키마** 대응
- FileManager를 활용해 **녹음 파일 관리**
- **DIP**를 통한 의존성 역전
- 샘플레이트 핸들링을 통한 **오디오 품질 및 용량 최적화**

---

> 기술 스택
- **언어**: Swift
- **프레임워크**: SwiftUI, CoreML, CoreImage
- **아키텍처**: MVI
- **비동기처리**: Swift Concurrency

---

> 서비스
- **최소 버전**: iOS 18.0
- **개발 인원**: 1인
- **개발 기간** : 2025.7.25 ~ 2025.09.18, 현재 지속적으로 서비스 운영 중
- **iOS 앱스토어:** [필름그레인](https://apps.apple.com/kr/app/film-grain/id6749135152)
---

### 트러블 슈팅

**1. 숙련도 점수 수정 시 마지막으로 수정한 값만 Realm에 저장**

**Issue**

- 모의 면접 화면에서 사용자가 질문에 대한 숙련도를 수정할 수 있음
- 하지만, 기존 코드에서는 숙련도만 클릭하면 그 즉시 값을 Realm DB에 업로드
- 사용자가 마지막으로 선택한 값만 Realm DB에 저장함으로써 **불필요한 DB 연산 제거**

**Solution**

- `RxSwift`의 `AsyncSubject` 활용해, 마지막으로 수정한 값만 Realm DB에 저장
- `onCompleted` 시점을 아래와 같이 적용
  1. 다음 질문으로 이동 → `nextButtonTapped()`
  2. 이전 질문으로 이동 → `backuttonTapped()`
  3. 다른 뷰로 이동 → `viewDidDisappear()`

**Result**

- 불필요한 DB 연산 제거, **마지막으로 방출한 값만 DB에 저장**

```swift
//개선된 코드
func uploadSelectedFamiliarityDegree() {
    familiaritySubject
        .subscribe(with: self) { owner, value in
            let realm = try! Realm()
            try! realm.write {
                owner.questions[owner.currnetQuestionIndex.value].familiarityDegree = value
            }
            
            print("uploadSelectedFamiliarityDegree 실행")
            owner.repo.realmFileLocation()
        }
        .disposed(by: disposeBag)
}

//1. 다음 질문으로 이동
@objc func nextButtonTapped() {
    cameraViewModel.familiaritySubject.onCompleted()
    cameraViewModel.currnetQuestionIndex.value += 1
    cameraViewModel.fetchCurrentFamilarDegree()
}

//2. 이전 질문으로 이동
@objc func backButtonTapped() {
    cameraViewModel.familiaritySubject.onCompleted()
    cameraViewModel.currnetQuestionIndex.value -= 1
    cameraViewModel.fetchCurrentFamilarDegree()
}

//3. 다른 뷰로 이동
override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		cameraViewModel.familiaritySubject.onCompleted()
}
```
---

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
