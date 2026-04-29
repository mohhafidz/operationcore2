import 'package:flutter/material.dart';
import 'package:operationcore2/component/shared/app_text.dart';

/// Header section dengan bar indikator warna di sisi kiri (digunakan di Productivity)
class SectionHeader extends StatelessWidget {
  final String title;
  final Color indicatorColor;
  final double indicatorWidth;
  final double indicatorHeight;

  const SectionHeader({
    super.key,
    required this.title,
    required this.indicatorColor,
    this.indicatorWidth = 6,
    this.indicatorHeight = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      children: [
        Container(
          width: indicatorWidth,
          height: indicatorHeight,
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        AppTextTitle(title),
      ],
    );
  }
}

/// Header card dengan judul dan sub-keterangan (digunakan di Dashboard)
class CardSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const CardSectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextTitle(title),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            AppTextHint(subtitle!),
          ],
        ],
      ),
    );
  }
}
