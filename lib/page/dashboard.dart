import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/dashboard/category_progress_bar.dart';
import 'package:operationcore2/component/dashboard/circular_gauge.dart';
import 'package:operationcore2/component/dashboard/detail_table_row.dart';
import 'package:operationcore2/component/dashboard/working_day_card.dart';
import 'package:operationcore2/component/shared/app_text.dart';
import 'package:operationcore2/component/shared/section_header.dart';
import 'package:operationcore2/model/tabledetailperformance.dart';
import 'package:operationcore2/providers/dashboard_provider.dart';
import 'package:operationcore2/utils/gettrend.dart';
import 'package:operationcore2/utils/dashboard_calculations.dart';
import 'package:operationcore2/utils/number_formatter.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workingDay = ref.watch(workingDayProvider);
    final dayController = TextEditingController(text: workingDay.toString());
    final data = ref.watch(dashboardProvider);

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ROW CIRCULAR GAUGES
            Align(
              alignment: AlignmentGeometry.center,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: data.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text("Error: $e"),
                    data: (d) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          WorkingDayCard(controller: dayController),
                          CircularGauge(
                            percentage: d.siuAchv,
                            label: "SIU ACHV",
                          ),
                          CircularGauge(
                            percentage: d.jasaAchv,
                            label: "JASA ACHV",
                          ),
                          CircularGauge(
                            percentage: d.oilAchv,
                            label: "OIL ACHV",
                          ),
                          CircularGauge(
                            percentage: d.partAchv,
                            label: "PART ACHV",
                          ),
                          CircularGauge(
                            percentage: d.soAchv,
                            label: "SO ACHV",
                          ),
                          CircularGauge(
                            percentage: d.smAchv,
                            label: "SM ACHV",
                          ),
                          CircularGauge(
                            percentage: d.bookingAchv,
                            label: "BOOKING ACHV",
                          ),
                          CircularGauge(
                            percentage: d.totalAchv,
                            label: "TOTAL",
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
            _CategoryPerformanceSection(ref: ref),
            const SizedBox(height: 50),
            _DetailPerformanceSection(ref: ref),
          ],
        ),
      ),
    );
  }
}

/// Section Category Performance dengan GridView progress bar
class _CategoryPerformanceSection extends StatelessWidget {
  final WidgetRef ref;

