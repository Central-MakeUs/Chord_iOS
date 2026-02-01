# Project Documentation

## Root
- `README.md` - Project overview

## Backend Server Reference
API 구현 시 서버 프로젝트를 참조하여 정확한 비즈니스 로직과 데이터 구조를 확인할 것.

- **경로**: `/Users/seungwan/xcode/Chord_Server`
- **구조**: Spring Boot (Java) 멀티 모듈 Gradle 프로젝트
- **Base URL**: `http://3.36.186.131`
- **Swagger**: `http://3.36.186.131/swagger-ui/index.html`
- **OpenAPI**: `http://3.36.186.131/v3/api-docs`

### 주요 모듈
| 모듈 | 경로 | 설명 |
|---|---|---|
| `catalog` | `coachcoach/catalog/` | 메뉴/재료/레시피 CRUD (핵심 비즈니스 로직) |
| `insight` | `coachcoach/insight/` | AI 코칭/분석 |
| `user` | `coachcoach/user/` | 사용자 관리 |
| `common` | `coachcoach/common/` | 공통 에러 처리, API 응답 래핑 |

### 참조 용도
- **Controller**: `catalog/src/main/java/.../api/CatalogController.java` — API endpoint 정의 및 파라미터 확인
- **Service**: `catalog/src/main/java/.../service/MenuService.java`, `IngredientService.java` — 비즈니스 로직 (원가율 계산, 마진 등급 등)
- **Entity**: `catalog/src/main/java/.../domain/entity/` — DB 스키마 및 필드 타입 확인
- **Request/Response**: `catalog/src/main/java/.../api/request/`, `.../api/response/` — DTO 필드 정확도 검증

## OpenCode Configuration (`.opencode/`)

### Agents
- `.opencode/agents/senior-ios-engineer.md` - iOS development expert agent (TCA/Tuist)
- `.opencode/agents/requirements-analyzer.md` - Requirements analysis agent

### Documentation
- `.opencode/docs/ARCHITECTURE.md` - Architecture decisions and patterns
- `.opencode/docs/CONVENTIONS.md` - Code conventions and style guide
- `.opencode/docs/COMMIT_CONVENTION.md` - Git commit message guidelines
- `.opencode/docs/MODULES.md` - Module structure and dependencies
- `.opencode/docs/REQUIREMENTS.md` - Project requirements

### Skills
- `.opencode/skills/sync-docs/SKILL.md` - Documentation sync skill
