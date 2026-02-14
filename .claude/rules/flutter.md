# Flutter Rules
## State Management
- Use Riverpod 3 with @riverpod annotation (codegen)
- Prefer ConsumerWidget over Consumer
- Use ref.watch for reactive, ref.read for one-time
- AsyncValue for loading/error/data states
- Never use setState in ConsumerWidget
## Isar Database
- All collections use @collection annotation
- Use composite indexes for common query patterns
- Wrap Isar operations in try-catch, return Either
- Open Isar once in bootstrap, close on app terminate
- Use writeTxn for writes, read operations outside txn
## Routing
- GoRouter with named routes (RouteNames constants)
- Use context.go for replacement, context.push for stack
- All routes defined in app_router.dart
## Theme
- Always use Theme.of(context) or context.theme extension
- Comic fonts: Bangers for headers, ComicNeue for body
- Bold borders (2-3px), drop shadows, halftone backgrounds
- Use ComicColors constants, never hardcode colors
## Widget Rules
- Prefer const constructors
- Extract widgets into separate files at ~100 lines
- Use named parameters for clarity
- Always handle loading, error, and empty states
- Use comic_empty_state.dart for empty states
- Use comic_loading.dart for loading states
## Testing
- Unit tests for repositories and use cases
- Widget tests for comic components
- Use mocktail for mocking (not mockito)
- Test file mirrors lib/ structure in test/