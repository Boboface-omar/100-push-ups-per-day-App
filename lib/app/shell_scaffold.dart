import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_colors.dart';

class AppShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          backgroundColor: AppColors.surface,
          elevation: 0,
          height: 68,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 24),
              selectedIcon: const Icon(Icons.home_rounded, size: 24, color: AppColors.primary),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined, size: 24),
              selectedIcon: const Icon(Icons.insights_rounded, size: 24, color: AppColors.primary),
              label: 'Progression',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded, size: 24),
              selectedIcon: const Icon(Icons.person_rounded, size: 24, color: AppColors.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
