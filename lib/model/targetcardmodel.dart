import 'package:flutter/material.dart';

class TargetCardModel {
  final String title;
  final String icon;

  final List<TargetItem> items;

  TargetCardModel({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class TargetItem {
  String name;
  bool iscurrency;
  bool ispercentage;
  bool isdecimal;
  TextEditingController controller;

  TargetItem({
    required this.name,
    required this.iscurrency,
    required this.ispercentage,
    this.isdecimal = false,
  }) : controller = TextEditingController();
}
