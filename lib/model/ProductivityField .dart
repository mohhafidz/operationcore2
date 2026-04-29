// lib/model/ProductivityField.dart

enum ProductivityField { unitEntry, totalJasa }

String fieldToString(ProductivityField field) {
  switch (field) {
    case ProductivityField.unitEntry:
      return 'unitentry';
    case ProductivityField.totalJasa:
      return 'totaljasa';
  }
}

ProductivityField mapField(String columnLabel) {
  switch (columnLabel.toUpperCase()) {
    case 'UNIT ENTRY':
    case 'UNIT':
      return ProductivityField.unitEntry;
    case 'TOTAL JASA':
      return ProductivityField.totalJasa;
    default:
      return ProductivityField.unitEntry;
  }
}
