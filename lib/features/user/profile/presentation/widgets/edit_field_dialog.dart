import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/profile/profile_dialog_base.dart';
import 'package:fitness_day/core/widgets/profile/profile_text_field.dart';

class EditFieldDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String iconPath;
  final Function(String) onSave;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool nameOnly;

  const EditFieldDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.iconPath,
    required this.onSave,
    this.keyboardType,
    this.maxLength,
    this.nameOnly = false,
  });

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.hintText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDialogBase(
      title: widget.title,
      onSave: () async => widget.onSave(_controller.text),
      child: ProfileTextField(
        controller: _controller,
        hintText: widget.hintText,
        iconPath: widget.iconPath,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        nameOnly: widget.nameOnly,
      ),
    );
  }
}
