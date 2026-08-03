import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_day/core/utils/media_permissions.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

/// Debug screen to test and verify all permissions.
/// This screen helps verify that:
/// 1. All Info.plist entries are correct
/// 2. Permissions are properly requested
/// 3. Permissions appear in iOS Settings after being requested
class PermissionTesterScreen extends StatefulWidget {
  const PermissionTesterScreen({super.key});

  @override
  State<PermissionTesterScreen> createState() => _PermissionTesterScreenState();
}

class _PermissionTesterScreenState extends State<PermissionTesterScreen> {
  Map<String, PermissionStatus> _statuses = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _loading = true);
    
    final Map<String, PermissionStatus> statuses = {
      'Camera': await Permission.camera.status,
      'Photos': await Permission.photos.status,
      'Microphone': await Permission.microphone.status,
      'Location (When In Use)': await Permission.locationWhenInUse.status,
      'Motion & Fitness': await Permission.sensors.status,
    };

    setState(() {
      _statuses = statuses;
      _loading = false;
    });
  }

  Future<void> _requestPermission(String name, Permission permission) async {
    setState(() => _loading = true);
    
    final status = await permission.request();
    
    setState(() => _loading = false);
    
    if (!mounted) return;
    
    showAppSnackBar(
      context,
      text: '$name: ${_statusToString(status)}',
      isError: status.isDenied || status.isPermanentlyDenied,
    );
    
    await _checkAllPermissions();
  }

  Future<void> _requestCameraViaHelper() async {
    setState(() => _loading = true);
    final granted = await MediaPermissions.ensure(
      context,
      MediaPermissionKind.camera,
    );
    setState(() => _loading = false);
    
    if (!mounted) return;
    showAppSnackBar(
      context,
      text: 'Camera: ${granted ? "Granted" : "Denied"}',
      isError: !granted,
    );
    
    await _checkAllPermissions();
  }

  Future<void> _requestPhotosViaHelper() async {
    setState(() => _loading = true);
    final granted = await MediaPermissions.ensure(
      context,
      MediaPermissionKind.gallery,
    );
    setState(() => _loading = false);
    
    if (!mounted) return;
    showAppSnackBar(
      context,
      text: 'Photos: ${granted ? "Granted" : "Denied"}',
      isError: !granted,
    );
    
    await _checkAllPermissions();
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  String _statusToString(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted => '✅ Granted',
      PermissionStatus.denied => '❌ Denied',
      PermissionStatus.permanentlyDenied => '🚫 Permanently Denied',
      PermissionStatus.restricted => '⛔ Restricted',
      PermissionStatus.limited => '⚠️ Limited',
      PermissionStatus.provisional => '🔔 Provisional',
    };
  }

  Color _statusColor(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted => Colors.green,
      PermissionStatus.limited => Colors.orange,
      PermissionStatus.denied => Colors.red,
      PermissionStatus.permanentlyDenied => Colors.red.shade900,
      PermissionStatus.restricted => Colors.grey,
      PermissionStatus.provisional => Colors.blue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Tester'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAllPermissions,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📱 iOS Permission Testing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Permissions only appear in iOS Settings AFTER '
                          'they are requested at least once.\n\n'
                          'Tap "Request" below to trigger each permission dialog.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Current Permission Status:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // Display all permission statuses
                ..._statuses.entries.map((entry) {
                  return Card(
                    child: ListTile(
                      title: Text(entry.key),
                      subtitle: Text(_statusToString(entry.value)),
                      trailing: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _statusColor(entry.value),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                const Text(
                  'Test Permission Requests:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // Request buttons using direct permission_handler
                ElevatedButton.icon(
                  onPressed: () => _requestPermission('Camera', Permission.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Request Camera (Direct)'),
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () => _requestPermission('Photos', Permission.photos),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Request Photos (Direct)'),
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () => _requestPermission('Microphone', Permission.microphone),
                  icon: const Icon(Icons.mic),
                  label: const Text('Request Microphone (Direct)'),
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () => _requestPermission(
                    'Location',
                    Permission.locationWhenInUse,
                  ),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Request Location (Direct)'),
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () => _requestPermission(
                    'Motion & Fitness',
                    Permission.sensors,
                  ),
                  icon: const Icon(Icons.directions_run),
                  label: const Text('Request Motion & Fitness (Direct)'),
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'Test via MediaPermissions Helper:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // Request buttons using MediaPermissions helper
                ElevatedButton.icon(
                  onPressed: _requestCameraViaHelper,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Request Camera (via Helper)'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: _requestPhotosViaHelper,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Request Photos (via Helper)'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                
                const SizedBox(height: 24),
                
                // Settings button
                ElevatedButton.icon(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Open iOS Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                
                const SizedBox(height: 16),
                const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 How to Verify:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Tap each "Request" button above\n'
                          '2. Grant or deny the permission in the dialog\n'
                          '3. Tap "Open iOS Settings"\n'
                          '4. Scroll down to find "Fitness Day"\n'
                          '5. Verify Camera and Photos appear in the list',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
