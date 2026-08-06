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

  /// Checked once [onSave] has finished. Return the server's rejection message
  /// to pin it under the field and keep the dialog open; `null` means the save
  /// went through. Without this the dialog closed on a rejected value and the
  /// reason appeared as a banner over the screen the user had just left.
  final String? Function()? errorAfterSave;

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
    this.errorAfterSave,
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
    // Typing clears whatever message is pinned under the field.
    _controller.addListener(() {
      if (_errorText != null && mounted) setState(() => _errorText = null);
    });
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
        await widget.onSave(value);

        final serverError = widget.errorAfterSave?.call();
        if (serverError != null) {
          // Pin the server's wording under the field and throw, which is how
          // ProfileDialogBase is told to keep the dialog open.
          if (mounted) setState(() => _errorText = serverError);
          throw Exception('Update rejected: $serverError');
        }
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
