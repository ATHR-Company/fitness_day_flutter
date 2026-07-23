import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/package_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'subscription_package_card.dart';

class SubscriptionPackagesGrid extends StatefulWidget {
  final List<SubscriptionPackageData> packages;

  const SubscriptionPackagesGrid({super.key, required this.packages});

  @override
  State<SubscriptionPackagesGrid> createState() => _SubscriptionPackagesGridState();
}

class _SubscriptionPackagesGridState extends State<SubscriptionPackagesGrid> {
  final Set<int> _selectedIndices = {};

  void _showPlanDetails(BuildContext context, SubscriptionPackageData package) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (_) => PackageDetailsDialog(planId: package.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.65, // Adjust this ratio based on card content height
      ),
      itemCount: widget.packages.length,
      itemBuilder: (context, index) {
        final package = widget.packages[index];
        return SubscriptionPackageCard(
          package: package,
          badge: package.badge,
          isSelected: _selectedIndices.contains(index),
          onTap: () => _showPlanDetails(context, package),
          onDetailsTap: () => _showPlanDetails(context, package),
        );
      },
    );
  }
}
