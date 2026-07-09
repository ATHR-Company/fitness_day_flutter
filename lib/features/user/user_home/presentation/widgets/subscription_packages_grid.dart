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
        return SubscriptionPackageCard(
          package: widget.packages[index],
          isSelected: _selectedIndices.contains(index),
          onTap: () {
            setState(() {
              if (_selectedIndices.contains(index)) {
                _selectedIndices.remove(index);
              } else {
                _selectedIndices.add(index);
              }
            });
          },
        );
      },
    );
  }
}
