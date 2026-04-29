import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:operationcore2/component/text/texttitle.dart';
import 'package:operationcore2/page/dashboard.dart';
import 'package:operationcore2/page/monitoringsa.dart';
import 'package:operationcore2/page/productivity.dart';
import 'package:operationcore2/page/saperformance.dart';
import 'package:operationcore2/page/target.dart';
import 'package:operationcore2/page/usermanagement.dart';
import 'package:operationcore2/providers/auth_provider.dart';

class Navigation extends ConsumerStatefulWidget {
  const Navigation({super.key});

  @override
  ConsumerState<Navigation> createState() => _NavigationState();
}

class _NavigationState extends ConsumerState<Navigation> {
  int selectedIndex = 0;

  final pages = [
    Dashboard(),
    Target(),
    Productivity(),
    SAperformance(),
    Monitoringsa(),
    UserManagement(),
  ];
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final String role = user?.role.toUpperCase() ?? '';

    // Define all possible menu items
    final allMenuItems = [
      {'title': 'Dashboard', 'page': Dashboard(), 'roles': ['ADMIN', 'SA', 'CS']},
      {'title': 'Targets', 'page': Target(), 'roles': ['ADMIN']},
      {'title': 'Productivity', 'page': Productivity(), 'roles': ['ADMIN', 'SA', 'CS']},
      {'title': 'SA Performance', 'page': SAperformance(), 'roles': ['SA']},
      {'title': 'Monitoring SA', 'page': Monitoringsa(), 'roles': ['ADMIN', 'SA']},
      {'title': 'User Management', 'page': UserManagement(), 'roles': ['ADMIN']},
    ];

    // Filter menu items based on current user role
    final filteredMenuItems = allMenuItems.where((item) {
      final List<String> allowedRoles = item['roles'] as List<String>;
      return allowedRoles.contains(role);
    }).toList();

    // Ensure selectedIndex doesn't go out of bounds if role changes
    if (selectedIndex >= filteredMenuItems.length) {
      selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Icon(Icons.auto_graph_rounded, color: AppColors.accentBlue),
            const SizedBox(width: 8),

            const Text.rich(
              TextSpan(
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                children: [
                  TextSpan(
                    text: 'OPERATIONS',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'CORE',
                    style: TextStyle(color: AppColors.accentBlue),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 48),

            // Render filtered nav items
            ...filteredMenuItems.asMap().entries.map((entry) {
              return _navItem(entry.value['title'] as String, entry.key);
            }).toList(),

            Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await ref.read(authProvider.notifier).logout();
                  Get.offAllNamed('/login');
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accentBlue,
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Texttitle(message: user?.name ?? "pls login"),
                ],
              ),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text("Logout"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: filteredMenuItems.isNotEmpty
          ? filteredMenuItems[selectedIndex]['page'] as Widget
          : const Center(
              child: Text("No Access", style: TextStyle(color: Colors.white)),
            ),
    );
  }

  Widget _navItem(String title, int index) {
    final bool isActive = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.white : AppColors.textGray,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Container(height: 2, width: 20, color: AppColors.accentBlue),
            ],
          ],
        ),
      ),
    );
  }
}
