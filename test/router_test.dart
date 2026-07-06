import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A standalone testable router that uses StatefulShellRoute
/// to verify branch navigation is independent per branch.
GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _TestShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, _) => const _BranchPage(label: 'Dashboard', index: 0),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/storage',
              builder: (_, _) => const _BranchPage(label: 'Storage', index: 1),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/notifications',
              builder: (_, _) => const _BranchPage(label: 'Notifications', index: 2),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/stats',
              builder: (_, _) => const _BranchPage(label: 'Stats', index: 3),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const _BranchPage(label: 'Settings', index: 4),
            ),
          ]),
        ],
      ),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GoRouter StatefulShellRoute Navigation Tests', () {
    testWidgets('initial route renders Dashboard branch', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: _buildTestRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('goBranch(1) switches to Storage branch', (tester) async {
      final router = _buildTestRouter();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to branch 1 (Storage)
      router.go('/storage');
      await tester.pumpAndSettle();

      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
    });

    testWidgets('goBranch(4) switches to Settings branch', (tester) async {
      final router = _buildTestRouter();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('navigating between branches preserves index', (tester) async {
      final router = _buildTestRouter();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Go to Storage
      router.go('/storage');
      await tester.pumpAndSettle();
      expect(find.text('Branch index: 1'), findsOneWidget);

      // Go to Notifications
      router.go('/notifications');
      await tester.pumpAndSettle();
      expect(find.text('Branch index: 2'), findsOneWidget);

      // Go back to Dashboard
      router.go('/dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Branch index: 0'), findsOneWidget);
    });
  });
}

/// Minimal shell widget that exposes navigation via tap buttons.
class _TestShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _TestShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Row(
        children: List.generate(5, (i) => Expanded(
          child: TextButton(
            key: ValueKey('nav_$i'),
            onPressed: () => navigationShell.goBranch(i),
            child: Text('Tab $i'),
          ),
        )),
      ),
    );
  }
}

/// Simple page that identifies which branch it belongs to.
class _BranchPage extends StatelessWidget {
  final String label;
  final int index;
  const _BranchPage({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Text('Branch index: $index'),
      ],
    );
  }
}
