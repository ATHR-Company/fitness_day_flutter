import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/image_picker_widget.dart';
import 'package:fitness_day/core/utils/media_permissions.dart';
import 'package:fitness_day/features/settings/presentation/pages/permissions_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';

/// Example screen demonstrating camera and photo permissions usage
class CameraPhotoExample extends StatefulWidget {
  const CameraPhotoExample({Key? key}) : super(key: key);

  @override
  State<CameraPhotoExample> createState() => _CameraPhotoExampleState();
}

class _CameraPhotoExampleState extends State<CameraPhotoExample> {
  File? _selectedImage;

  /// Test camera permission directly
  Future<void> _testCameraPermission() async {
    final granted = await MediaPermissions.ensure(
      context,
      MediaPermissionKind.camera,
      showExplanation: true,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? 'Camera permission granted!' : 'Camera permission denied',
          ),
          backgroundColor: granted ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Test photos permission directly
  Future<void> _testPhotosPermission() async {
    final granted = await MediaPermissions.ensure(
      context,
      MediaPermissionKind.gallery,
      showExplanation: true,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? 'Photos permission granted!' : 'Photos permission denied',
          ),
          backgroundColor: granted ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Test location permission
  Future<void> _testLocationPermission() async {
    final granted = await MediaPermissions.ensure(
      context,
      MediaPermissionKind.location,
      showExplanation: true,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Location permission granted!'
                : 'Location permission denied',
          ),
          backgroundColor: granted ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PermissionsSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test Permissions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap buttons below to test permissions.\nAfter tapping, check iPhone Settings → Fitness Day to see the permission.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              if (_selectedImage != null)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                )
              else
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 32),

              // Test Camera Permission Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testCameraPermission,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Test Camera Permission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Test Photos Permission Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testPhotosPermission,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Test Photos Permission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Test Location Permission Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testLocationPermission,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Test Location Permission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 24),

              // Pick Image (Full Flow)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ImagePickerWidget.showImageSourceSheet(
                      context: context,
                      onImagePicked: (File image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: Text('pick_image'.tr()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Manage Permissions Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PermissionsSettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: Text('manage_permissions'.tr()),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
