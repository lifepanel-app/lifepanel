import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/comic_theme.dart';
import 'core/router/app_router.dart';

class LifePanelApp extends ConsumerWidget {
  const LifePanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'LifePanel',
      debugShowCheckedModeBanner: false,
      theme: ComicTheme.light,
      darkTheme: ComicTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
