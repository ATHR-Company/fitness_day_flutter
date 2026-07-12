import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/challenge_active_screen.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_description_tab.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_dialog_header.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_image_tab_switcher.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_rules_tab.dart';

class ChallengeDetailsDialog extends StatefulWidget {
  final ChallengeModel challenge;
  final ChallengeType challengeType;

  const ChallengeDetailsDialog({
    super.key,
    required this.challenge,
    this.challengeType = ChallengeType.steps,
  });

  @override
  State<ChallengeDetailsDialog> createState() => _ChallengeDetailsDialogState();
}

class _ChallengeDetailsDialogState extends State<ChallengeDetailsDialog> {
  bool _isDescriptionSelected = true;

  void _goToRules() => setState(() => _isDescriptionSelected = false);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 650.h,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: [
              ChallengeDialogHeader(onClose: () => Navigator.pop(context)),
              ChallengeImageTabSwitcher(
                imageUrl: widget.challenge.imageUrl,
                isDescriptionSelected: _isDescriptionSelected,
                onTabChanged: (val) => setState(() => _isDescriptionSelected = val),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _isDescriptionSelected
                      ? ChallengeDescriptionTab(
                          challenge: widget.challenge,
                          onNext: _goToRules,
                        )
                      : ChallengeRulesTab(
                          challenge: widget.challenge,
                          challengeType: widget.challengeType,
                        ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
