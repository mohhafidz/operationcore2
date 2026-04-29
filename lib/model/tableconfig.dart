class TableColumnConfig {
  final String label;
  final int flex;

  TableColumnConfig({required this.label, required this.flex});
}

class TableRowData {
  final String? id;
  final List<String> values;

  TableRowData(this.values, {this.id});
}
