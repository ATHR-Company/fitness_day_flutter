import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/features/shared/notifications/presentation/pages/notifications_page.dart';
import 'package:fitness_day/features/specialist/notifications/presentation/manager/specialist_notifications_cubit.dart';
import 'package:fitness_day/features/specialist/notifications/presentation/manager/specialist_notifications_state.dart';

/// Wires the specialist notifications API into the shared [NotificationsPage] UI.
class SpecialistNotificationsPage extends StatelessWidget {
  const SpecialistNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.getIt<SpecialistNotificationsCubit>()..getNotifications(),
      child: const _SpecialistNotificationsPageContent(),
    );
  }
}

class _SpecialistNotificationsPageContent extends StatefulWidget {
  const _SpecialistNotificationsPageContent();

  @override
  State<_SpecialistNotificationsPageContent> createState() =>
      _SpecialistNotificationsPageContentState();
}

class _SpecialistNotificationsPageContentState
    extends State<_SpecialistNotificationsPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SpecialistNotificationsCubit>().loadMoreNotifications();
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
    return BlocBuilder<SpecialistNotificationsCubit, SpecialistNotificationsState>(
      builder: (context, state) {
        final cubit = context.read<SpecialistNotificationsCubit>();

        if (state is SpecialistNotificationsFailure) {
          return NotificationsPage(
            errorMessage: state.message,
            onRetry: () => cubit.getNotifications(isRefresh: true),
          );
        }

        final notifications = switch (state) {
          SpecialistNotificationsSuccess(:final notifications) => notifications,
          SpecialistNotificationsLoadingMore(:final notifications) => notifications,
          _ => null,
        };

        return NotificationsPage(
          isLoading: notifications == null,
          isLoadingMore: state is SpecialistNotificationsLoadingMore,
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
        );
      },
    );
  }
}
