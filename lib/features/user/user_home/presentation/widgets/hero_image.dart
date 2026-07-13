import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

class HeroImage extends StatelessWidget {
  final String? imageUrl;

  const HeroImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.isNotEmpty == true
        ? imageUrl!
        : 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800';
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: AppImage(
        url,
        height: 180.h,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
