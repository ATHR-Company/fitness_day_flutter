import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/no_script_input_formatter.dart';
import 'package:fitness_day/features/user/market/domain/entities/address_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/addresses_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/map_picker_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/static_map_preview.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/utils/no_script_input_formatter.dart';

class EditAddressScreen extends StatefulWidget {
  /// Pass [address] to pre-fill fields (edit mode).
  /// Leave null to open in add mode with empty fields.
  final AddressData? address;

  const EditAddressScreen({super.key, this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _streetController;
  late final TextEditingController _postalCodeController;

  LatLng? _pickedLocation;
  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.address != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _nameController = TextEditingController(text: address?.title ?? '');
    _neighborhoodController =
        TextEditingController(text: address?.district ?? '');
    _streetController = TextEditingController(text: address?.street ?? '');
    _postalCodeController =
        TextEditingController(text: address?.postalCode ?? '');
    _isDefault = address?.isDefault ?? false;

    if (address != null) {
      _pickedLocation = LatLng(address.lat, address.lng);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  // ── Map picker ──────────────────────────────────────────────────────────────
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialCoordinates: _pickedLocation),
      ),
    );
    if (result != null) {
      setState(() => _pickedLocation = result);
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_pickedLocation == null) {
      showAppSnackBar(
        context,
        text: 'market.select_location_prompt'.tr(),
        isError: true,
      );
      return;
    }

    final input = AddressInput(
      title: _nameController.text.trim(),
      district: _neighborhoodController.text.trim(),
      street: _streetController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      lat: _pickedLocation!.latitude,
      lng: _pickedLocation!.longitude,
      isDefault: _isDefault,
    );

    setState(() => _isSaving = true);
    final cubit = context.read<AddressesCubit>();
    final bool ok = _isEditMode
        ? await cubit.updateAddress(widget.address!.id, input)
        : await cubit.createAddress(input);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      showAppSnackBar(
        context,
        text: 'market.address_save_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Map section ──────────────────────────────────────
                      _buildMapSection(),
                      SizedBox(height: 24.h),

                      // ── Fields ───────────────────────────────────────────
                      _buildField(
                        label: 'market.address_name_label'.tr(),
                        hint: 'market.address_name_hint'.tr(),
                        controller: _nameController,
                        validator: _requiredValidator,
                      ),
                      SizedBox(height: 16.h),
                      _buildField(
                        label: 'market.neighborhood_label'.tr(),
                        hint: 'market.neighborhood_hint'.tr(),
                        controller: _neighborhoodController,
                        validator: _requiredValidator,
                      ),
                      SizedBox(height: 16.h),
                      _buildField(
                        label: 'market.street_label'.tr(),
                        hint: 'market.street_hint'.tr(),
                        controller: _streetController,
                        validator: _requiredValidator,
                      ),
                      SizedBox(height: 16.h),
                      _buildField(
                        label: 'market.postal_code_label'.tr(),
                        hint: '13325',
                        controller: _postalCodeController,
                        keyboardType: TextInputType.number,
                        validator: _postalCodeValidator,
                      ),
                      SizedBox(height: 16.h),
                      _buildDefaultToggle(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  // ── Validators ───────────────────────────────────────────────────────────────
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'market.field_required_error'.tr();
    }
    return null;
  }

  String? _postalCodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'market.field_required_error'.tr();
    }
    if (value.trim().length < 5) {
      return 'market.postal_code_length_error'.tr();
    }
    return null;
  }

  // ── Widgets ──────────────────────────────────────────────────────────────────
  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'market.map_location_label'.tr(),
              style: TextStyleManager.style11Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyleManager.style11Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (_pickedLocation != null) ...[
          // Tappable static preview → re-opens picker
          GestureDetector(
            onTap: _openMapPicker,
            child: AbsorbPointer(
              child: StaticMapPreview(
                key: ValueKey(_pickedLocation),
                coordinates: _pickedLocation!,
                height: 150,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _openMapPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_location_alt_outlined,
                    size: 16.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  'market.change_location'.tr(),
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Empty state → tap to open picker
          GestureDetector(
            onTap: _openMapPicker,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_location_alt_outlined,
                      color: AppColors.primary, size: 32.sp),
                  SizedBox(height: 8.h),
                  Text(
                    'market.tap_to_select_location'.tr(),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'market.set_as_default_label'.tr(),
            style: TextStyleManager.style11Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          Switch(
            value: _isDefault,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => setState(() => _isDefault = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SizedBox(
        height: 47.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              _isEditMode
                  ? 'market.edit_address_title'.tr()
                  : 'market.add_new_address'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 47.w,
                  height: 47.w,
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyleManager.style11Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyleManager.style11Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: keyboardType == TextInputType.number
                ? null
                : [NoScriptInputFormatter()],
            decoration: InputDecoration(
              labelStyle: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textPrimary,
              ),
              hintText: hint,
              hintStyle: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              errorStyle: TextStyleManager.style9Medium.copyWith(
                color: AppColors.error,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.error, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 33.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditMode
                              ? 'market.edit_button'.tr()
                              : 'market.add_button'.tr(),
                          style: TextStyleManager.style15Medium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
