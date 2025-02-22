import 'package:flutter/material.dart';

class TextDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  TextDialog({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter Text"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: "Type something..."),
      ),
      actions: [
        TextButton(
          onPressed: onAdd,
          child: Text("Add"),
        ),
      ],
    );
  }
}
