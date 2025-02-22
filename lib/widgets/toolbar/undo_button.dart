import 'package:flutter/material.dart';

class UndoButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isEnabled;

  UndoButton({required this.onTap, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Icon(
              Icons.undo,
              size: 30,
              color: isEnabled ? Colors.black : Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              "Undo",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
