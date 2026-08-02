import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Related Article Card (small horizontal card)
// ─────────────────────────────────────────────────────────────────────────────
class RelatedArticleCard extends StatefulWidget {
  final ArticleData article;
  final VoidCallback? onTap;

  const RelatedArticleCard({super.key, required this.article, this.onTap});

  @override
  State<RelatedArticleCard> createState() => _RelatedArticleCardState();
}

class _RelatedArticleCardState extends State<RelatedArticleCard> {
  late bool _isSaved;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.article.isSaved;
  }

  /// Follows the parent when the flag is changed somewhere else — the same
  /// article can be open in the details screen above this card.
  @override
  void didUpdateWidget(RelatedArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isLoading && widget.article.isSaved != oldWidget.article.isSaved) {
      _isSaved = widget.article.isSaved;
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final useCase = getIt<ToggleSaveArticleUseCase>();
    final result = await useCase(widget.article.id);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result is Success<bool>) {
        _isSaved = result.data;
      }
    });

    if (result is Success<bool>) {
      getIt<AppEventBus>().publish(ArticleChanged(
        articleId: widget.article.id,
        isSaved: result.data,
        views: widget.article.views,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: AppShadows.primaryShadow,
        ),
        child: Row(
          children: [
            // Bookmark icon
            GestureDetector(
              onTap: _toggleSave,
              child: _isLoading
                  ? SizedBox(
                      width: 24.sp,
                      height: 24.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
            ),
            SizedBox(width: 10.w),
            // Title
            Expanded(
              child: Text(
                widget.article.title,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(width: 12.w),
            // Image on the left (leading in RTL = right side visually)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppImage(
                widget.article.imageUrl,
                width: 72.w,
                height: 72.w,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
