import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/life_areas.dart';
import '../../../../core/theme/comic_colors.dart';

/// Main dashboard with 3 slideable screens.
///
/// Screen 1 (left): Yoga figure with 6 progress pies
/// Screen 2 (center): 6 area partitions with overview charts
/// Screen 3 (right): Daily feed — notifications, todos, time-grouped cards
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? ComicColors.secondary
                          : ComicColors.halftone,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: ComicColors.outline,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // 3 slideable screens
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  _YogaProgressScreen(),
                  _OverviewScreen(),
                  _DailyFeedScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 1: Yoga figure surrounded by 6 progress pies.
/// TODO: Replace with Flame GameWidget + Rive yoga figure in Phase 8.
class _YogaProgressScreen extends StatelessWidget {
  const _YogaProgressScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PROGRESS',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),
          // Placeholder for yoga figure + 6 pies
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ComicColors.outline, width: 3),
              color: ComicColors.surface,
            ),
            child: const Center(
              child: Text(
                '🧘',
                style: TextStyle(fontSize: 80),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 6 mini progress indicators
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: LifeArea.values.map((area) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: area.color.withValues(alpha: 0.15),
                      border: Border.all(color: area.color, width: 2.5),
                    ),
                    child: Icon(area.icon, color: area.color, size: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    area.label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Screen 2 (center/home): 6 partitions with overview chart of each area.
class _OverviewScreen extends StatelessWidget {
  const _OverviewScreen();

  static const _areaPaths = {
    LifeArea.money: '/money',
    LifeArea.fuel: '/fuel',
    LifeArea.work: '/work',
    LifeArea.mind: '/mind',
    LifeArea.body: '/body',
    LifeArea.home: '/home-life',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'LIFEPANEL',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: LifeArea.values.map((area) {
                return GestureDetector(
                  onTap: () => context.push(_areaPaths[area]!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: area.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ComicColors.outline,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ComicColors.shadow.withValues(alpha: 0.15),
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(area.icon, color: area.color, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          area.label,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: area.color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to explore',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen 3: Daily feed — notifications/todos grouped by time of day.
class _DailyFeedScreen extends StatelessWidget {
  const _DailyFeedScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildTimeSection(context, 'Morning', Icons.wb_sunny),
                _buildTimeSection(context, 'Afternoon', Icons.light_mode),
                _buildTimeSection(context, 'Evening', Icons.nights_stay),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: ComicColors.textSecondary),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ComicColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ComicColors.outline, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ComicColors.shadow.withValues(alpha: 0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              'No items yet. Start tracking to see your daily feed!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ComicColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
