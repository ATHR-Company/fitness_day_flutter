# Camera and Photo Permissions Usage Guide

## Overview
تم إضافة نظام كامل لإدارة صلاحيات الكاميرا والصور والميكروفون في التطبيق على iOS و Android.

## الملفات المضافة

### 1. Permission Helper (`lib/core/utils/permission_helper.dart`)
كلاس لإدارة الصلاحيات يحتوي على:
- فحص حالة الصلاحيات
- طلب الصلاحيات من المستخدم
- فتح إعدادات التطبيق
- التعامل مع حالات الرفض الدائم

### 2. Permission Dialog (`lib/core/widgets/permission_dialog.dart`)
Widget لعرض dialogs عند رفض الصلاحيات مع خيار فتح الإعدادات

### 3. Image Picker Widget (`lib/core/widgets/image_picker_widget.dart`)
Widget كامل لاختيار الصور من الكاميرا أو المعرض مع معالجة الصلاحيات تلقائياً

### 4. Permissions Settings Screen (`lib/features/settings/presentation/pages/permissions_settings_screen.dart`)
شاشة كاملة في الإعدادات لإدارة جميع الصلاحيات

## كيفية الاستخدام

### 1. استخدام Image Picker Widget

```dart
import 'package:fitness_day/core/widgets/image_picker_widget.dart';

// في أي مكان في التطبيق
ImagePickerWidget.showImageSourceSheet(
  context: context,
  onImagePicked: (File image) {
    // استخدم الصورة المختارة هنا
    setState(() {
      _selectedImage = image;
    });
  },
);
```

### 2. فحص وطلب صلاحية محددة

```dart
import 'package:fitness_day/core/utils/permission_helper.dart';

// فحص الصلاحية
bool hasPermission = await PermissionHelper.isCameraGranted();

// طلب الصلاحية
bool granted = await PermissionHelper.requestCamera();

// طلب مع معالجة الحالات المختلفة
PermissionRequestResult result = await PermissionHelper.requestCameraWithDialog();

if (result == PermissionRequestResult.granted) {
  // الصلاحية ممنوحة
} else if (result == PermissionRequestResult.permanentlyDenied) {
  // تم رفض الصلاحية بشكل دائم - اعرض dialog لفتح الإعدادات
  if (context.mounted) {
    await PermissionDialog.showCameraPermissionDialog(context);
  }
}
```

### 3. فتح شاشة إدارة الصلاحيات

```dart
import 'package:fitness_day/features/settings/presentation/pages/permissions_settings_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PermissionsSettingsScreen(),
  ),
);
```

### 4. عرض Permission Dialog

```dart
import 'package:fitness_day/core/widgets/permission_dialog.dart';

// للكاميرا
await PermissionDialog.showCameraPermissionDialog(context);

// للصور
await PermissionDialog.showPhotosPermissionDialog(context);

// للميكروفون
await PermissionDialog.showMicrophonePermissionDialog(context);
```

## الصلاحيات المضمنة

### iOS (Info.plist)
تم إضافة الصلاحيات التالية:
- `NSCameraUsageDescription` - للكاميرا
- `NSPhotoLibraryUsageDescription` - لقراءة الصور
- `NSPhotoLibraryAddUsageDescription` - لحفظ الصور
- `NSMicrophoneUsageDescription` - للميكروفون

### Android (AndroidManifest.xml)
تم إضافة الصلاحيات التالية:
- `android.permission.CAMERA` - للكاميرا
- `android.permission.READ_MEDIA_IMAGES` - لقراءة الصور (Android 13+)
- `android.permission.READ_EXTERNAL_STORAGE` - لقراءة الصور (Android 12 وأقل)
- `android.permission.RECORD_AUDIO` - للميكروفون

## الترجمات

تم إضافة جميع النصوص المطلوبة في ملفات الترجمة:
- `assets/translations/en.json`
- `assets/translations/ar.json`

المفاتيح المستخدمة:
- `permissions_settings.*` - نصوص شاشة الإعدادات
- `image_picker.*` - نصوص اختيار الصور
- `common.*` - نصوص عامة

## مثال كامل

يمكنك رؤية مثال كامل للاستخدام في:
`lib/examples/camera_photo_example.dart`

## ملاحظات مهمة

1. **iOS**: الصلاحيات يجب أن تطلب في وقت الاستخدام الفعلي فقط
2. **Android 13+**: يستخدم `READ_MEDIA_IMAGES` بدلاً من `READ_EXTERNAL_STORAGE`
3. **الرفض الدائم**: عند الرفض الدائم، يجب توجيه المستخدم لإعدادات التطبيق
4. **فتح الإعدادات**: استخدم `openAppSettings()` من `permission_handler`

## الخطوات التالية

1. دمج `ImagePickerWidget` في الأماكن التي تحتاج لاختيار الصور
2. إضافة رابط لشاشة `PermissionsSettingsScreen` في صفحة الإعدادات
3. اختبار على أجهزة حقيقية (iOS و Android)
4. التأكد من النصوص واضحة ومفهومة للمستخدم
