import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/chat_details_page.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/pages/ai_coach_chat_screen.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/conversations_shimmer_loading.dart';
import 'package:fitness_day/features/user/support/presentation/manager/contact_us_cubit.dart';
import 'package:fitness_day/features/user/support/presentation/manager/contact_us_state.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  late final ContactUsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<ContactUsCubit>();
    _cubit.fetchUserChat();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.black,
                        size: 20.sp,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        LocaleKeys.contact_us_contact_us_title.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyleManager.heading2.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // ── Subtitle ─────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  LocaleKeys.contact_us_contact_us_subtitle.tr(),
                  textAlign: TextAlign.start,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ── AI Coach Card (Always Visible) ──────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _ContactCard(
                  title: LocaleKeys.contact_us_contact_us_ai_coach.tr(),
                  subtitle: LocaleKeys.contact_us_contact_us_ai_desc.tr(),
                  rawImage: true,
                  image: AppImage(
                    AppImages.ai,
                    width: 70.r,
                    height: 70.r,
                    fit: BoxFit.contain,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiCoachChatScreen()),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // ── Specialist Card (Shown conditionally if user has a chat) ────
              BlocBuilder<ContactUsCubit, ContactUsState>(
                builder: (context, state) {
                  if (state is ContactUsLoading) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: const SpecialistCardShimmer(),
                    );
                  }

                  if (state is ContactUsLoaded && state.hasSpecialistChat) {
                    final conversation = state.conversation!;
                    final otherParty = conversation.otherParty!;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _ContactCard(
                        title: otherParty.name.isNotEmpty
                            ? otherParty.name
                            : LocaleKeys.contact_us_contact_us_specialist_title.tr(),
                        subtitle: conversation.displayLastMessage ??
                            LocaleKeys.contact_us_contact_us_ai_desc.tr(),
                        unreadCount: conversation.unreadCount,
                        image: otherParty.avatar != null && otherParty.avatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  otherParty.avatar!,
                                  width: 70.r,
                                  height: 70.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => AppImage(
                                    SvgIcons.logo,
                                    width: 70.r,
                                    height: 70.r,
                                  ),
                                ),
                              )
                            : AppImage(SvgIcons.logo, width: 70.r, height: 70.r),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailsPage(
                                title: otherParty.name.isNotEmpty
                                    ? otherParty.name
                                    : LocaleKeys.contact_us_contact_us_specialist_title.tr(),
                                isSpecialist: true,
                                specialistId: otherParty.id,
                                conversationId: conversation.conversationId,
                                avatarUrl: otherParty.avatar,
                              ),
                            ),
                          );
                          // Re-fetch user chat when returning from ChatDetailsPage to update last message/status
                          if (context.mounted) {
                            _cubit.fetchUserChat();
                          }
                        },
                      ),
                    );
                  }

                  // If no conversation exists or error, hide specialist card
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact Card
// ─────────────────────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget image;
  final bool rawImage;
  final int unreadCount;
  final VoidCallback onTap;

  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
    this.rawImage = false,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.greenMint, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            if (rawImage)
              SizedBox(width: 80.w, height: 80.h, child: image)
            else
              ClipOval(
                child: Container(
                  width: 70.r,
                  height: 70.r,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.17),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: image,
                ),
              ),

            SizedBox(width: 6.w),

            // Title + arrow + subtitle + unread count badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyleManager.style14Bold.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: unreadCount < 10
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: unreadCount >= 10
                                ? BorderRadius.circular(12.r)
                                : null,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyleManager.heading3.copyWith(
                              color: AppColors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Directionality.of(context) == ui.TextDirection.rtl
                            ? Icons.keyboard_double_arrow_left
                            : Icons.keyboard_double_arrow_right,
                        color: AppColors.primary,
                        size: 25.sp,
                      ),
                    ],
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
