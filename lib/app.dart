import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'features/exercises/exercises_screen.dart';
import 'features/history/history_screen.dart';
import 'features/routines/routines_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/shell/scaffold_with_nav.dart';
import 'features/skills/skills_screen.dart';

final _router = GoRouter(
  initialLocation: '/exercicios',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNav(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fichas',
              builder: (context, state) => const RoutinesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exercicios',
              builder: (context, state) => const ExercisesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/skills',
              builder: (context, state) => const SkillsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/historico',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progresso',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Treino',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
