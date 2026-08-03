import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_day/core/utils/permission_helper.dart';
import 'package:easy_localization/easy_localization.dart';

/// Screen to manage app permissions in settings
class PermissionsSettingsScreen extends StatefulWidget {
  const PermissionsSettingsScreen({super.key});

  @override
  State<PermissionsSettingsScreen> createState() =>
      _PermissionsSettingsScreenState();
}

class _PermissionsSettingsScreenState extends State<PermissionsSettingsScreen>
    with WidgetsBindingObserver {
  bool _cameraGranted = false;
  bool _photosGranted = false;
  bool _microphoneGranted = false;
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPermissionStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatuses();
    }
  }

  /// Load current permission statuses
  Future<void> _loadPermissionStatuses() async {
    final camera = await PermissionHelper.isCameraGranted();
    final photos = await PermissionHelper.isPhotosGranted();
    final microphone = await PermissionHelper.isMicrophoneGranted();
    final location = await Permission.locationWhenInUse.isGranted;

    if (!mounted) return;
    setState(() {
      _cameraGranted = camera;
      _photosGranted = photos;
      _microphoneGranted = microphone;
      _locationGranted = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('permissions_settings.permissions'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'permissions_settings.permissions_description'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildPermissionTile(
            icon: Icons.camera_alt,
            title: 'permissions_settings.camera_permission'.tr(),
            subtitle: 'permissions_settings.camera_permission_subtitle'.tr(),
            isGranted: _cameraGranted,
            onTap: () => _handleCameraPermission(),
          ),
          const Divider(),
          _buildPermissionTile(
            icon: Icons.photo_library,
            title: 'permissions_settings.photos_permission'.tr(),
            subtitle: 'permissions_settings.photos_permission_subtitle'.tr(),
            isGranted: _photosGranted,
            onTap: () => _handlePhotosPermission(),
          ),
          const Divider(),
          _buildPermissionTile(
            icon: Icons.mic,
            title: 'permissions_settings.microphone_permission'.tr(),
            subtitle: 'permissions_settings.microphone_permission_subtitle'
                .tr(),
            isGranted: _microphoneGranted,
            onTap: () => _handleMicrophonePermission(),
          ),
          const Divider(),
          _buildPermissionTile(
            icon: Icons.location_on,
            title: 'permissions_settings.location_permission'.tr(),
            subtitle: 'permissions_settings.location_permission_subtitle'.tr(),
            isGranted: _locationGranted,
            onTap: () => _handleLocationPermission(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'permissions_settings.permissions_info'.tr(),
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build permission tile
  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isGranted ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isGranted ? Colors.green[700] : Colors.red[700],
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(subtitle),
          const SizedBox(height: 4),
          Text(
            isGranted
                ? 'permissions_settings.allowed'.tr()
                : 'permissions_settings.not_allowed'.tr(),
            style: TextStyle(
              color: isGranted ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Handle camera permission
  Future<void> _handleCameraPermission() async {
    final status = await PermissionHelper.getCameraStatus();

    if (status.isGranted) {
      await openAppSettings();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final result = await PermissionHelper.requestCamera();
      if (!mounted) return;
      setState(() {
        _cameraGranted = result;
      });
    }
  }

  /// Handle photos permission
  Future<void> _handlePhotosPermission() async {
    final status = await PermissionHelper.getPhotosStatus();

    if (status.isGranted || status.isLimited) {
      await openAppSettings();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final result = await PermissionHelper.requestPhotos();
      if (!mounted) return;
      setState(() {
        _photosGranted = result;
      });
    }
  }

  /// Handle microphone permission
  Future<void> _handleMicrophonePermission() async {
    final status = await PermissionHelper.getMicrophoneStatus();

    if (status.isGranted) {
      await openAppSettings();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final result = await PermissionHelper.requestMicrophone();
      if (!mounted) return;
      setState(() {
        _microphoneGranted = result;
      });
    }
  }

  /// Handle location permission
  Future<void> _handleLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      await openAppSettings();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final result = await Permission.locationWhenInUse.request();
      if (!mounted) return;
      setState(() {
        _locationGranted = result.isGranted;
      });
    }
  }
}
