import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';


class UnsubscribedHeroImage extends StatelessWidget {
  final String imageUrl;

  const UnsubscribedHeroImage({
    super.key,
    this.imageUrl = 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
        ),
        child:Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            
      ),
    );
  }
}
