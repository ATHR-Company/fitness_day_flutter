import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenge_details_cubit.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/challenge_active_screen.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_action_button.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_description_tab.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_dialog_header.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_image_tab_switcher.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_rules_tab.dart';

/// Details sheet: description, rules, and the join / leave action.
class ChallengeDetailsDialog extends StatelessWidget {
  /// The card this sheet was opened from. It is shown immediately so the sheet
  /// never opens blank; the fetch then adds the rules, which only the details
  /// endpoint returns.
  final ChallengeModel challenge;

  const ChallengeDetailsDialog({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChallengeDetailsCubit>()
        ..load(challenge.id, seed: challenge),
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatefulWidget {
  const _DetailsView();

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView> {
  bool _isDescriptionSelected = true;

  void _goToRules() => setState(() => _isDescriptionSelected = false);

  Future<void> _join() async {
    final navigator = Navigator.of(context);
    final (ok, message, joined) =
        await context.read<ChallengeDetailsCubit>().join();
    if (!mounted) return;

    if (!ok) {
      // The backend's own wording — "already joined", "challenge ended" — is
      // already translated, so it is shown verbatim.
      showAppSnackBar(context, text: message, isError: true);
      return;
    }

    // Straight into the challenge. `joined` is the server's object, so the
    // screen opens with the backfilled progress already on it rather than at
    // zero — a challenge joined mid-week is credited for the days that passed.
    navigator.pop();
    if (joined == null) return;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ChallengeActiveScreen(challenge: joined),
      ),
    );
  }

  /// Leaving discards progress outright, so it asks first.
  Future<void> _leave() async {
    final cubit = context.read<ChallengeDetailsCubit>();
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('challenges.leave_title'.tr()),
            content: Text('challenges.leave_message'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text('profile.cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'challenges.btn_leave'.tr(),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final (ok, message) = await cubit.leave();
    if (!mounted || ok) return;
    showAppSnackBar(context, text: message, isError: true);
  }

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
          child: BlocBuilder<ChallengeDetailsCubit, ChallengeDetailsState>(
            builder: (context, state) => switch (state) {
              ChallengeDetailsError(:final message, :final error) => Padding(
                  padding: EdgeInsets.all(16.w),
                  child: AppErrorView(error: error, message: message),
                ),
              ChallengeDetailsLoaded(:final challenge, :final isBusy) =>
                _buildContent(challenge, isBusy),
              _ => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ChallengeModel challenge, bool isBusy) {
    return Column(
      children: [
        ChallengeDialogHeader(onClose: () => Navigator.pop(context)),
        ChallengeImageTabSwitcher(
          imageUrl: challenge.image,
          isDescriptionSelected: _isDescriptionSelected,
          onTabChanged: (val) => setState(() => _isDescriptionSelected = val),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _isDescriptionSelected
                ? ChallengeDescriptionTab(challenge: challenge)
                : ChallengeRulesTab(challenge: challenge),
          ),
        ),
        // Pinned, outside the scroll view. Each tab used to carry its own
        // buttons at the end of its content, so they landed at a different
        // height per tab and moved under the user's thumb on every switch.
        _buildActions(challenge, isBusy),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildActions(ChallengeModel challenge, bool isBusy) {
    final action = ChallengeActionButton(
      challenge: challenge,
      isBusy: isBusy,
      onJoin: _join,
      onLeave: _leave,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      // "Next" only means something on the description tab — there is nothing
      // after the rules — so the rules tab gives the action the full width.
      child: _isDescriptionSelected
          ? Row(
              children: [
                Expanded(child: action),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToRules,
                    style: OutlinedButton.styleFrom(
                      // Outlined, so the filled button stays the primary one
                      // and two solid greens don't compete side by side.
                      minimumSize: Size(double.infinity, 50.h),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'challenges.btn_next'.tr(),
                        maxLines: 1,
                        style: TextStyleManager.style13Medium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : action,
    );
  }
}
