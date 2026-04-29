import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/text/textbold.dart';
import 'package:operationcore2/component/text/textmessage.dart';
import 'package:operationcore2/component/text/texttitle.dart';

class Detailcategory extends StatelessWidget {
  const Detailcategory({super.key});

  @override
  Widget build(BuildContext context) {
    return CardCustume(
      padding: 20,
      width: 394,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Textmessage(message: "Total Unit Sales"),
              Container(
                padding: EdgeInsetsDirectional.all(4),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "100%",
                  style: GoogleFonts.inter(
                    color: Color(0xff10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          textBold(message: "SIU"),
          SizedBox(height: 18),
          _data("Achievement", "917", false),
          Divider(),
          SizedBox(height: 20),
          _data("Target", "850", true),
          Divider(),
          SizedBox(height: 20),
          Row(
            spacing: 20,
            children: [
              _statistik("vs Last Month", "-9%", true),
              _statistik("vs Last Month", "11%", false),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _data(String name, String data, bool data2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Textmessage(message: name),
      if (data2) Textmessage(message: data),
      if (!data2) Texttitle(message: data),
    ],
  );
}

Widget _statistik(String name, String data, bool minus) {
  return Container(
    width: 164,
    decoration: BoxDecoration(
      color: minus ? AppColors.red : AppColors.green,
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsetsDirectional.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.inter(
            color: minus ? AppColors.redtext : AppColors.greentext,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Text(
          data,
          style: GoogleFonts.inter(
            color: minus ? AppColors.redtext : AppColors.greentext,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
