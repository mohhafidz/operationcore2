class PersonModel {
  final String title;
  final String icon;
  List<PesonItem> items;

  PersonModel({required this.title, required this.icon, required this.items});
}

class PesonItem {
  final String name;

  PesonItem({required this.name});
}
