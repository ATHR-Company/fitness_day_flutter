import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'loader.dart';

/// Wraps any [child] widget with a full-screen loading overlay.
///
/// When [isCall] becomes `true`, the keyboard is dismissed automatically and
/// the child is covered by a semi-transparent black scrim with a [ColorLoader]
/// spinner. All pointer events on the child are blocked while loading.
class LoaderHud extends StatefulWidget {
  final bool isCall;
  final Widget child;

  const LoaderHud({
    super.key,
    required this.isCall,
    required this.child,
  });

  @override
  State<LoaderHud> createState() => _LoaderHudState();
}

class _LoaderHudState extends State<LoaderHud> {
  @override
  void didUpdateWidget(covariant LoaderHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dismiss the keyboard when a call starts so the HUD is fully visible.
    if (widget.isCall && !oldWidget.isCall) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: widget.isCall,
      color: Colors.black,
      progressIndicator: const ColorLoader(),
      child: IgnorePointer(
        ignoring: widget.isCall,
        child: widget.child,
      ),
    );
  }
}
