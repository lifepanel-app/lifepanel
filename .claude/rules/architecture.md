# Architecture Rules
## Clean Architecture Layers
- Domain layer: entities (freezed), repository contracts (abstract), use cases
- Data layer: models (Isar @collection), datasources, repository implementations
- Presentation layer: providers (Riverpod @riverpod), pages, widgets
## Key Principles
- All 6 life areas share TrackableEntry as the unified base
- Feature folders only contain area-SPECIFIC code (unique entities, pages)
- Common operations (CRUD, filtering, categories) use shared/ code
- Error handling: fpdart Either<Failure, T> across all layers
- DI: get_it for construction-time wiring, Riverpod for runtime state
- Never import data layer from domain layer
- Use cases return Either, never throw
## Comic Component Library
- All UI components live in lib/comic/
- Components are global and reused across all 6 areas
- New components go in comic/widgets/, comic/composites/, or comic/effects/
- Use flutter_animate for animations, not implicit animations
## Naming Conventions
- Files: snake_case.dart
- Classes: PascalCase
- Providers: camelCaseProvider
- Routes: /area/sub-route
- Constants: kConstantName or SCREAMING_CASE for enums