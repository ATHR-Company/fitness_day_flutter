import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:fitness_day/features/user/visits/data/models/branch_model.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import 'package:fitness_day/core/widgets/app_snack_bar.dart';

class ChangeLocationDialog extends StatefulWidget {
  final String assessmentId;

  const ChangeLocationDialog({super.key, required this.assessmentId});

  @override
  State<ChangeLocationDialog> createState() => _ChangeLocationDialogState();
}

class _ChangeLocationDialogState extends State<ChangeLocationDialog> {
  String _selectedType = 'BRANCH'; // 'BRANCH' or 'ONLINE'
  BranchModel? _selectedBranch;

  @override
  void initState() {
    super.initState();
    context.read<ChangeAssessmentCubit>().fetchBranches();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangeAssessmentCubit, ChangeAssessmentState>(
      listener: (context, state) {
        if (state is ChangeAssessmentSuccess) {
          showAppSnackBar(
            context,
            text: 'تم تعديل مكان الزيارة بنجاح',
            isSuccess: true,
          );
          context.pop();
        } else if (state is ChangeAssessmentError) {
          showAppSnackBar(
            context,
            text: state.message,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        List<BranchModel> branches = [];
        bool isLoading = state is ChangeAssessmentLoading;

        if (state is BranchesLoaded) {
          branches = state.branches;
          if (_selectedBranch == null && branches.isNotEmpty) {
            _selectedBranch = branches.first;
          }
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.lightGreenBackground, AppColors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'تعديل مكان الزيارة',
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,

                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        color: AppColors.primary,
                        size: 28.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Branch Option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = 'BRANCH';
                    });
                  },
                  child: _buildOption(
                    text: branches.isNotEmpty && _selectedBranch != null 
                        ? _selectedBranch!.name 
                        : 'مقر يوم الرشاقة',
                    isSelected: _selectedType == 'BRANCH',
                  ),
                ),
                SizedBox(height: 16.h),

                // Online Option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = 'ONLINE';
                    });
                  },
                  child: _buildOption(
                    text: 'اونلاين - البريد الالكتروني او الهاتف',
                    isSelected: _selectedType == 'ONLINE',
                  ),
                ),
                SizedBox(height: 32.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomOutlinedButton(
                        text: 'visit_details.cancel'.tr(),
                        onPressed: isLoading ? () {} : () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomButton(
                        isLoading: isLoading,
                        text: 'visit_details.save'.tr(),
                        onPressed: isLoading
                            ? () {}
                            : () {
                                context.read<ChangeAssessmentCubit>().submitChangeRequest(
                                      assessmentId: widget.assessmentId,
                                      type: _selectedType,
                                      branchId: _selectedType == 'BRANCH' ? _selectedBranch?.id : null,
                                    );
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({required String text, required bool isSelected}) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2), 
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                text,
                textAlign: TextAlign.right,
                textDirection: ui.TextDirection.rtl,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
