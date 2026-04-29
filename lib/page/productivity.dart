import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/component/productivity/productivity_table.dart';
import 'package:operationcore2/component/shared/section_header.dart';
import 'package:operationcore2/model/ProductivityField%20.dart';
import 'package:operationcore2/model/alluser.dart';
import 'package:operationcore2/model/tableconfig.dart';
import 'package:operationcore2/providers/dashboard_provider.dart';
import 'package:operationcore2/providers/productifity_provider.dart';
import 'package:operationcore2/providers/auth_provider.dart';
import 'package:operationcore2/utils/calculateMekanikTotals.dart';

final mekanikColumns = [
  TableColumnConfig(label: "STAFF NAME", flex: 3),
  TableColumnConfig(label: "UNIT ENTRY", flex: 1),
  TableColumnConfig(label: "PRODUCTIVITY", flex: 1),
  TableColumnConfig(label: "TARGET", flex: 1),
  TableColumnConfig(label: "TOTAL JASA", flex: 1),
  TableColumnConfig(label: "ACHIEVEMENT", flex: 1),
];

final serviceAdvisorColumns = [
  TableColumnConfig(label: "STAFF NAME", flex: 3),
  TableColumnConfig(label: "UNIT ENTRY", flex: 1),
  TableColumnConfig(label: "PROD", flex: 1),
];

List<TableRowData> _toMekanikRows(
  List<alluser> users,
  int target,
  Map<String, Map<String, dynamic>> productivityData,
  WidgetRef ref,
) {
  return users.map((u) {
    final data = productivityData[u.userId] ?? {};
    final unitEntry = data['unitentry'] ?? 0;
    final totalJasa = data['totaljasa'] ?? 0;
    final workingDay = ref.watch(workingDayProvider);
    final productivity = unitEntry / workingDay;
    final prosantase = totalJasa / target * 100;

    return TableRowData([
      u.name,
      unitEntry.toString(),
      productivity.toString(),
      target.toString(),
      totalJasa.toString(),
      prosantase.toString(),
    ], id: u.userId);
  }).toList();
}

List<TableRowData> _toLeaderRows(
  List<alluser> leaderUsers,
  int target,
  Map<String, Map<String, dynamic>> productivityData,
  List<alluser> mekanikUsers,
  WidgetRef ref,
) {
  final totals = calculateMekanikTotals(mekanikUsers, productivityData);
  final unitEntry = totals['unitEntry'] ?? 0;
  final totalJasa = totals['totalJasa'] ?? 0;
  final workingDay = ref.watch(workingDayProvider);
  final productivity = workingDay == 0 ? 0 : unitEntry / workingDay;
  final prosentase = target == 0 ? 0 : (totalJasa / target * 100);

  return leaderUsers.map((u) {
    return TableRowData([
      u.name,
      unitEntry.toString(),
      productivity.toStringAsFixed(2),
      target.toString(),
      totalJasa.toString(),
      prosentase.toStringAsFixed(2),
    ], id: u.userId);
  }).toList();
}

List<TableRowData> _toSaRows(
  List<alluser> users,
  Map<String, Map<String, dynamic>> productivityData,
  WidgetRef ref,
) {
  return users.map((u) {
    final data = productivityData[u.userId] ?? {};
    final unitEntry = data['unitentry'] ?? 0;
    final workingDay = ref.watch(workingDayProvider);
    final productivity = unitEntry / workingDay;

    return TableRowData([
      u.name,
      unitEntry.toString(),
      productivity.toString(),
    ], id: u.userId);
  }).toList();
}

class Productivity extends ConsumerStatefulWidget {
  const Productivity({super.key});

  @override
  ConsumerState<Productivity> createState() => _ProductivityState();
}

class _ProductivityState extends ConsumerState<Productivity> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersGroupedByRoleProvider);
    final targetAsync = ref.watch(targetProvider);
    final productivityAsync = ref.watch(productivityProvider);
    final currentUser = ref.watch(authProvider).user;

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Error: $err',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
      data: (groupedUsers) {
        final mekanikUsers = groupedUsers['MK'] ?? [];
        final leaderUsers = groupedUsers['LD'] ?? [];
        final csUsers = groupedUsers['CS'] ?? [];
        final target = targetAsync.asData?.value ?? 0;
        final productivityData = productivityAsync.asData?.value ?? {};
        final leaderTarget = target * mekanikUsers.length;

        bool canEdit(String? rowUserId) {
          if (currentUser == null) return false;
          final role = currentUser.role.toUpperCase();
          if (role == 'ADMIN') return false;
          if (role == 'SA') return true;
          return currentUser.id == rowUserId;
        }

        void handleEdit(String columnLabel, String? userId) {
          if (!canEdit(userId)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Anda tidak memiliki izin untuk mengedit data ini",
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          showNumberInputDialog(
            columnLabel: columnLabel,
            userId: userId,
            ref: ref,
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              children: [
                _ProductivitySection(
                  title: "MEKANIK",
                  indicatorColor: Colors.blue,
                  columns: mekanikColumns,
                  rows: _toMekanikRows(
                    mekanikUsers,
                    target,
                    productivityData,
                    ref,
                  ),
                  editableColumnLabels: const ['UNIT ENTRY', 'TOTAL JASA'],
                  onEdit: handleEdit,
                  canEdit: canEdit,
                ),
                const SizedBox(height: 40),
                _ProductivitySection(
                  title: "LEADER",
                  indicatorColor: Colors.orange,
                  columns: mekanikColumns,
                  rows: _toLeaderRows(
                    leaderUsers,
                    leaderTarget,
                    productivityData,
                    mekanikUsers,
                    ref,
                  ),
                  onEdit: handleEdit,
                  canEdit: canEdit,
                ),
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ProductivitySection(
                        title: "CS SERVICE",
                        indicatorColor: Colors.purple,
                        columns: serviceAdvisorColumns,
                        rows: _toSaRows(csUsers, productivityData, ref),
                        editableColumnLabels: const ['UNIT ENTRY'],
                        onEdit: handleEdit,
                        canEdit: canEdit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Section productivity dengan header + tabel (menggunakan komponen reusable)
class _ProductivitySection extends StatelessWidget {
  final String title;
  final Color indicatorColor;
  final List<TableColumnConfig> columns;
  final List<TableRowData> rows;
  final List<String> editableColumnLabels;
  final void Function(String columnLabel, String? userId)? onEdit;
  final bool Function(String? userId) canEdit;

  const _ProductivitySection({
    required this.title,
    required this.indicatorColor,
    required this.columns,
    required this.rows,
    this.editableColumnLabels = const [],
    this.onEdit,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        SectionHeader(title: title, indicatorColor: indicatorColor),
        ProductivityTable(
          columns: columns,
          rows: rows,
          editableColumnLabels: editableColumnLabels,
          onEdit: onEdit,
          canEdit: canEdit,
        ),
      ],
    );
  }
}
