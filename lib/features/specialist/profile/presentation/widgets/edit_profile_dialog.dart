import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/utils/validators.dart';
import 'package:fitness_day/core/widgets/challenge_image_picker.dart';
import 'package:fitness_day/core/widgets/profile/profile_dialog_base.dart';
import 'package:fitness_day/core/widgets/profile/profile_text_field.dart';
import 'package:fitness_day/features/specialist/profile/presentation/manager/specialist_profile_cubit.dart';
import 'package:fitness_day/features/specialist/profile/presentation/manager/specialist_profile_state.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _nameController;
  String? _localImagePath;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SpecialistProfileCubit>();
    _nameController = TextEditingController(text: cubit.profileData?.name ?? '');
    // Typing clears the message pinned under the field.
    _nameController.addListener(() {
      if (_nameError != null && mounted) setState(() => _nameError = null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Runs before the request. Returning false keeps the dialog open with the
  /// reason under the field. Same rule as the user's name edit — a name the
  /// backend would reject never leaves the device.
  bool _validate() {
    final error = AppValidators.personName(_nameController.text);
    if (error != _nameError) setState(() => _nameError = error);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SpecialistProfileCubit>();
    final networkAvatar = cubit.profileData?.avatar ?? '';

    return ProfileDialogBase(
      title: 'profile.personal_profile'.tr(),
      validate: _validate,
      onSave: () async {
        await cubit.updateSpecialistProfile(
          name: _nameController.text.trim(),
          avatarPath: _localImagePath,
        );

        final state = cubit.state;
        if (state is SpecialistProfileUpdateFailure) {
          // The server's own wording goes under the field, next to the value
          // it is talking about, and throwing keeps the dialog open so the
          // name can actually be corrected.
          if (mounted) setState(() => _nameError = state.message);
          throw Exception('Update rejected: ${state.message}');
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
            nameOnly: true,
            maxLength: 30,
            errorText: _nameError,
          ),
        ],
      ),
    );
  }
}
