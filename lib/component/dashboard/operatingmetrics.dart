import 'package:flutter/material.dart';
import 'package:operationcore2/component/card.dart';

class Operatingmetrics extends StatelessWidget {
  const Operatingmetrics({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return CardCustume(
      padding: 20,
      width: screenWidth,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Operating Metrics",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              // Row(
              //   children: [
              //     OutlinedButton(
              //       onPressed: () {},
              //       child: const Text("Export CSV"),
              //     ),
              //     const SizedBox(width: 8),
              //     OutlinedButton(
              //       onPressed: () {},
              //       child: const Text("Print PDF"),
              //     ),
              //   ],
              // ),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          // Tabel Sederhana
          Table(
            children: [
              _tableRow([
                "METRICS",
                "SIU",
                "JASA",
                "OIL",
                "PART",
                "S/ORDER",
                "TOTAL",
              ], isHeader: true),
              _tableRow([
                "Daily Avg",
                "37",
                "14,600,501",
                "11,576,924",
                "32,148,688",
                "15,233,292",
                "75,556,464",
              ]),
              _tableRow([
                "Gap to 100%",
                "(67)",
                "(12.8M)",
                "(19.4M)",
                "(39.6M)",
                "(54.3M)",
                "(132M)",
              ], isRed: true),
              _tableRow([
                "Min. Daily Budget",
                "34",
                "14,084,706",
                "10,800,803",
                "30,563,811",
                "13,060,000",
                "70,269,654",
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

TableRow _tableRow(
  List<String> cells, {
  bool isHeader = false,
  bool isRed = false,
}) {
  return TableRow(
    children: cells
        .map(
          (c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              c,
              style: TextStyle(
                color: isHeader
                    ? Colors.grey
                    : (isRed && c.contains('(') ? Colors.red : Colors.white),
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        )
        .toList(),
  );
}
