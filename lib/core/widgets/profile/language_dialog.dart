import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/constant/app_locale.dart';
import 'profile_dialog_base.dart';

class LanguageDialog extends StatefulWidget {
  const LanguageDialog({super.key});

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  String _selectedLang = 'ar';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLang = context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDialogBase(
      title: 'profile.edit_language'.tr(),
      onSave: () async {
        AppLocale.set(_selectedLang);   // ← update interceptor immediately
        await context.setLocale(Locale(_selectedLang));
      },
      child: Row(
        children: [
          Expanded(
            child: _buildLangOption(
              langCode: 'en',
              title: 'profile.english'.tr(),
              svgPath: SvgIcons.english,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildLangOption(
              langCode: 'ar',
              title: 'profile.arabic'.tr(),
              svgPath: SvgIcons.arabic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangOption({
    required String langCode,
    required String title,
    required String svgPath,
  }) {
    bool isSelected = _selectedLang == langCode;
    return GestureDetector(
      onTap: () => setState(() => _selectedLang = langCode),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.5),
                  size: 20.sp,
                ),
              ),
            ),
            SvgPicture.asset(svgPath, width: 48.w, height: 48.w),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
