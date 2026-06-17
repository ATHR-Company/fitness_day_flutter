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

class _AppPhoneFieldState extends State<AppPhoneField> {
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey<FormFieldState<String>>();
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

  /// Strips a leading zero from [local] and combines with the country code.
  /// e.g. code='+20', local='0106301245' → '+20106301245'
  String _buildFullNumber(String local) {
    final stripped = local.startsWith('0') ? local.substring(1) : local;
    return '${_selectedCountry['code']}$stripped';
  }

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
        _localController.text = norm.substring(match['code']!.length);
      } else {
        // fallback: show as-is (without leading +)
        _localController.text = initial.startsWith('+')
            ? initial.substring(1)
            : initial;
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
        // الـ bottom sheet اتجاهه ثابت RTL دايمًا
        textDirection: ui.TextDirection.rtl,
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
                      color: const Color(0xffE6E6E6),
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
                        fillColor: const Color(0xffF5F5F5),
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
                              
                              // Truncate existing text if it exceeds the new country's digit limit
                              final newDigits = int.parse(country['digits']!);
                              final currentText = _localController.text;
                              final hasZero = currentText.startsWith('0');
                              var stripped = hasZero ? currentText.substring(1) : currentText;
                              
                              if (stripped.length > newDigits) {
                                stripped = stripped.substring(0, newDigits);
                                _localController.text = hasZero ? '0$stripped' : stripped;
                              }
                            });
                            // Re-sync parent controller with new country code
                            _syncToParent(_localController.text);
                            Navigator.pop(context);
                            // Re-validate both the specific field and the parent Form.
                            Future.delayed(const Duration(milliseconds: 50), () {
                              if (mounted) {
                                _fieldKey.currentState?.validate();
                                Form.maybeOf(context)?.validate();
                              }
                            });
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
                            style: TextStyleManager.style14Medium.copyWith(color: const Color(0xffB3B3B3)),
                            textDirection: ui.TextDirection.ltr,
                          ),
                          selected: isSelected,
                          selectedTileColor: const Color(0xffF5F5F5),
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
          autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
          validator: (_) {
            final local = _localController.text;
            final requiredDigits = int.parse(_selectedCountry['digits']!);
            final stripped = local.startsWith('0')
                ? local.substring(1)
                : local;
            if (stripped.length < requiredDigits) {
              return 'login.phone_local_digits_min'.tr(
                args: [requiredDigits.toString()],
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
          textAlign: TextAlign.right,
          style: TextStyleManager.heading3.copyWith(
            color: AppColors.black,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(
              int.parse(_selectedCountry['digits']!),
            ),
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
              onTap: (widget.enabled && !widget.readOnly) ? _showCountryPicker : null,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry['flag']!,
                      style: TextStyle(fontSize: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    // The grey vertical divider
                    Container(
                      width: 1.w,
                      height: 24.h,
                      color: AppColors.divider,
                    ),
                  ],
                ),
              ),
            ),
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
