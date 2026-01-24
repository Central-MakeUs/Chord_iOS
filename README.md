# CoachCoach Project Documentation

## Overview
CoachCoach is an iOS application designed to help small business owners analyze profit margins and receive AI-based coaching strategies.

## Documentation Structure
The documentation is managed under the `.opencode` directory to facilitate AI-assisted development.

### 📂 Agents (`.opencode/agents/`)
Persona definitions for AI assistants to maintain consistency.
- **[Requirements Analyzer](.opencode/agents/requirements-analyzer.md)**: Translates requests into TCA specs.
- **[Senior iOS Engineer](.opencode/agents/senior-ios-engineer.md)**: Coding standards for Swift/TCA/Tuist.

### 📂 Docs (`.opencode/docs/`)
Living documentation of the project.
- **[ARCHITECTURE.md](.opencode/docs/ARCHITECTURE.md)**: System design and patterns.
- **[CONVENTIONS.md](.opencode/docs/CONVENTIONS.md)**: Code style and naming rules.
- **[MODULES.md](.opencode/docs/MODULES.md)**: Module responsibilities and details.
- **[REQUIREMENTS.md](.opencode/docs/REQUIREMENTS.md)**: Feature tracking.

### 📂 Skills (`.opencode/skills/`)
Specialized capabilities for the AI agent.
- **[Sync Docs](.opencode/skills/sync-docs/SKILL.md)**: Procedures to keep docs up-to-date.

## Getting Started
1. **Generate Project**: `tuist generate`
2. **Open Workspace**: `open CoachCoach.xcworkspace`
3. **Build**: `Cmd + B`

## Tech Stack
- **iOS**: 16.0+
- **Architecture**: The Composable Architecture (TCA)
- **Modularity**: Tuist
- **UI**: SwiftUI
