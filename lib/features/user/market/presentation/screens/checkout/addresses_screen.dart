import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/edit_address_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/payment_method_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  String? selectedAddressId;

  // Sample addresses - replace with actual data from state management
  final List<Map<String, dynamic>> addresses = [
    {
      'id': '1',
      'name': 'market.mock_address_home_name'.tr(),
      'details': 'market.mock_address_home_details'.tr(),
    },
    {
      'id': '2',
      'name': 'market.mock_address_office_name'.tr(),
      'details': 'market.mock_address_office_details'.tr(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: addresses.isEmpty
                  ? _buildEmptyState()
                  : _buildAddressesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.addresses_title'.tr(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Envelope illustration
            Container(
              width: 300.w,
              height: 300.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(AppImages.emptyAddress),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // SizedBox(height: 24.h),
            Text(
              'market.no_addresses_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'market.saved_addresses_title'.tr(),
            style: TextStyleManager.style13Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 16.h),
          ...addresses.map((address) => _buildAddressCard(address)),
          SizedBox(height: 33.h),
          Container(
            width: double.infinity,
            height: 1.h,
            color: AppColors.divider,
          ),
          SizedBox(height: 33.h),
          _buildAddNewAddressButton(),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final isSelected = selectedAddressId == address['id'];
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.2),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
              // Radio button
          GestureDetector(
            onTap: () {
              setState(() {
                selectedAddressId = address['id'];
              });
            },
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPlaceholder,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent, // transparent is semantic here
              ),
              child: isSelected
                  ? Icon(
                      Icons.circle,
                      size: 10.sp,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ),
      SizedBox(width: 12.w),    
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedAddressId = address['id'];
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address['name'],
                    style: TextStyleManager.style10Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address['details'],
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Edit button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAddressScreen(
                    addressData: {
                      'name': address['name'] ?? '',
                      'neighborhood': address['neighborhood'] ?? '',
                      'street': address['street'] ?? '',
                      'postalCode': address['postalCode'] ?? '',
                      'buildingNumber': address['buildingNumber'] ?? '',
                    },
                  ),
                ),
              );
            },
            child:  Icon(
                Icons.edit,
                size: 20.sp,
                color: AppColors.primary,
              ),
          
          ),
        
      
        ],
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return GestureDetector(
      onTap: () {
        // No addressData passed → add mode: empty fields, title "اضافة عنوان جديد"
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EditAddressScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 16.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'market.add_new_address'.tr(),
              style: TextStyleManager.style13Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
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
                  onPressed: selectedAddressId == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentMethodScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.textSecondary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'market.confirm_button'.tr(),
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
