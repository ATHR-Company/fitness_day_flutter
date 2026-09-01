import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Full-screen map picker. Tapping on the map moves the pin.
/// The "Confirm" button pops with a [LatLng] result.
class MapPickerScreen extends StatefulWidget {
  final LatLng? initialCoordinates;

  const MapPickerScreen({super.key, this.initialCoordinates});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;

  // Default: Riyadh, Saudi Arabia
  static const LatLng _defaultLocation = LatLng(24.7136, 46.6753);

  LatLng? _pickedLocation;
  bool _isLocating = false;
  bool _mapReady = false;
  LatLng? _pendingMoveTarget;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pickedLocation = widget.initialCoordinates;
    if (_pickedLocation == null) {
      _determineCurrentPosition();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Moves the map camera, deferring the move until the map is ready.
  void _moveTo(LatLng target) {
    if (!_mapReady) {
      _pendingMoveTarget = target;
      return;
    }
    _mapController.move(target, 16.0);
  }

  void _onMapReady() {
    _mapReady = true;
    final pending = _pendingMoveTarget;
    if (pending != null) {
      _pendingMoveTarget = null;
      _mapController.move(pending, 16.0);
    }
  }

  void _applyLocation(LatLng loc) {
    if (!mounted) return;
    setState(() {
      _pickedLocation = loc;
      _isLocating = false;
    });
    _moveTo(loc);
  }

  Future<void> _determineCurrentPosition() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _stopLocating();
        _showLocationMessage(
          'market.location_service_disabled'.tr(),
          onAction: Geolocator.openLocationSettings,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _stopLocating();
        _showLocationMessage('market.location_permission_denied'.tr());
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _stopLocating();
        _showLocationMessage(
          'market.location_permission_blocked'.tr(),
          onAction: Geolocator.openAppSettings,
        );
        return;
      }

      // Show the last known fix immediately so the map is never stuck on the
      // default city while the GPS is still acquiring a precise position.
      if (_pickedLocation == null) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null && mounted && _pickedLocation == null) {
            setState(
              () => _pickedLocation = LatLng(
                lastKnown.latitude,
                lastKnown.longitude,
              ),
            );
            _moveTo(_pickedLocation!);
          }
        } catch (_) {
          // Last known position is a best-effort optimisation only.
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );

      _applyLocation(LatLng(position.latitude, position.longitude));
    } on TimeoutException {
      _stopLocating();
      if (_pickedLocation == null) {
        _fallbackToDefault();
      }
      _showLocationMessage('market.location_timeout'.tr());
    } catch (_) {
      _stopLocating();
      if (_pickedLocation == null) {
        _fallbackToDefault();
      }
      _showLocationMessage('market.location_failed'.tr());
    }
  }

  void _stopLocating() {
    if (mounted && _isLocating) setState(() => _isLocating = false);
  }

  void _fallbackToDefault() {
    if (!mounted) return;
    setState(() => _pickedLocation = _defaultLocation);
    _moveTo(_defaultLocation);
  }

  void _showLocationMessage(String message, {VoidCallback? onAction}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyleManager.style13Medium.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.black,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: onAction == null
            ? null
            : SnackBarAction(
                label: 'market.open_settings'.tr(),
                textColor: AppColors.primary,
                onPressed: onAction,
              ),
      ),
    );
  }

  void _onMapTap(TapPosition _, LatLng point) {
    setState(() => _pickedLocation = point);
  }

  void _onConfirm() {
    if (_pickedLocation != null) {
      Navigator.pop(context, _pickedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _pickedLocation ?? _defaultLocation,
                      initialZoom: 15.0,
                      onTap: _onMapTap,
                      onMapReady: _onMapReady,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.fitness.fitness_day',
                      ),
                      if (_pickedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pickedLocation!,
                              width: 40,
                              height: 40,
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.error,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (_isLocating)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ColoredBox(
                          color: AppColors.black.withValues(alpha: 0.08),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  // My location button
                  PositionedDirectional(
                    bottom: 16.h,
                    start: 16.w,
                    child: FloatingActionButton.small(
                      heroTag: 'my_location',
                      backgroundColor: AppColors.white,
                      onPressed: _isLocating ? null : _determineCurrentPosition,
                      child: Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SizedBox(
        height: 47.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'market.map_picker_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 47.w,
                  height: 47.w,
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: _pickedLocation == null ? null : _onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textSecondary.withValues(
                alpha: 0.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'market.confirm_location'.tr(),
              style: TextStyleManager.style15Medium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
