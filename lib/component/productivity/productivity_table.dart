import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/model/ProductivityField%20.dart';
import 'package:operationcore2/model/tableconfig.dart';
import 'package:operationcore2/providers/productifity_provider.dart';
import 'package:operationcore2/utils/number_formatter.dart';

/// Tabel produktivitas yang dapat dikonfigurasi kolom, baris, dan kolom yang dapat diedit
class ProductivityTable extends StatelessWidget {
  final List<TableColumnConfig> columns;
  final List<TableRowData> rows;
  final List<String> editableColumnLabels;
  final void Function(String columnLabel, String? userId)? onEdit;
  final bool Function(String? userId) canEdit;

  const ProductivityTable({
    super.key,
    required this.columns,
    required this.rows,
    this.editableColumnLabels = const [],
    this.onEdit,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // HEADER
          Row(
            children: columns
                .map(
                  (col) => Expanded(
                    flex: col.flex,
                    child: Text(
                      col.label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),

          // ROWS
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: List.generate(columns.length, (index) {
                  final label = columns[index].label;
                  final isEditable =
                      editableColumnLabels.contains(label) && canEdit(row.id);

                  return Expanded(
                    flex: columns[index].flex,
                    child: isEditable
                        ? EditableTableCell(
                            value: row.values[index],
                            columnLabel: label,
                            rowId: row.id,
                            onEdit: onEdit,
                          )
                        : ProductivityTableCell(
                            value: row.values[index],
                            columnLabel: label,
                          ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Cell dalam tabel yang dapat diedit (tampilkan ikon edit)
class EditableTableCell extends StatelessWidget {
  final String value;
  final String columnLabel;
  final String? rowId;
  final void Function(String columnLabel, String? userId)? onEdit;

  const EditableTableCell({
    super.key,
    required this.value,
    required this.columnLabel,
    this.rowId,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (onEdit != null) {
              onEdit!(columnLabel, rowId);
            } else {
              showNumberInputDialog(columnLabel: columnLabel);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.edit, color: Colors.white60, size: 14),
          ),
        ),
        ProductivityTableCell(value: value, columnLabel: columnLabel),
      ],
    );
  }
}

/// Cell biasa dalam tabel produktivitas
class ProductivityTableCell extends StatelessWidget {
  final String value;
  final String columnLabel;

  const ProductivityTableCell({
    super.key,
    required this.value,
    required this.columnLabel,
  });

  @override
  Widget build(BuildContext context) {
    String formatted = value;
    if (!columnLabel.contains("STAFF")) {
      formatted = formatValue(value);
    }

    Color textColor = Colors.white;
    FontWeight weight = FontWeight.normal;

    if (columnLabel.contains("UNIT")) {
      textColor = const Color(0xffFFC107);
      weight = FontWeight.bold;
    }

    if (columnLabel.contains("ACHIEVEMENT")) {
      textColor = const Color(0xff00E396);
      weight = FontWeight.bold;
    }

    return Text(
      formatted,
      style: TextStyle(color: textColor, fontWeight: weight, fontSize: 14),
    );
  }
}

/// Dialog untuk input angka (unit entry, total jasa, dll.)
void showNumberInputDialog({
  String columnLabel = '',
  String? userId,
  WidgetRef? ref,
}) {
  final TextEditingController controller = TextEditingController();

  Get.dialog(
    AlertDialog(
      backgroundColor: const Color(0xff1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        "Input $columnLabel",
        style: const TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Enter number",
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final value = controller.text;

            if (value.isNotEmpty && userId != null && ref != null) {
              final intValue = int.tryParse(value) ?? 0;
              final field = mapField(columnLabel);

              final now = DateTime.now();
              final docId =
                  "${now.year}-${now.month.toString().padLeft(2, '0')}";

              await ref
                  .read(productifityRepositoryProvider)
                  .updateProductivityValue(
                    docId: docId,
                    userId: userId,
                    field: field,
                    value: intValue,
                  );
            }

            Get.back();
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
