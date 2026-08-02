import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/challenge_image_picker.dart';
import 'package:fitness_day/core/widgets/profile/profile_dialog_base.dart';
import 'package:fitness_day/core/widgets/profile/profile_text_field.dart';
import 'package:fitness_day/features/specialist/profile/presentation/manager/specialist_profile_cubit.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/specialist/profile/presentation/manager/specialist_profile_state.dart';
import 'package:fitness_day/core/widgets/errors/show_app_error.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _nameController;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SpecialistProfileCubit>();
    _nameController = TextEditingController(text: cubit.profileData?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SpecialistProfileCubit>();
    final networkAvatar = cubit.profileData?.avatar ?? '';

    return ProfileDialogBase(
      title: 'profile.personal_profile'.tr(),
      onSave: () async {
        final name = _nameController.text.trim();
        if (name.isEmpty) {
          showAppSnackBar(context, text: 'profile.name_cannot_be_empty'.tr(), isError: true);
          throw Exception("Name is empty");
        }

        await cubit.updateSpecialistProfile(
          name: name,
          avatarPath: _localImagePath,
        );

        final state = cubit.state;
        if (state is SpecialistProfileUpdateFailure) {
          if (context.mounted) {
            showAppError(context, state.error, message: state.message);
          }
          throw Exception('Update failed: ${state.message}');
        }
      },
      child: Column(
        children: [
          // Avatar Picker
          ChallengeImagePicker(
            initialImageUrl: networkAvatar,
            showBottomText: false,
            showEditOverlay: true,
            size: 100.w,
            onImagePicked: (file) {
              _localImagePath = file.path;
            },
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Text(
                'profile.edit_name'.tr(),
                style: TextStyleManager.style13Medium,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ProfileTextField(
            controller: _nameController,
            hintText: 'conversations.dummy_name'.tr(),
            iconPath: SvgIcons.editName,
          ),
        ],
      ),
    );
  }
}
