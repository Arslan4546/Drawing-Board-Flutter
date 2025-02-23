import 'package:flutter/material.dart';
import '../../models/text_data.dart';

void showTextOptions(BuildContext context, TextData textData,
    Function(TextData) showEditTextDialog, Function setState) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionButton(
                icon: Icons.edit,
                label: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  showEditTextDialog(textData);
                },
              ),
              const SizedBox(width: 16),
              _buildOptionButton(
                icon: Icons.delete,
                label: "Delete",
                isDestructive: true,
                onTap: () {
                  setState(() {
                    // Assuming this modifies a list in the parent widget
                    // This will be handled in drawing_board_screen.dart
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildOptionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? Colors.red
                  : Colors.blue, // Adjust color as needed
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
