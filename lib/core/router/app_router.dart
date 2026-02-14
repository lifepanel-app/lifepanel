import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'route_names.dart';

/// Provides the GoRouter instance via Riverpod.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Main Dashboard (3 slideable screens)
      GoRoute(
        path: '/',
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),

      // Money routes
      GoRoute(
        path: '/money',
        name: RouteNames.money,
        builder: (context, state) => const _StubPage(title: 'Money'),
        routes: [
          GoRoute(
            path: 'add-transaction',
            name: RouteNames.addTransaction,
            builder: (context, state) => const _StubPage(title: 'Add Transaction'),
          ),
          GoRoute(
            path: 'accounts',
            name: RouteNames.accounts,
            builder: (context, state) => const _StubPage(title: 'Accounts'),
          ),
          GoRoute(
            path: 'budget',
            name: RouteNames.budget,
            builder: (context, state) => const _StubPage(title: 'Budget'),
          ),
          GoRoute(
            path: 'investments',
            name: RouteNames.investments,
            builder: (context, state) => const _StubPage(title: 'Investments'),
          ),
          GoRoute(
            path: 'transfer',
            name: RouteNames.transfer,
            builder: (context, state) => const _StubPage(title: 'Transfer'),
          ),
          GoRoute(
            path: 'records',
            name: RouteNames.moneyRecords,
            builder: (context, state) => const _StubPage(title: 'Money Records'),
          ),
          GoRoute(
            path: 'categories',
            name: RouteNames.moneyCategories,
            builder: (context, state) => const _StubPage(title: 'Money Categories'),
          ),
        ],
      ),

      // Fuel routes
      GoRoute(
        path: '/fuel',
        name: RouteNames.fuel,
        builder: (context, state) => const _StubPage(title: 'Fuel'),
        routes: [
          GoRoute(
            path: 'meals',
            name: RouteNames.meals,
            builder: (context, state) => const _StubPage(title: 'Meals'),
          ),
          GoRoute(
            path: 'liquids',
            name: RouteNames.liquids,
            builder: (context, state) => const _StubPage(title: 'Liquids'),
          ),
          GoRoute(
            path: 'supplements',
            name: RouteNames.supplements,
            builder: (context, state) => const _StubPage(title: 'Supplements'),
          ),
          GoRoute(
            path: 'recipes',
            name: RouteNames.recipes,
            builder: (context, state) => const _StubPage(title: 'Recipes'),
          ),
          GoRoute(
            path: 'groceries',
            name: RouteNames.groceries,
            builder: (context, state) => const _StubPage(title: 'Groceries'),
          ),
          GoRoute(
            path: 'prep',
            name: RouteNames.mealPrep,
            builder: (context, state) => const _StubPage(title: 'Meal Prep'),
          ),
          GoRoute(
            path: 'diet',
            name: RouteNames.diet,
            builder: (context, state) => const _StubPage(title: 'Diet'),
          ),
        ],
      ),

      // Work routes
      GoRoute(
        path: '/work',
        name: RouteNames.work,
        builder: (context, state) => const _StubPage(title: 'Work'),
        routes: [
          GoRoute(
            path: 'tasks',
            name: RouteNames.tasks,
            builder: (context, state) => const _StubPage(title: 'Tasks'),
          ),
          GoRoute(
            path: 'clock',
            name: RouteNames.clock,
            builder: (context, state) => const _StubPage(title: 'Clock'),
          ),
          GoRoute(
            path: 'alarms',
            name: RouteNames.alarms,
            builder: (context, state) => const _StubPage(title: 'Alarms'),
          ),
          GoRoute(
            path: 'calendar',
            name: RouteNames.calendar,
            builder: (context, state) => const _StubPage(title: 'Calendar'),
          ),
          GoRoute(
            path: 'career',
            name: RouteNames.career,
            builder: (context, state) => const _StubPage(title: 'Career'),
          ),
        ],
      ),

      // Mind routes
      GoRoute(
        path: '/mind',
        name: RouteNames.mind,
        builder: (context, state) => const _StubPage(title: 'Mind'),
        routes: [
          GoRoute(
            path: 'mood',
            name: RouteNames.mood,
            builder: (context, state) => const _StubPage(title: 'Mood'),
          ),
          GoRoute(
            path: 'journal',
            name: RouteNames.journal,
            builder: (context, state) => const _StubPage(title: 'Journal'),
          ),
          GoRoute(
            path: 'social',
            name: RouteNames.social,
            builder: (context, state) => const _StubPage(title: 'Social'),
          ),
          GoRoute(
            path: 'stress',
            name: RouteNames.stress,
            builder: (context, state) => const _StubPage(title: 'Stress'),
          ),
        ],
      ),

      // Body routes
      GoRoute(
        path: '/body',
        name: RouteNames.body,
        builder: (context, state) => const _StubPage(title: 'Body'),
        routes: [
          GoRoute(
            path: 'sleep',
            name: RouteNames.sleep,
            builder: (context, state) => const _StubPage(title: 'Sleep'),
          ),
          GoRoute(
            path: 'workout',
            name: RouteNames.workout,
            builder: (context, state) => const _StubPage(title: 'Workout'),
          ),
          GoRoute(
            path: 'menstrual',
            name: RouteNames.menstrual,
            builder: (context, state) => const _StubPage(title: 'Menstrual'),
          ),
          GoRoute(
            path: 'skin-hair',
            name: RouteNames.skinHair,
            builder: (context, state) => const _StubPage(title: 'Skin & Hair'),
          ),
          GoRoute(
            path: 'health-records',
            name: RouteNames.healthRecords,
            builder: (context, state) => const _StubPage(title: 'Health Records'),
          ),
        ],
      ),

      // Home routes
      GoRoute(
        path: '/home-life',
        name: RouteNames.homeLife,
        builder: (context, state) => const _StubPage(title: 'Home'),
        routes: [
          GoRoute(
            path: 'car',
            name: RouteNames.car,
            builder: (context, state) => const _StubPage(title: 'Car'),
          ),
          GoRoute(
            path: 'garden',
            name: RouteNames.garden,
            builder: (context, state) => const _StubPage(title: 'Garden'),
          ),
          GoRoute(
            path: 'pets',
            name: RouteNames.pets,
            builder: (context, state) => const _StubPage(title: 'Pets'),
          ),
          GoRoute(
            path: 'cleaning',
            name: RouteNames.cleaning,
            builder: (context, state) => const _StubPage(title: 'Cleaning'),
          ),
          GoRoute(
            path: 'inventory',
            name: RouteNames.homeInventory,
            builder: (context, state) => const _StubPage(title: 'Home Inventory'),
          ),
        ],
      ),
    ],
  );
});

/// Temporary stub page for routes not yet implemented.
class _StubPage extends StatelessWidget {
  final String title;

  const _StubPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\nComing Soon!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
