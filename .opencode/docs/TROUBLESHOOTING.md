# Troubleshooting Log

## 목적
- 최근에 발생한 문제의 원인/해결/코드 위치를 누적 기록한다.
- 같은 이슈 재발 시 빠르게 원인을 찾고 동일한 해결 방법을 재사용한다.

## 기록 규칙 (앞으로 동일하게 유지)
- 각 이슈는 아래 6개 항목으로 남긴다: `증상`, `원인`, `해결`, `변경 파일`, `검증`, `비고`.
- `변경 파일`은 실제 수정된 경로만 적고, 임시 실험 파일/아카이브 경로는 적지 않는다.
- 서버/플랫폼 이슈는 가능한 공식 문서 링크를 같이 적는다.

---

## 2026-02-15

### 1) 재료 추가 실패 알럿이 `DataLayer.APIError error 2`로만 표시됨
- 증상: 메뉴 재료 추가 실패 시 원인 문구 대신 시스템 에러 문자열만 노출.
- 원인: `error.localizedDescription`만 사용해서 `APIError.message`를 사용자에게 전달하지 못함.
- 해결: 알럿 메시지에서 `APIError`를 우선 캐스팅해 `message`를 표시하도록 변경.
- 변경 파일:
  - `FeatureMenu/Sources/MenuIngredients/MenuIngredientsFeature.swift`
- 검증:
  - 실패 케이스에서 한국어 서버 메시지 노출 확인.
- 비고:
  - 실제 실패 원인 중 하나는 `DUP_RECIPE`(이미 메뉴에 등록된 재료 중복 추가).

### 2) 재료 상세 상단 카테고리가 `INGREDIENTS`/`MATERIALS` 코드값으로 표시됨
- 증상: 재료 상세 카드 카테고리 텍스트가 한글 라벨이 아니라 서버 코드로 표시.
- 원인: 상세 뷰가 `item.category`를 그대로 렌더링.
- 해결:
  - 표시 시 코드 -> 라벨 변환(`INGREDIENTS -> 식재료`, `MATERIALS -> 운영 재료`).
  - 수정 저장 시 라벨 -> 코드 역변환 후 업데이트 요청.
- 변경 파일:
  - `FeatureIngredients/Sources/IngredientDetail/IngredientDetailView.swift`
  - `FeatureIngredients/Sources/IngredientDetail/IngredientDetailFeature.swift`
  - `FeatureIngredients/Sources/IngredientEditSheet/IngredientEditSheetFeature.swift`
  - `FeatureIngredients/Sources/IngredientEditSheet/IngredientEditSheetView.swift`
- 검증:
  - 상세/수정 시트에서 카테고리 라벨 정상 표시 및 저장 후 반영 확인.

### 3) 재료 추가 폼에서 필수값(가격/구매용량/사용량) 비어도 `추가하기` 활성화
- 증상: 필수 입력값 없이도 버튼이 활성화되어 잘못된 요청 가능.
- 원인: 버튼 상태 계산이 필수 필드를 반영하지 않음.
- 해결:
  - `price > 0 && purchaseAmount > 0 && usageAmount > 0`일 때만 버튼 활성화.
  - reducer에서도 동일 조건 guard 추가.
- 변경 파일:
  - `FeatureMenuRegistration/Sources/Ultrawork/IngredientAddSheet.swift`
  - `FeatureMenuRegistration/Sources/MenuRegistration/MenuRegistrationFeature.swift`
  - `FeatureMenu/Sources/MenuIngredients/AddIngredientSheet.swift`
- 검증:
  - 필수값 미입력 시 비활성, 모두 입력 시 활성 확인.

### 4) 메뉴 재료 추가 시트가 중간 높이(detent)로 멈추는 UI 버그
- 증상: `재료 추가` 시트가 의도하지 않게 중간 높이로 스냅됨.
- 원인: 시트 상태별로 복수 detent를 동시에 허용.
- 해결:
  - 상태별로 단일 detent만 허용:
    - 기본/커스텀 입력 단계: `.large`
    - 등록 재료 `+` 상세 단계: `.height(430)`
- 변경 파일:
  - `FeatureMenu/Sources/MenuIngredients/AddIngredientSheet.swift`
  - `FeatureMenu/Sources/MenuIngredients/MenuIngredientsView.swift`
- 검증:
  - 기본 시트는 중간 높이 미진입, `+` 상세 단계는 고정 높이 확인.

### 5) App Store 배포 옵션 미노출 (`Generic Xcode Archive`)
- 증상: Organizer에서 `App Store Connect` 배포 옵션이 나타나지 않음.
- 원인: 앱 아카이브가 아니라 워크스페이스 generic archive 생성.
- 해결:
  - 워크스페이스에서 앱 스킴(`CoachCoach`)으로 아카이브하도록 정리.
  - 앱 아카이브의 `ApplicationProperties` 포함 여부로 검증.
- 변경 파일:
  - (코드 변경 없음, 아카이브/스킴 사용 방식 정리)
- 검증:
  - `.xcarchive/Info.plist`에 `ApplicationProperties` 존재 확인.

### 6) 업로드 시 버전/빌드 정보 누락 오류
- 증상:
  - `CFBundleShortVersionString is empty`
  - `CFBundleVersion is empty`
- 원인: 버전/빌드 정보가 빌드 산출물에 안정적으로 주입되지 않음.
- 해결:
  - `Info.plist`에 기본값 추가.
  - Tuist app target 설정에 `MARKETING_VERSION`, `CURRENT_PROJECT_VERSION` 명시.
- 변경 파일:
  - `CoachCoach/Info.plist`
  - `CoachCoach/Project.swift`
