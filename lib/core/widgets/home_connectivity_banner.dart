import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/network/connectivity_service.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// An inline connectivity-status banner designed to be placed **inside** the
/// scroll body of a home screen, directly below the header section.
///
/// • Slides in with [AnimatedSize] + [AnimatedOpacity] when the device loses
///   its network connection.
/// • Briefly flashes a green "back online" bar when the connection is restored,
///   then disappears automatically after 2 seconds.
/// • When neither offline nor reconnecting, the widget collapses to zero
///   height so it occupies no space in the layout.
class HomeConnectivityBanner extends StatefulWidget {
  const HomeConnectivityBanner({super.key});

  @override
  State<HomeConnectivityBanner> createState() => _HomeConnectivityBannerState();
}

class _HomeConnectivityBannerState extends State<HomeConnectivityBanner> {
  final ConnectivityService _connectivity = ConnectivityService();
  StreamSubscription<bool>? _sub;

  bool _isOnline = true;
  bool _showReconnected = false;
  Timer? _reconnectedTimer;

  @override
  void initState() {
    super.initState();
    // Seed the initial state on first render.
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

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: showBanner
          ? AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: showBanner ? 1.0 : 0.0,
              child: _BannerContent(isOnline: _isOnline),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final bool isOnline;

  const _BannerContent({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isOnline ? AppColors.success : AppColors.error;
    final IconData icon =
        isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final String text = isOnline
        ? 'errors.back_online'.tr()
        : 'errors.offline_banner'.tr();

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    );
  }
}
