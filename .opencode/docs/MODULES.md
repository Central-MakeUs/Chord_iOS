# Module Documentation

## CoachCoach (App)
### Purpose
앱의 진입점이자 최상위 모듈입니다.
### Responsibilities
- `CoachCoachApp.swift`: 앱 라이프사이클 관리
- `RootFeature`: 탭 네비게이션 및 최상위 상태 관리
- 모든 Feature 모듈을 통합

---

## FeatureMenu
### Purpose
메뉴 관리 기능 (목록, 상세, 등록, 수정)
### Responsibilities
- `MenuList`: 메뉴 목록 조회 및 필터링
- `MenuDetail`: 메뉴 상세 정보 및 레시피 확인
- `MenuEdit`: 메뉴 정보 수정 (가격, 원가 등)
- `PrepareTimeSheet`: 제조 시간 설정 시트 (UIKit wheel picker + custom selection bar)
- `MenuIngredients`: 메뉴에 들어가는 재료 관리

### Dependencies
- `CoreModels`: 메뉴 데이터 모델
- `DesignSystem`: UI 컴포넌트
- `DataLayer`: 메뉴 데이터 CRUD

---

## FeatureIngredients
### Purpose
재료 관리 기능
### Responsibilities
- `IngredientList`: 재료 목록 및 재고 확인
- `IngredientDetail`: 재료 상세 정보 및 수정
- `IngredientEdit`: 재료 정보(단위, 가격 등) 수정

---

## FeatureHome
### Purpose
홈 화면 대시보드
### Responsibilities
- 오늘의 요약 정보 표시
- 주요 기능 바로가기

---

## DesignSystem
### Purpose
앱 전반의 통일된 UI/UX를 위한 컴포넌트 라이브러리
### Components
- `BottomButton`: 하단 고정 버튼
- `CoachCoachAlert`: 커스텀 알럿
- `RadioIndicator`: 라디오 버튼 UI
- `Colors`: `AppColor` (Primary, Grayscale 등)
- `Fonts`: `Pretendard` 폰트 시스템

---

## DataLayer
### Purpose
데이터 저장 및 로드 (Repository Pattern 유사)
### Responsibilities
- `MenuClient`: 메뉴 데이터 CRUD 인터페이스 및 구현
- `IngredientClient`: 재료 데이터 CRUD
- API 통신 또는 로컬 DB(SwiftData/Realm) 연동

---

## CoreModels
### Purpose
앱 전반에서 공유되는 도메인 모델
### Models
- `MenuItem`: 메뉴 정보
- `Ingredient`: 재료 정보
- `MenuCategory`: 메뉴 카테고리 (음료, 푸드 등)
- `MenuStatus`: 마진율 상태 (위험, 주의, 양호)

---

## CoreCommon
### Purpose
공통 유틸리티 및 익스텐션
### Contents
- `String+Extension`: 포맷팅 등
- `Date+Extension`: 날짜 처리
- `Constants`: 전역 상수
