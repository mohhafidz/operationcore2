import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:operationcore2/component/target_achievement/skeleton_loader.dart';
import 'package:operationcore2/component/target_achievement/target_achievement_header.dart';
import 'package:operationcore2/component/target_achievement/revenue_trend_card.dart';
import 'package:operationcore2/component/target_achievement/daily_transactions_card.dart';
import 'package:operationcore2/component/target_achievement/weekly_performance_card.dart';
import 'package:operationcore2/providers/target_achievement_provider.dart';

class TargetAchievement extends ConsumerWidget {
  const TargetAchievement({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiStateAsync = ref.watch(targetAchievementUIStateProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1100;

          return uiStateAsync.when(
            loading: () =>
                TargetAchievementLoadingSkeleton(isCompact: isCompact),
            error: (err, stack) => _buildErrorState(context, ref, err, stack),
            data: (uiState) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      TargetAchievementHeader(
                        isCompact: isCompact,
                        availableFilters: uiState.availableFilters,
                        activeFilter: uiState.activeFilter,
                        onFilterChanged: (newSA) {
                          ref
                              .read(selectedSAFilterProvider.notifier)
                              .setFilter(newSA);
                        },
                      ),
                      const SizedBox(height: 24.0),

                      // Trend Chart Card
                      RevenueTrendCard(saData: uiState),
                      const SizedBox(height: 32.0),

                      // Daily Transactions Card
                      DailyTransactionsCard(saData: uiState),
                      const SizedBox(height: 40.0),

                      // Weekly Performance Card
                      WeeklyPerformanceCard(saData: uiState),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
    StackTrace? stack,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B29),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.05),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Gagal Memuat Data",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(targetAchievementDataProvider);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Coba Lagi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
