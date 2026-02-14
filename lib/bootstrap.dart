import 'core/di/injection_container.dart';

/// Initialize all app dependencies before runApp.
Future<void> bootstrap() async {
  // Initialize dependency injection (get_it)
  await initDependencies();

  // TODO: Initialize Isar database
  // TODO: Seed default categories on first launch
  // TODO: Process recurring rules on app open
  // TODO: Check for smart recovery (missed days)
}
