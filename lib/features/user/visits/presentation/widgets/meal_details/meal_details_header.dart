import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Back header + "Added by Fitness Day" caption for the meal details page.
class MealDetailsHeader extends StatelessWidget {
  const MealDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AppBackHeader(
            title: LocaleKeys.meal_details_page_title.tr(),
          ),
        ),
        Text(
          LocaleKeys.meal_details_added_by.tr(),
          style: TextStyleManager.style8Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
