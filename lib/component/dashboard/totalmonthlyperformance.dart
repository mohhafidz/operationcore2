import 'package:flutter/material.dart';
import 'package:operationcore2/component/text/textbold.dart';
import 'package:operationcore2/component/text/textmessage.dart';
import 'package:operationcore2/component/text/textnumber.dart';
import 'package:operationcore2/component/text/textnumber2.dart';
import 'package:operationcore2/component/text/texttitle.dart';
import 'package:operationcore2/component/card.dart';

class Totalmonthlyperformance extends StatelessWidget {
  const Totalmonthlyperformance({super.key});

  @override
  Widget build(BuildContext context) {
    final double percentage = 100;
    return CardCustume(
      padding: 30,
      width: 570,
      height: 350,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Texttitle(message: "Total Monthly Performance"),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: percentage > 1.0
                          ? 1.0
                          : percentage, // Progress (max 1.0)
                      strokeWidth: 12, // Ketebalan garis
                      backgroundColor:
                          Colors.white10, // Warna sisa lingkaran yang redup
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B82F6),
                      ), // Biru terang
                      strokeCap:
                          StrokeCap.round, // Membuat ujung garis membulat
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      textBold(message: '${(percentage).toInt()}%'),
                      const Textmessage(message: "TARGET ACHIEVED"),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 36),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Textmessage(message: "Current Total Achievement"),
                  textNumber(message: "1,888,911,605"),
                  SizedBox(height: 22),
                  Textmessage(message: "Goal Target"),
                  textNumber2(message: "1,756,741,340"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