  const _CategoryPerformanceSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dashboardProvider);

    return CardCustume(
      padding: 20,
      widget: data.when(
        data: (d) {
          return Column(
            children: [
              const CardSectionHeader(
                title: "Category Performance Comparison",
                subtitle: "Actual (Total s/d Hari Ini) vs Target Monthly",
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 40,
                mainAxisSpacing: 24,
                childAspectRatio: 10,
                children: [
                  CategoryProgressBar(
                    current: d.siuActual,
                    target: d.siuTarget,
                    label: "SIU (UNITS)",
                    color: const Color(0xff3B82F6),
                  ),
                  CategoryProgressBar(
                    current: d.oilActual,
                    target: d.oilTarget,
                    label: "OIL (Revenue)",
                    color: const Color(0xff00F2FF),
                  ),
                  CategoryProgressBar(
                    current: d.sorderActual,
                    target: d.sorderTarget,
                    label: "S/ORDER (Revenue)",
                    color: const Color(0xff34D399),
                  ),
                  CategoryProgressBar(
                    current: d.jasaActual,
                    target: d.jasaTarget,
                    label: "JASA (Revenue)",
                    color: const Color(0xff10B981),
                  ),
                  CategoryProgressBar(
                    current: d.partActual,
                    target: d.partTarget,
                    label: "PART (Revenue)",
                    color: const Color(0xff3B82F6),
                  ),
                  CategoryProgressBar(
                    current: d.materialActual,
                    target: d.materialTarget,
                    label: "MATERIAL (Revenue)",
                    color: const Color(0xffF59E0B),
                  ),
                  CategoryProgressBar(
                    current: d.bookingActual,
                    target: d.bookingTarget,
                    label: "BOOKING",
                    color: const Color(0xff10B981),
                  ),
                  CategoryProgressBar(
                    current: d.totalActual,
                    target: d.totalTarget,
                    label: "TOTAL",
                    color: const Color(0xff00F2FF),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Text("Error: $e"),
      ),
    );
  }
}

/// Section Detail Performance Breakdown table
class _DetailPerformanceSection extends StatelessWidget {
  final WidgetRef ref;

  const _DetailPerformanceSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dashboardProvider);
    final sisaHari = ref.watch(remainingWorkingDayProvider);
    final workingDay = ref.watch(workingDayProvider);
    final totalWorkingDay = ref.watch(totalWorkingDayProvider);
    final databulansebelum = ref.watch(databulansebelumProvider);
    final datatahunsebelum = ref.watch(datatahunsebelumProvider);

    return data.when(
      data: (data) {
        final siuResults = DashboardCalculations.calculateMetric(
          actual: data.siuActual,
          target: data.siuTarget,
          prevMonth: databulansebelum.value?.siu ?? 0,
          prevYear: datatahunsebelum.value?.siu ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );
        final jasaResults = DashboardCalculations.calculateMetric(
          actual: data.jasaActual,
          target: data.jasaTarget,
          prevMonth: databulansebelum.value?.jasa ?? 0,
          prevYear: datatahunsebelum.value?.jasa ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );
        final oilResults = DashboardCalculations.calculateMetric(
          actual: data.oilActual,
          target: data.oilTarget,
          prevMonth: databulansebelum.value?.oil ?? 0,
          prevYear: datatahunsebelum.value?.oil ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );
        final partResults = DashboardCalculations.calculateMetric(
          actual: data.partActual,
          target: data.partTarget,
          prevMonth: databulansebelum.value?.part ?? 0,
          prevYear: datatahunsebelum.value?.part ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );
        final sorderResults = DashboardCalculations.calculateMetric(
          actual: data.sorderActual,
          target: data.sorderTarget,
          prevMonth: databulansebelum.value?.so ?? 0,
          prevYear: datatahunsebelum.value?.so ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );
        final materialResults = DashboardCalculations.calculateMetric(
          actual: data.materialActual,
          target: data.materialTarget,
          prevMonth: databulansebelum.value?.sm ?? 0,
          prevYear: datatahunsebelum.value?.sm ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );
        final totalResults = DashboardCalculations.calculateMetric(
          actual: data.totalActual,
          target: data.totalTarget,
          prevMonth: databulansebelum.value?.total ?? 0,
          prevYear: datatahunsebelum.value?.total ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );
        final bookingResults = DashboardCalculations.calculateMetric(
          actual: data.bookingActual,
          target: data.bookingTarget,
          prevMonth: databulansebelum.value?.booking ?? 0,
          prevYear: datatahunsebelum.value?.booking ?? 0,
          totalWorkingDays: totalWorkingDay,
          daysElapsed: workingDay,
          remainingWorkingDays: sisaHari,
        );

        final trendLastMonth = getOverallTrend([
          siuResults.growthMonth,
          jasaResults.growthMonth,
          oilResults.growthMonth,
          partResults.growthMonth,
          sorderResults.growthMonth,
          materialResults.growthMonth,
          totalResults.growthMonth,
          bookingResults.growthMonth,
        ]);

        final trendLastYear = getOverallTrend([
          siuResults.growthYear,
          jasaResults.growthYear,
          oilResults.growthYear,
          partResults.growthYear,
          sorderResults.growthYear,
          materialResults.growthYear,
          totalResults.growthYear,
          bookingResults.growthYear,
        ]);

        return CardCustume(
          padding: 20,
          widget: Column(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    "DETAILED PERFORMANCE BREAKDOWN",
                    color: Color(0xff94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  Row(
                    children: [
                      LegendIndicator(
                        label: "Positive Growth",
                        color: const Color(0xff10B981),
                      ),
                      const SizedBox(width: 20),
                      LegendIndicator(
                        label: "Target Gap",
                        color: const Color(0xffF43F5E),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(color: Colors.white.withOpacity(.1)),
              const SizedBox(height: 10),

              DetailTableRow(
                metric: "METRIC",
                isHeader: true,
                values: const [
                  TableValue("SIU"),
                  TableValue("JASA"),
                  TableValue("OIL"),
                  TableValue("PART"),
                  TableValue("S/ORDER"),
                  TableValue("MATERIAL"),
                  TableValue("TOTAL"),
                  TableValue("BOOKING"),
                  TableValue("TREND"),
                ],
              ),

              DetailTableRow(
                metric: "HARI INI",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(data.dailySiu)}"),
                  TableValue("${numberFormatter.format(data.dailyJasa)}"),
                  TableValue("${numberFormatter.format(data.dailyOil)}"),
                  TableValue("${numberFormatter.format(data.dailyPart)}"),
                  TableValue("${numberFormatter.format(data.dailySorder)}"),
                  TableValue("${numberFormatter.format(data.dailyMaterial)}"),
                  TableValue("${numberFormatter.format(data.dailyTotal)}"),
                  TableValue("${numberFormatter.format(data.dailyBooking)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "TOTAL S/D HARI INI",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(data.siuActual)}"),
                  TableValue("${numberFormatter.format(data.jasaActual)}"),
                  TableValue("${numberFormatter.format(data.oilActual)}"),
                  TableValue("${numberFormatter.format(data.partActual)}"),
                  TableValue("${numberFormatter.format(data.sorderActual)}"),
                  TableValue("${numberFormatter.format(data.materialActual)}"),
                  TableValue("${numberFormatter.format(data.totalActual)}"),
                  TableValue("${numberFormatter.format(data.bookingActual)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "TARGET",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(data.siuTarget)}"),
                  TableValue("${numberFormatter.format(data.jasaTarget)}"),
                  TableValue("${numberFormatter.format(data.oilTarget)}"),
                  TableValue("${numberFormatter.format(data.partTarget)}"),
                  TableValue("${numberFormatter.format(data.sorderTarget)}"),
                  TableValue("${numberFormatter.format(data.materialTarget)}"),
                  TableValue("${numberFormatter.format(data.totalTarget)}"),
                  TableValue("${numberFormatter.format(data.bookingTarget)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "% (ACHIEVEMENT)",
                dynamicColor: true,
                values: [
                  TableValue("${numberFormatter.format(siuResults.achievementPercentage)}%"),
                  TableValue("${numberFormatter.format(jasaResults.achievementPercentage)}%"),
                  TableValue("${numberFormatter.format(oilResults.achievementPercentage)}%"),
                  TableValue("${numberFormatter.format(partResults.achievementPercentage)}%"),
                  TableValue("${numberFormatter.format(sorderResults.achievementPercentage)}%"),
                  TableValue("${numberFormatter.format(materialResults.achievementPercentage)}%"),
                  TableValue("${numberFormatter.format(totalResults.achievementPercentage)}%"),
                  TableValue("${numberFormatter.format(bookingResults.achievementPercentage)}%"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "AVERAGE PER HARI",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(siuResults.averagePerHari)}"),
                  TableValue("${numberFormatter.format(jasaResults.averagePerHari)}"),
                  TableValue("${numberFormatter.format(oilResults.averagePerHari)}"),
                  TableValue("${numberFormatter.format(partResults.averagePerHari)}"),
                  TableValue("${numberFormatter.format(sorderResults.averagePerHari)}"),
                  TableValue("${numberFormatter.format(materialResults.averagePerHari)}"),
                  TableValue("${numberFormatter.format(totalResults.averagePerHari)}"),
                  TableValue("${numberFormatter.format(bookingResults.averagePerHari)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "SISA TARGET KE 100%",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(siuResults.sisaTargetValue)}"),
                  TableValue("${numberFormatter.format(jasaResults.sisaTargetValue)}"),
                  TableValue("${numberFormatter.format(oilResults.sisaTargetValue)}"),
                  TableValue("${numberFormatter.format(partResults.sisaTargetValue)}"),
                  TableValue("${numberFormatter.format(sorderResults.sisaTargetValue)}"),
                  TableValue("${numberFormatter.format(materialResults.sisaTargetValue)}"),
                  TableValue("${numberFormatter.format(totalResults.sisaTargetValue)}"),
                  TableValue("${numberFormatter.format(bookingResults.sisaTargetValue)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "SISA TARGET /HARI",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(siuResults.sisaTargetPerHari)}"),
                  TableValue("${numberFormatter.format(jasaResults.sisaTargetPerHari)}"),
                  TableValue("${numberFormatter.format(oilResults.sisaTargetPerHari)}"),
                  TableValue("${numberFormatter.format(partResults.sisaTargetPerHari)}"),
                  TableValue("${numberFormatter.format(sorderResults.sisaTargetPerHari)}"),
                  TableValue("${numberFormatter.format(materialResults.sisaTargetPerHari)}"),
                  TableValue("${numberFormatter.format(totalResults.sisaTargetPerHari)}"),
                  TableValue("${numberFormatter.format(bookingResults.sisaTargetPerHari)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "MAKS ACHV BASED ON AVERAGE",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(siuResults.maksAchvValue)}"),
                  TableValue("${numberFormatter.format(jasaResults.maksAchvValue)}"),
                  TableValue("${numberFormatter.format(oilResults.maksAchvValue)}"),
                  TableValue("${numberFormatter.format(partResults.maksAchvValue)}"),
                  TableValue("${numberFormatter.format(sorderResults.maksAchvValue)}"),
                  TableValue("${numberFormatter.format(materialResults.maksAchvValue)}"),
                  TableValue("${numberFormatter.format(totalResults.maksAchvValue)}"),
                  TableValue("${numberFormatter.format(bookingResults.maksAchvValue)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "MAKS ACHV (%)",
                dynamicColor: true,
                values: [
                  TableValue("${numberFormatter.format(siuResults.maksAchvPercentage)}%"),
                  TableValue("${numberFormatter.format(jasaResults.maksAchvPercentage)}%"),
                  TableValue("${numberFormatter.format(oilResults.maksAchvPercentage)}%"),
                  TableValue("${numberFormatter.format(partResults.maksAchvPercentage)}%"),
                  TableValue("${numberFormatter.format(sorderResults.maksAchvPercentage)}%"),
                  TableValue("${numberFormatter.format(materialResults.maksAchvPercentage)}%"),
                  TableValue("${numberFormatter.format(totalResults.maksAchvPercentage)}%"),
                  TableValue("${numberFormatter.format(bookingResults.maksAchvPercentage)}%"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "TARGET HARIAN MINIMAL (BUDGET)",
                color: const Color(0xff22D3EE),
                values: [
                  TableValue("${numberFormatter.format(siuResults.dailyBudget)}"),
                  TableValue("${numberFormatter.format(jasaResults.dailyBudget)}"),
                  TableValue("${numberFormatter.format(oilResults.dailyBudget)}"),
                  TableValue("${numberFormatter.format(partResults.dailyBudget)}"),
                  TableValue("${numberFormatter.format(sorderResults.dailyBudget)}"),
                  TableValue("${numberFormatter.format(materialResults.dailyBudget)}"),
                  TableValue("${numberFormatter.format(totalResults.dailyBudget)}"),
                  TableValue("${numberFormatter.format(bookingResults.dailyBudget)}"),
                  const TableValue(""),
                ],
              ),

              DetailTableRow(
                metric: "VS LAST MONTH",
                dynamicColor: true,
                values: [
                  TableValue("${numberFormatter.format(siuResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.siu ?? 0)} "),
                  TableValue("${numberFormatter.format(jasaResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.jasa ?? 0)} "),
                  TableValue("${numberFormatter.format(oilResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.oil ?? 0)} "),
                  TableValue("${numberFormatter.format(partResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.part ?? 0)} "),
                  TableValue("${numberFormatter.format(sorderResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.so ?? 0)} "),
                  TableValue("${numberFormatter.format(materialResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.sm ?? 0)} "),
                  TableValue("${numberFormatter.format(totalResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.total ?? 0)} "),
                  TableValue("${numberFormatter.format(bookingResults.growthMonth)}%", " ${numberFormatter.format(databulansebelum.value?.booking ?? 0)} "),
                  TableValue(trendLastMonth),
                ],
              ),

              DetailTableRow(
                metric: "VS LAST YEAR",
                dynamicColor: true,
                values: [
                  TableValue("${numberFormatter.format(siuResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.siu ?? 0)}"),
                  TableValue("${numberFormatter.format(jasaResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.jasa ?? 0)}"),
                  TableValue("${numberFormatter.format(oilResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.oil ?? 0)}"),
                  TableValue("${numberFormatter.format(partResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.part ?? 0)}"),
                  TableValue("${numberFormatter.format(sorderResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.so ?? 0)}"),
                  TableValue("${numberFormatter.format(materialResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.sm ?? 0)}"),
                  TableValue("${numberFormatter.format(totalResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.total ?? 0)}"),
                  TableValue("${numberFormatter.format(bookingResults.growthYear)}%", "${numberFormatter.format(datatahunsebelum.value?.booking ?? 0)}"),
                  TableValue(trendLastYear),
                ],
              ),
            ],
          ),
        );
      },
      error: (Object error, StackTrace stackTrace) {
        return const Center(child: Text("Error"));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
