# Project Requirements

## Status Legend
- [ ] 미완료
- [x] 완료

## Feature ↔ API 연결

### 1. Menu (FeatureMenu)
- [x] 메뉴 목록 조회 — `MenuFeature` ↔ `fetchMenuItems`
- [ ] 메뉴 상세 조회 — `MenuDetailFeature`에 `onAppear` + `fetchMenuDetail` 연결
- [x] 메뉴 수정 (이름/가격/카테고리/제조시간) — `MenuEditFeature` ↔ `updateMenu*`
- [x] 메뉴 삭제 — `MenuEditFeature` ↔ `deleteMenu`
- [ ] 메뉴 레시피 목록 조회 — `MenuIngredientsFeature` ↔ `RecipeRepository.fetchRecipes`
- [ ] 메뉴 레시피 추가/삭제 — `MenuIngredientsFeature` ↔ `RecipeRepository.createRecipe*/deleteRecipes`
- [x] 메뉴 생성 — `MenuRegistrationFeature` ↔ `MenuRepository.createMenu`
- [x] 메뉴 추가 UI 진입점 — `MenuView`에 추가 버튼 → `FeatureMenuRegistration` 연결

### 2. Ingredient (FeatureIngredients)
- [x] 재료 목록 조회 — `IngredientsFeature` ↔ `fetchIngredients`
- [x] 재료 검색 — `IngredientSearchFeature` ↔ `searchIngredients` (`/search/my`)
- [x] 재료 상세 조회 — `IngredientDetailFeature` ↔ `fetchIngredientDetail`
- [x] 재료 수정 (가격/수량/단위) — `IngredientDetailFeature` ↔ `updateIngredient`
- [x] 공급처 수정 — `IngredientDetailFeature` ↔ `updateSupplier`
- [ ] 재료 생성 UI + API 연결 — Feature 자체 미구현 (`IngredientsRoute.add` → `EmptyView`)
- [ ] 재료 삭제 UI + API 연결

### 3. Repository 누락 API
- [x] `GET /menus/templates/{templateId}` — 템플릿 기본 정보
- [x] `GET /menus/templates/{templateId}/ingredients` — 템플릿 재료 리스트
- [ ] `GET /ingredients/search` — 재료 통합 검색 (템플릿+유저, DTO 있음, Repository method 없음)

### 4. 미사용 Repository 연결
- [ ] `CategoryRepository` — 어떤 Feature에서도 사용 안 함
- [ ] `RecipeRepository` — 어떤 Feature에서도 사용 안 함

### 5. 기타
- [ ] `IngredientUnit` 확장 — 현재 `ml`, `g`, `개`만 존재. API의 다양한 `unitCode` 대응 필요
- [ ] Home Dashboard (FeatureHome) — 대시보드 UI/데이터
- [ ] AI Coach (FeatureAICoach) — Placeholder 상태
- [ ] Onboarding (FeatureOnboarding) — API 연결 없음
