import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/network/connectivity_service.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Wraps the whole app and slides a banner down from the top whenever the
/// device loses its network connection. Wire it once at the app root via
/// `MaterialApp.router(builder: ...)`.
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final ConnectivityService _connectivity = ConnectivityService();
  StreamSubscription<bool>? _sub;

  bool _isOnline = true;
  // Briefly show a green "back online" confirmation after reconnecting.
  bool _showReconnected = false;
  Timer? _reconnectedTimer;

  @override
  void initState() {
    super.initState();
    _connectivity.isOnline.then((online) {
      if (mounted) setState(() => _isOnline = online);
    });
    _sub = _connectivity.onStatusChange.listen(
      _onStatusChange,
      onError: (_) {},
    );
  }

  void _onStatusChange(bool online) {
    if (online == _isOnline) return;
    setState(() => _isOnline = online);

    _reconnectedTimer?.cancel();
    if (online) {
      setState(() => _showReconnected = true);
      _reconnectedTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showReconnected = false);
      });
    } else {
      _showReconnected = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reconnectedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showBanner = !_isOnline || _showReconnected;

    return Stack(
      children: [
        widget.child,
        // The banner sits above everything, respecting the top safe area.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              offset: showBanner ? Offset.zero : const Offset(0, -1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: showBanner ? 1 : 0,
                child: _BannerBody(isOnline: _isOnline),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerBody extends StatelessWidget {
  final bool isOnline;

  const _BannerBody({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final Color color = isOnline ? AppColors.success : AppColors.error;
    final IconData icon =
        isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final String text = isOnline
        ? 'errors.back_online'.tr()
        : 'errors.offline_banner'.tr();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: color,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 6.h,
          bottom: 8.h,
          left: 16.w,
          right: 16.w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 16.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyleManager.style12Regular.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
