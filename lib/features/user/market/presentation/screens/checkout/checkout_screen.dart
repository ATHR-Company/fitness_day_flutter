import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/addresses_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/branch_pickup_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum DeliveryMethod { shipping, branchPickup }

class _CheckoutScreenState extends State<CheckoutScreen> {
  DeliveryMethod selectedDeliveryMethod = DeliveryMethod.shipping;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16.h),
                    _buildCouponSection(),
                    SizedBox(height: 24.h),
                    _buildOrderDetailsHeader(),
                    SizedBox(height: 24.h),
                    _buildDeliveryDetailsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNext(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.checkout_title'.tr(),
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

  Widget _buildCouponSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'market.coupon_question'.tr(),
            style: TextStyleManager.style13Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            // height: 48.h,
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'market.coupon_hint'.tr(),
                      hintStyle: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.h,
                  width: 100.w,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'market.apply_button'.tr(),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: AppColors.backgroundTint,
      alignment: Alignment.center,
      child: Text(
        'market.order_details_header'.tr(),
        style: TextStyleManager.style13Medium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeliveryDetailsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'market.delivery_details_title'.tr(),
            style: TextStyleManager.style11Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDeliveryOptionCard(
            title: 'market.delivery_option_shipping'.tr(),
            method: DeliveryMethod.shipping,
            icon: Icons.local_shipping,
          ),
          SizedBox(height: 12.h),
          _buildDeliveryOptionCard(
            title: 'market.delivery_option_branch_pickup'.tr(),
            method: DeliveryMethod.branchPickup,
            icon: Icons.inventory_2,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptionCard({
    required String title,
    required DeliveryMethod method,
    required IconData icon,
  }) {
    final isSelected = selectedDeliveryMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryMethod = method;
        });
      },
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.greenLightAccent
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 18.sp),
            ),

            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyleManager.style11Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            // Radio button
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPlaceholder,
                  width: isSelected ? 4 : 1,
                ),
              ),
            ),

            // Icon
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNext() {
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

              // Order Summary Section

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDeliveryMethod == DeliveryMethod.shipping) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddressesScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BranchPickupScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'market.next_button'.tr(),
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
