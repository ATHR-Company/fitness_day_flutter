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
// Article List Card
// ─────────────────────────────────────────────────────────────────────────────
class ArticleListCard extends StatefulWidget {
  final ArticleData article;
  final VoidCallback? onTap;

  const ArticleListCard({super.key, required this.article, this.onTap});

  @override
  State<ArticleListCard> createState() => _ArticleListCardState();
}

class _ArticleListCardState extends State<ArticleListCard> {
  late bool _isSaved;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.article.isSaved;
  }

  /// Follows the cubit when the flag is changed somewhere else. Without this the
  /// local copy taken in [initState] would keep showing the old bookmark even
  /// after the list itself has been patched.
  @override
  void didUpdateWidget(ArticleListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isLoading && widget.article.isSaved != oldWidget.article.isSaved) {
      _isSaved = widget.article.isSaved;
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

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
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: AppShadows.primaryShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with bookmark ──────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: AppImage(
                    widget.article.imageUrl,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: _toggleSave,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.primaryShadow,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22.sp,
                              height: 22.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(
                              _isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_sharp,
                              color: AppColors.primary,
                              size: 22.sp,
                            ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Content ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 14.sp, color: AppColors.textSecondary),
                          SizedBox(width: 4.w),
                          Text(
                            widget.article.date,
                            style: TextStyleManager.style10Medium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye_outlined,
                              size: 14.sp, color: AppColors.primary),
                          SizedBox(width: 4.w),
                          Text(
                            '${widget.article.views}',
                            style: TextStyleManager.style10Medium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    widget.article.title,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.article.body,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