- 검증:
  - 아카이브 `Info.plist`에서 두 값 확인.

### 7) `Missing or invalid signature` (submission certificate 아님)
- 증상: 업로드 시 앱이 Apple submission certificate로 서명되지 않았다고 실패.
- 원인: Release 아카이브가 개발 서명(`Apple Development` + dev/wildcard profile)으로 생성됨.
- 해결:
  - Tuist에서 app target 서명 분리:
    - Debug: Automatic + Apple Development
    - Release: Manual + Apple Distribution + 수동 App Store profile
  - bundle id를 `com.seungwan.coachcoach`로 통일.
- 변경 파일:
  - `CoachCoach/Project.swift`
- 검증:
  - 아카이브 로그에서 `Signing Identity: Apple Distribution` 확인.

### 8) `Xcode managed profile cannot be used with manual signing`
- 증상: Manual signing인데 `iOS Team Store Provisioning Profile: ...` 사용 시 아카이브 실패.
- 원인: Xcode-managed profile은 수동 서명 모드와 충돌.
- 해결:
  - Apple Developer Portal에서 수동 App Store profile 생성.
  - profile name: `CoachCoach AppStore (Manual)`
  - Tuist Release `PROVISIONING_PROFILE_SPECIFIER`를 위 이름으로 지정.
- 변경 파일:
  - `CoachCoach/Project.swift`
- 검증:
  - `xcodebuild -showBuildSettings`에서 Release profile specifier 일치 확인.

### 9) `Invalid Bundle OS Type code` (`CFBundlePackageType`)
- 증상: 업로드 검증에서 `CFBundlePackageType`이 `APPL`이 아니거나 비어있다고 실패.
- 원인: 아카이브 산출물 plist에 `CFBundlePackageType` 키 누락.
- 해결:
  - `Info.plist`에 `CFBundlePackageType = APPL` 추가.
  - Tuist build setting에 `INFOPLIST_KEY_CFBundlePackageType = APPL` 명시(구성별 주입 보강).
- 변경 파일:
  - `CoachCoach/Info.plist`
  - `CoachCoach/Project.swift`
- 검증:
  - 아카이브 앱 plist에서 `CFBundlePackageType` 추출 시 `APPL` 확인.

### 10) 메뉴 재료 추가 시 `오른쪽 추가`/`검색결과 +` 플로우 불일치
- 증상:
  - `재료 추가` 시트의 입력창 오른쪽 `추가`와 검색 결과 `+`가 서로 다른 동작/종료 타이밍을 보임.
- 원인:
  - 공통 draft 단계 없이 즉시 추가되는 경로와 상세 입력 경로가 혼재.
- 해결:
  - 2단계 플로우로 통일:
    - 입력창 오른쪽 `추가` -> 커스텀 상세 시트(카테고리 + 가격/구매용량/사용량/공급업체)
    - 검색 결과 `+` -> 등록 재료 상세 시트(사용량 + 재료정보)
  - 최종 추가는 각 상세 시트의 버튼에서만 실행하도록 정리.
- 변경 파일:
  - `FeatureMenu/Sources/MenuIngredients/AddIngredientSheet.swift`
- 검증:
  - 두 진입점 모두 즉시 닫히지 않고 상세 입력 단계로 진입 확인.

### 11) 재료 수정 바텀시트에서 카테고리 탭 선택 불가
- 증상:
  - `식재료/운영 재료`가 정적 배지처럼 보이고 선택이 반영되지 않음.
- 원인:
  - edit sheet state/action에 카테고리 변경 상태가 없고 저장 payload에도 미포함.
- 해결:
  - edit sheet에 `draftCategory`/`initialCategory` 상태 추가 및 변경 action 연결.
  - 저장 시 선택 카테고리를 상세 feature로 전달하고 update request에 반영.
- 변경 파일:
  - `FeatureIngredients/Sources/IngredientEditSheet/IngredientEditSheetFeature.swift`
  - `FeatureIngredients/Sources/IngredientEditSheet/IngredientEditSheetView.swift`
  - `FeatureIngredients/Sources/IngredientDetail/IngredientDetailFeature.swift`
  - `FeatureIngredients/Sources/IngredientDetail/IngredientDetailView.swift`
- 검증:
  - 탭 전환 UI 반영 + 저장 후 카테고리 변경 반영 확인.

### 12) 아카이브 시 Tests/UI Tests 서명 오류 동반 발생
- 증상:
  - `CoachCoachTests` / `CoachCoachUITests`에 development team 관련 서명 에러 노출.
- 원인:
  - 배포 서명 변경 과정에서 테스트 타겟 서명 설정 불일치.
- 해결:
  - 테스트 타겟은 자동 개발 서명으로 유지하고, 앱 타겟 Release만 배포 서명 분리.
- 변경 파일:
  - `CoachCoach/Project.swift`
  - `CoachCoach/CoachCoach.xcodeproj/project.pbxproj` (Tuist generate 결과)
- 검증:
  - `xcodebuild -showBuildSettings` 기준 앱/테스트 타겟 서명 모드 분리 확인.

---

## 참고 링크 (Apple)
- CFBundlePackageType (`APPL`):
  - https://developer.apple.com/library/archive/qa/qa1273/_index.html
  - https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
- 배포 인증서/서명:
  - https://developer.apple.com/help/account/certificates/certificates-overview/
  - https://help.apple.com/xcode/mac/current/en.lproj/devcac6ab5b3.html
- 자동/수동 서명 모드:
  - https://help.apple.com/xcode/mac/current/en.lproj/devff5ececf8.html
  - https://help.apple.com/xcode/mac/current/en.lproj/dev1bf96f17e.html
