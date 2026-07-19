import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.ink, width: 2.5)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.list_alt_rounded), label: 'Treinos'),
            NavigationDestination(
                icon: Icon(Icons.fitness_center_rounded), label: 'Exercícios'),
            NavigationDestination(
                icon: Icon(Icons.emoji_events_rounded), label: 'Skills'),
            NavigationDestination(
                icon: Icon(Icons.history_rounded), label: 'Histórico'),
            NavigationDestination(
                icon: Icon(Icons.show_chart_rounded), label: 'Progresso'),
          ],
        ),
      ),
    );
  }
}
