import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/features/shared/notifications/presentation/pages/notifications_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/features/user/notifications/presentation/manager/user_notifications_cubit.dart';
import 'package:fitness_day/features/user/notifications/presentation/manager/user_notifications_state.dart';

/// Wires the user notifications API into the shared [NotificationsPage] UI.
class UserNotificationsPage extends StatelessWidget {
  const UserNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<UserNotificationsCubit>()..getNotifications(),
      child: const _UserNotificationsPageContent(),
    );
  }
}

class _UserNotificationsPageContent extends StatefulWidget {
  const _UserNotificationsPageContent();

  @override
  State<_UserNotificationsPageContent> createState() => _UserNotificationsPageContentState();
}

class _UserNotificationsPageContentState extends State<_UserNotificationsPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UserNotificationsCubit>().loadMoreNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(BuildContext context, String createdAt) {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return createdAt;
    final local = parsed.toLocal();
    final now = DateTime.now();
    final isToday = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final pattern = isToday ? 'hh:mm a' : 'yyyy-MM-dd hh:mm a';
    return DateFormat(pattern, context.locale.languageCode).format(local);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserNotificationsCubit, UserNotificationsState>(
      builder: (context, state) {
        final cubit = context.read<UserNotificationsCubit>();

        if (state is UserNotificationsFailure) {
          return NotificationsPage(
            errorMessage: state.message,
            onRetry: () => cubit.getNotifications(isRefresh: true),
          );
        }

        final notifications = switch (state) {
          UserNotificationsSuccess(:final notifications) => notifications,
          UserNotificationsLoadingMore(:final notifications) => notifications,
          _ => null,
        };

        return NotificationsPage(
          isLoading: notifications == null,
          isLoadingMore: state is UserNotificationsLoadingMore,
          items: notifications
              ?.map((n) => NotificationItem(
                    title: n.title,
                    subtitle: n.message,
                    time: _formatTime(context, n.createdAt),
                    isRead: n.read,
                    image: n.image,
                    onToggleRead: () => cubit.toggleRead(n.id),
                  ))
              .toList(),
          onRefresh: () => cubit.getNotifications(isRefresh: true),
          scrollController: _scrollController,
          drawer: UserAppDrawer(isSubscribed: di.getIt<AppCache>().getIsSubscribed()),
        );
      },
    );
  }
}
