import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/countries.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class AppPhoneField extends StatefulWidget {
  const AppPhoneField({
    super.key,
    this.title,
    this.hint,
    this.controller,
    this.onChanged,
    this.onCodeChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidateMode,
  });

  final String? title;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCodeChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

/// Refuses a zero in the first position, silently.
///
/// The country code already carries the international prefix, so the national
/// trunk `0` — the one people habitually type in `0106301245` — has no place in
/// the field. Rejecting the keystroke is friendlier than accepting it and then
/// explaining the error: nothing appears, and the next digit lands correctly.
///
/// Only the *leading* zero is blocked; zeros anywhere else are ordinary digits.
class _NoLeadingZeroFormatter extends TextInputFormatter {
  const _NoLeadingZeroFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.startsWith('0')) return newValue;

    final String trimmed = newValue.text.replaceFirst(RegExp(r'^0+'), '');
    final int removed = newValue.text.length - trimmed.length;
    // Pull the caret back by however many characters vanished, so it does not
    // sit past the end of the shortened text.
    final int offset = (newValue.selection.baseOffset - removed).clamp(
      0,
      trimmed.length,
    );
    return TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  late Map<String, String> _selectedCountry;
  final TextEditingController _searchController = TextEditingController();
  // Internal controller for the raw local digits shown in the field.
  // widget.controller always receives the full international number.
  final TextEditingController _localController = TextEditingController();
  List<Map<String, String>> _filtered = [];

  // ─── helper ───────────────────────────────────────────────────────────────
  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  ui.TextDirection get _textDir =>
      _isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr;

  String _countryName(Map<String, String> country) =>
      _isAr ? country['ar']! : country['en']!;

  /// Combines the local digits with the country code.
  ///
  /// Leading zeros are stripped defensively: [_NoLeadingZeroFormatter] keeps
  /// them out of the field, but a number prefilled from the API or the cache
  /// never went through it.
  String _buildFullNumber(String local) {
    final stripped = _stripLeadingZeros(local);
    return '${_selectedCountry['code']}$stripped';
  }

  /// The `0` in `0106301245` is Egypt's national trunk prefix, not part of the
  /// number — E.164 (`+20106301245`) never carries it. Same for every other
  /// country in the list, so this is not an Egypt-only rule.
  static String _stripLeadingZeros(String local) {
    int i = 0;
    while (i < local.length && local[i] == '0') {
      i++;
    }
    return local.substring(i);
  }

  int get _requiredDigits => int.parse(_selectedCountry['digits']!);

  void _syncToParent(String localValue) {
    final full = _buildFullNumber(localValue);
    if (widget.controller != null && widget.controller!.text != full) {
      widget.controller!.text = full;
    }
    widget.onChanged?.call(full);
    widget.onCodeChanged?.call(_selectedCountry['code']!);
  }

  @override
  void initState() {
    super.initState();
    _selectedCountry = Countries.all.first;
    _filtered = Countries.all;

    // If parent provided a full phone in `widget.controller`, prefill
    // the local controller and select matching country code.
    final initial = widget.controller?.text ?? '';
    if (initial.isNotEmpty) {
      final norm = initial.startsWith('+') ? initial : '+$initial';
      final match = Countries.all.firstWhere(
        (c) => norm.startsWith(c['code']!),
        orElse: () => Countries.all.first,
      );

      // if matched a non-default country (i.e., norm starts with its code)
      if (norm.startsWith(match['code']!)) {
        _selectedCountry = match;
        _localController.text =
            _stripLeadingZeros(norm.substring(match['code']!.length));
      } else {
        // fallback: show as-is (without leading +)
        _localController.text = _stripLeadingZeros(
          initial.startsWith('+') ? initial.substring(1) : initial,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _localController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    _filtered = Countries.all;
    _searchController.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Directionality(
        // Bottom sheet direction follows the current app locale.
        textDirection: _textDir,
        child: StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (_, scrollController) => Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'login.search_country_hint'.tr(),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: AppColors.greyBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          _filtered = Countries.all.where((c) {
                            return c['ar']!.contains(val) ||
                                c['en']!.toLowerCase().contains(
                                  val.toLowerCase(),
                                ) ||
                                c['code']!.contains(val);
                          }).toList();
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  // List
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (_, i) {
                        final country = _filtered[i];
                        final isSelected =
                            country['code'] == _selectedCountry['code'] &&
                            country['ar'] == _selectedCountry['ar'];
                        return ListTile(
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;

                              // Truncate what the new country cannot hold. No
                              // leading zero to preserve any more — the field
                              // never contains one.
                              final newDigits = int.parse(country['digits']!);
                              final current =
                                  _stripLeadingZeros(_localController.text);
                              _localController.text = current.length > newDigits
                                  ? current.substring(0, newDigits)
                                  : current;
                            });
                            // Re-sync parent controller with new country code
                            _syncToParent(_localController.text);
                            Navigator.pop(context);
                            _revalidateAfterCountryChange();
                          },
                          leading: Text(
                            country['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            _countryName(country),
                            style: TextStyleManager.style14Medium,
                          ),
                          trailing: Text(
                            country['code']!,
                            style: TextStyleManager.style14Medium.copyWith(
                              color: AppColors.textPlaceholder,
                            ),
                            textDirection: ui.TextDirection.ltr,
                          ),
                          selected: isSelected,
                          selectedTileColor: AppColors.greyBackground,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Refreshes this field — and only this field — after the country changed.
  ///
  /// Two things used to go wrong here. It called `Form.maybeOf(context)
  /// ?.validate()`, which validates *every* field in the form: picking a
  /// country lit up errors under the password, the email and anything else the
  /// user had not filled in yet. And it validated this field even when it was
  /// empty, so changing the country on an untouched form produced "the number
  /// must be N digits" about a number nobody had typed.
  ///
  /// Now: nothing is touched but this field, and only when the user has
  /// actually entered something. An empty field is reset instead, which clears
  /// any error left over from the previous country.
  void _revalidateAfterCountryChange() {
    // After the frame, so the sheet has closed and the field's own state has
    // caught up with the new controller text.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_localController.text.isEmpty) {
        _fieldKey.currentState?.reset();
        // reset() clears the text too, so put it back — it was already empty,
        // but this also restores the parent's copy of the number.
        _syncToParent('');
        return;
      }
      _fieldKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ─── بدون Directionality شاملة — بس العنوان والـ hint بيتأثروا باللغة ───
    return Column(
      // اتجاه العنوان حسب اللغة
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          // العنوان: اتجاهه حسب اللغة
          Text(widget.title!, style: TextStyleManager.heading2),
          SizedBox(height: 11.h),
        ],
        TextFormField(
          key: _fieldKey,
          focusNode: widget.focusNode,
          controller: _localController,
          keyboardType: TextInputType.phone,
          onChanged: _syncToParent,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          autovalidateMode:
              widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
          validator: (_) {
            final local = _localController.text;
            final stripped = _stripLeadingZeros(local);
            if (stripped.length < _requiredDigits) {
              return 'login.phone_local_digits_min'.tr(
                args: [_requiredDigits.toString()],
              );
            }
            if (widget.validator != null) {
              return widget.validator!(
                widget.controller?.text ?? _buildFullNumber(local),
              );
            }
            return null;
          },
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          // الأرقام دايمًا LTR
          textDirection: ui.TextDirection.ltr,
          textAlign: _isAr ? TextAlign.right : TextAlign.left,
          style: TextStyleManager.heading3,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            const _NoLeadingZeroFormatter(),
            // Counts real digits only. While a leading zero was allowed this
            // limit was spending one of its slots on it, so an Egyptian number
            // typed as `0106301245` was capped at ten characters — nine of them
            // actual digits — and the field could never be made valid.
            LengthLimitingTextInputFormatter(_requiredDigits),
          ],
          decoration: InputDecoration(
            // الـ hint اتجاهه حسب اللغة فقط
            hintText: widget.hint ?? 'login.phone_hint'.tr(),
            hintTextDirection: _textDir,
            hintStyle: TextStyleManager.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
            prefixIcon: InkWell(
              onTap: (widget.enabled && !widget.readOnly)
                  ? _showCountryPicker
                  : null,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: Center(
                        child: Text(
                          _selectedCountry['flag']!,
                          // Match the visual size of the password lock SVG
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // The grey vertical divider — same height as password field
                    Container(
                      width: 1.w,
                      height: 24.h,
                      color: AppColors.divider,
                    ),
                  ],
                ),
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 48.w, minHeight: 24.h),
            // Underline borders like in the Figma design
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider, width: 1.0),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider, width: 1.0),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2.0),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.error, width: 1.0),
            ),
            disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }
}
