import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/payment_method_screen.dart';

class BranchPickupScreen extends StatelessWidget {
  const BranchPickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBranchSelector(),
                    SizedBox(height: 24.h),
                    _buildContactInfo(),
                    SizedBox(height: 24.h),
                    _buildWorkingHours(context),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
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
            'الاستلام من الفرع',
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
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

  Widget _buildBranchSelector() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 4,
              ),
            ),
          ),
        SizedBox(width: 8.w),
          Text(
            'يوم الرشاقة القطيف',
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات التواصل',
          style: TextStyleManager.style11Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 22.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call, color: AppColors.white, size: 16.sp),
            ),
              SizedBox(width: 8.w),
        
            Text(
              '+966543759100',
              textDirection: TextDirection.ltr,
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.black,
              ),
            ),
            ],
        ),
      ],
    );
  }

  Widget _buildWorkingHours(BuildContext context) {
    final List<Map<String, String>> days = [
      {'day': 'السبت', 'time': '11:00 ص - 11:00 م'},
      {'day': 'الأحد', 'time': '11:00 ص - 11:00 م'},
      {'day': 'الاثنين', 'time': '11:00 ص - 11:00 م'},
      {'day': 'الثلاثاء', 'time': '11:00 ص - 11:00 م'},
      {'day': 'الأربعاء', 'time': '11:00 ص - 11:00 م'},
      {'day': 'الخميس', 'time': '11:00 ص - 11:00 م'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ساعات العمل',
          style: TextStyleManager.style11Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            return _buildTimeCard(days[index]['day']!, days[index]['time']!);
          },
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: _buildTimeCard('الجمعة', '4:00 ص - 11:00 م'),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard(String day, String time) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              
              Icon(Icons.access_time_filled, color: AppColors.primary, size: 14.sp),
                  SizedBox(width: 4.w),
              Text(
                day,
                style: TextStyleManager.style11Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.05),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentMethodScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'تأكيد الطلب',
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
