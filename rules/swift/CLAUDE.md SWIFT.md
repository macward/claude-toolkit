# Project Guidelines

## Tech Stack

- Swift 6
- SwiftUI
- @Observable for state management

## Project Structure

Feature-based folder structure:

```swift
App/
├── App/
│   ├── MyAppApp.swift
│   └── Configuration/
├── Features/
│   ├── Auth/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Repositories/
│   │   └── Models/
│   ├── Home/
│   └── Settings/
├── Shared/
│   ├── Services/
│   ├── Components/
│   ├── Extensions/
│   └── Models/
├── Navigation/
└── Resources/
```

- Each feature contains only what it needs
- Shared/ is for code used by 2+ features
- Simple features don't need subfolders

## Architecture & Patterns

### Layers

```bash
View → ViewModel (when needed) → Repository → Service/Database
```

### ViewModels

- Use ViewModel when the view has complex logic, multiple states, or needs unit testing
- Simple views can use @State + @Environment directly without ViewModel
- One ViewModel per root screen
- ALWAYS use final class
- Do NOT import SwiftUI unless strictly necessary for navigation types
- NEVER put business logic directly in Views

### Dependency Injection

- ALWAYS use @Environment for sharing services and state across views
- NEVER use singletons or shared instances
- Inject dependencies at the App root level
- ViewModels receive dependencies via init injection

### Async/Await

- ALWAYS use async/await, NEVER completion handlers
- ALWAYS mark ViewModels with @MainActor
- Use .task modifier for async work in Views
- Use AsyncStream for continuous data streams (WebSockets, listeners, delegate conversions)
- NEVER use DispatchQueue.main.async — use MainActor instead
- NEVER use try! in async code

### Error Handling

- ViewModels catch errors and expose state (error property)
- Do NOT propagate errors to Views with throws
- Views react to error state, they don't handle errors directly

### Task Cancellation

- .task modifier handles cancellation automatically when View disappears
- For long loops or operations, check Task.isCancelled or use try Task.checkCancellation()
- AsyncStream MUST handle cleanup in onTermination

### Navigation

- Navigation approach is not yet defined
- When implementing navigation, prefer solutions that:
  - Use NavigationStack with path binding
  - Support deep linking
  - Keep navigation state centralized
  - Are compatible with @Observable

### Naming Conventions

- ALWAYS use full names, never abbreviations
- Views: `HomeView`, `LoginView`
- ViewModels: `HomeViewModel`, `LoginViewModel`
- Repositories: `UserRepository`, `AuthRepository`
- Services: `APIService`, `StorageService`

### Patterns to Avoid

- Completion handlers
- `DispatchQueue.main.async`
- `Task { @MainActor in }` when already on MainActor
- `.task` with nested `Task { }` inside
- Force try (`try!`) in async code
- Singletons or shared instances

## Code Style

### Formatting

- Use guard for early exit
- Explicit type annotations: `let value: String = "text"`
- Use trailing closure only for single closure, not multiple
- Use self only when required (closures, ambiguity)
- Use optional shorthand: `if let value { }` not `if let value = value { }`
- ALWAYS mark access control explicitly on all types and members (public, internal, private)

### File Organization

- Use `// MARK: -` to separate sections (Properties, Lifecycle, Public Methods, Private Methods)
- Separate protocol conformances into extensions

### Tooling

- Use SwiftLint with default rules

## Testing Guidelines

### Framework

- Use Swift Testing (@Test), not XCTest

### Naming

- Function names: `subjectAction` or `subjectActionCondition`
- ALWAYS add descriptive string to @Test macro

```swift
@Test("User login fails when password is empty")
func userLoginFailsEmptyPassword() async throws { 
	// this is a nice way to check how it works
}
```

### Mocks

- Use protocols for dependencies
- Create manual mock implementations for tests
- Do NOT use mocking libraries

### Coverage

- ALWAYS test ViewModels
- ALWAYS test Repositories
- Services: test only if they contain logic
- Do NOT write unit tests for Views

## Build & Run Commands

- ` xcodebuild -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build ` - Build project
- ` xcodebuild -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test ` - Run tests
- ` swiftlint ` - Run linter

## Git & Workflow

### Branch Naming

- `feature/short-description`
- `fix/short-description`
- `refactor/short-description`

### Commits

Use conventional commits:

- `feat:` new feature
- `fix:` bug fix
- `refactor:` code restructure
- `test:` adding tests
- `docs:` documentation
- `chore:` maintenance

### Merge Strategy

- Squash merge PRs to keep main history clean

## Common Patterns & Examples

Reference implementations are in `.claude/examples/` — consult these when creating new Views, ViewModels, Repositories, or Services.

## Known Issues & Gotchas

<!-- Add project-specific issues, workarounds, and warnings here -->