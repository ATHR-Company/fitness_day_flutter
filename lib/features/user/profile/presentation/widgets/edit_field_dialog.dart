import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Returns an error message for the current text, or `null` when it is
  /// acceptable. A failing validator keeps the dialog open and blocks [onSave].
  final String? Function(String)? validator;

  /// Last chance to clean the text before it reaches [onSave] — e.g. rounding
  /// a weight to two decimals so the server never stores 50.066556668568886.
  final String Function(String)? normalize;

  final List<TextInputFormatter>? inputFormatters;

  const EditFieldDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.iconPath,
    required this.onSave,
    this.keyboardType,
    this.maxLength,
    this.nameOnly = false,
    this.validator,
    this.normalize,
    this.inputFormatters,
  });

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  late final TextEditingController _controller;
  String? _errorText;

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

  bool _validate() {
    final error = widget.validator?.call(_controller.text);
    if (error != _errorText) setState(() => _errorText = error);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDialogBase(
      title: widget.title,
      validate: _validate,
      onSave: () async {
        final value = widget.normalize?.call(_controller.text) ?? _controller.text;
        return widget.onSave(value);
      },
      child: ProfileTextField(
        controller: _controller,
        hintText: widget.hintText,
        iconPath: widget.iconPath,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        nameOnly: widget.nameOnly,
        inputFormatters: widget.inputFormatters,
        errorText: _errorText,
      ),
    );
  }
}
