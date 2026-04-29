import 'package:flutter/material.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/text/texttitle.dart';

class CategoryDistribution extends StatelessWidget {
  const CategoryDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    return CardCustume(
      width: double.infinity,
      padding: 30,
      widget: Column(
        mainAxisSize: MainAxisSize.min, // Agar container menciut mengikuti isi
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Texttitle(message: "Category Distribution (Millions)"),
              Row(
                children: [
                  _indikator(true, "Current"),
                  const SizedBox(width: 12),
                  _indikator(false, "Target"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // --- BAR LIST ---
          // PERBAIKAN: Jika diletakkan di dalam Column yang 'mainAxisSize.min',
          // kita tidak perlu 'Expanded'. Cukup Column biasa.
          Column(
            children: [
              _buildProgressBar("PART", 0.85, "85%"),
              _buildProgressBar("JASA", 0.70, "70%"),
              _buildProgressBar("OIL", 0.60, "60%"),
              _buildProgressBar("S/ORDER", 0.65, "65%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, String percentText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                percentText,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indikator(bool isCurrent, String message) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? const Color(0xFF3B82F6)
                : const Color(0xFF334155),
          ),
        ),
        const SizedBox(width: 6),
        Text(message, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
