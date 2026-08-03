import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_day/core/utils/permission_helper.dart';
import 'package:easy_localization/easy_localization.dart';

/// Screen to manage app permissions in settings
class PermissionsSettingsScreen extends StatefulWidget {
  const PermissionsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PermissionsSettingsScreen> createState() =>
      _PermissionsSettingsScreenState();
}

class _PermissionsSettingsScreenState extends State<PermissionsSettingsScreen> {
  bool _cameraGranted = false;
  bool _photosGranted = false;
  bool _microphoneGranted = false;
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatuses();
  }

  /// Load current permission statuses
  Future<void> _loadPermissionStatuses() async {
    final camera = await PermissionHelper.isCameraGranted();
    final photos = await PermissionHelper.isPhotosGranted();
    final microphone = await PermissionHelper.isMicrophoneGranted();
    final location = await Permission.locationWhenInUse.isGranted;

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
      appBar: AppBar(title: Text('permissions'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'permissions_description'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildPermissionTile(
            icon: Icons.camera_alt,
            title: 'camera_permission'.tr(),
            subtitle: 'camera_permission_subtitle'.tr(),
            isGranted: _cameraGranted,
            onTap: () => _handleCameraPermission(),
          ),
          const Divider(),
          _buildPermissionTile(
            icon: Icons.photo_library,
            title: 'photos_permission'.tr(),
            subtitle: 'photos_permission_subtitle'.tr(),
            isGranted: _photosGranted,
            onTap: () => _handlePhotosPermission(),
          ),
          const Divider(),
          _buildPermissionTile(
            icon: Icons.mic,
            title: 'microphone_permission'.tr(),
            subtitle: 'microphone_permission_subtitle'.tr(),
            isGranted: _microphoneGranted,
            onTap: () => _handleMicrophonePermission(),
          ),
          const Divider(),
          _buildPermissionTile(
            icon: Icons.location_on,
            title: 'location_permission'.tr(),
            subtitle: 'location_permission_subtitle'.tr(),
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
                    'permissions_info'.tr(),
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
            isGranted ? 'allowed'.tr() : 'not_allowed'.tr(),
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
      _showAlreadyGrantedDialog('camera_permission'.tr());
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog('camera_permission'.tr());
    } else {
      final result = await PermissionHelper.requestCamera();
      setState(() {
        _cameraGranted = result;
      });
      if (!result) {
        _showPermissionDeniedDialog('camera_permission'.tr());
      }
    }
  }

  /// Handle photos permission
  Future<void> _handlePhotosPermission() async {
    final status = await PermissionHelper.getPhotosStatus();

    if (status.isGranted) {
      _showAlreadyGrantedDialog('photos_permission'.tr());
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog('photos_permission'.tr());
    } else {
      final result = await PermissionHelper.requestPhotos();
      setState(() {
        _photosGranted = result;
      });
      if (!result) {
        _showPermissionDeniedDialog('photos_permission'.tr());
      }
    }
  }

  /// Handle microphone permission
  Future<void> _handleMicrophonePermission() async {
    final status = await PermissionHelper.getMicrophoneStatus();

    if (status.isGranted) {
      _showAlreadyGrantedDialog('microphone_permission'.tr());
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog('microphone_permission'.tr());
    } else {
      final result = await PermissionHelper.requestMicrophone();
      setState(() {
        _microphoneGranted = result;
      });
      if (!result) {
        _showPermissionDeniedDialog('microphone_permission'.tr());
      }
    }
  }

  /// Handle location permission
  Future<void> _handleLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      _showAlreadyGrantedDialog('location_permission'.tr());
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog('location_permission'.tr());
    } else {
      final result = await Permission.locationWhenInUse.request();
      setState(() {
        _locationGranted = result.isGranted;
      });
      if (!result.isGranted) {
        _showPermissionDeniedDialog('location_permission'.tr());
      }
    }
  }

  /// Show already granted dialog
  void _showAlreadyGrantedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('permission_already_granted'.tr()),
        content: Text(
          'permission_already_granted_message'.tr(
            namedArgs: {'permission': permissionName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  /// Show open settings dialog
  void _showOpenSettingsDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('permission_denied'.tr()),
        content: Text(
          'permission_denied_open_settings'.tr(
            namedArgs: {'permission': permissionName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('open_settings'.tr()),
          ),
        ],
      ),
    );
  }

  /// Show permission denied dialog
  void _showPermissionDeniedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('permission_denied'.tr()),
        content: Text(
          'permission_denied_message'.tr(
            namedArgs: {'permission': permissionName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }
}
