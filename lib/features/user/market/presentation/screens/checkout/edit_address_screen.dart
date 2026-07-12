import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/map_picker_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/payment_method_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/static_map_preview.dart';

class EditAddressScreen extends StatefulWidget {
  /// Pass [addressData] to pre-fill fields (edit mode).
  /// Leave null to open in add mode with empty fields.
  final Map<String, String>? addressData;

  const EditAddressScreen({super.key, this.addressData});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _streetController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _buildingNumberController;

  LatLng? _pickedLocation;

  bool get _isEditMode => widget.addressData != null;

  @override
  void initState() {
    super.initState();
    final data = widget.addressData;
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _neighborhoodController =
        TextEditingController(text: data?['neighborhood'] ?? '');
    _streetController = TextEditingController(text: data?['street'] ?? '');
    _postalCodeController =
        TextEditingController(text: data?['postalCode'] ?? '');
    _buildingNumberController =
        TextEditingController(text: data?['buildingNumber'] ?? '');

    // Restore saved coordinates when editing
    final lat = double.tryParse(data?['lat'] ?? '');
    final lng = double.tryParse(data?['lng'] ?? '');
    if (lat != null && lng != null) {
      _pickedLocation = LatLng(lat, lng);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _buildingNumberController.dispose();
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
  void _onSave() {
    // Validate form first
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validate location
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'market.select_location_prompt'.tr(),
            style: TextStyleManager.style11Medium
                .copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isEditMode) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
        'street': _streetController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'buildingNumber': _buildingNumberController.text.trim(),
        'lat': _pickedLocation!.latitude.toString(),
        'lng': _pickedLocation!.longitude.toString(),
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
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
                      _buildField(
                        label: 'market.building_number_label'.tr(),
                        hint: '18',
                        controller: _buildingNumberController,
                        keyboardType: TextInputType.number,
                        validator: _requiredValidator,
                      ),
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
              // height: 100.h,
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            _isEditMode ? 'market.edit_address_title'.tr() : 'market.add_new_address'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20.sp,
                color: AppColors.black,
              ),
            ),
          ),
        ],
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
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isEditMode ? 'market.edit_button'.tr() : 'market.add_button'.tr(),
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
