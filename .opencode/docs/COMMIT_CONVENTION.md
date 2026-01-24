# Commit Convention

## Format
```
[Type] 제목

본문 (선택사항)
```

## Type (대괄호 사용)
- **[Feat]**: 새로운 기능 추가
- **[Fix]**: 버그 수정
- **[Refactor]**: 코드 리팩토링 (기능 변경 없음)
- **[Style]**: 코드 스타일 변경 (포맷팅, 세미콜론 등)
- **[Chore]**: 빌드 설정, 패키지 매니저 등
- **[Docs]**: 문서 수정
- **[Test]**: 테스트 코드 추가/수정
- **[Perf]**: 성능 개선

## 규칙
- **언어**: 한국어로 작성
- **제목**: 명확하고 간결하게
- **본문**: 필요시 상세 설명 추가

## Examples

### Good
```
[Feat] 앱 시작 시 Pretendard 폰트 한 번만 등록

- PretendardTypography에서 CoachCoachApp으로 폰트 등록 이동
- "already exists" 에러 방지
- 앱 라이프사이클 동안 폰트를 한 번만 로드
```

```
[Refactor] 데이터 레이어에 Repository 패턴 도입

- DataLayer 모듈에 Repository 프로토콜 생성
- View의 비즈니스 로직을 Reducer로 이동
- MenuRepository, HomeRepository, IngredientRepository 추가
- TCA Dependencies를 사용한 의존성 주입
```

```
[Fix] CoreData 모듈명을 DataLayer로 변경

Apple CoreData 프레임워크와 모듈명 충돌 해결
```

### Bad
```
수정함
```

```
[Feat] 기능 추가하고 버그 고치고 리팩토링함
```
