import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/component/monitoring/sa_section.dart';
import 'package:operationcore2/providers/monitoringsa_provider.dart';
import 'package:operationcore2/providers/dashboard_provider.dart';

class Monitoringsa extends ConsumerWidget {
  const Monitoringsa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(monitoringSAProvider);

    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (list) {
        final workingDay = ref.watch(workingDayProvider);
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: SaSection(data: list, workingDay: workingDay),
          ),
        );
      },
    );
  }
}
