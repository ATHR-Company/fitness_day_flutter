import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'gemini_meal_service.dart';
import 'meal_result_sheet.dart';

class ScanMealScreen extends StatefulWidget {
  const ScanMealScreen({super.key});

  @override
  State<ScanMealScreen> createState() => _ScanMealScreenState();
}

enum _CameraState { loading, ready, permissionDenied, error }

class _ScanMealScreenState extends State<ScanMealScreen>
    with WidgetsBindingObserver {
  final TextEditingController _codeController = TextEditingController();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  _CameraState _cameraState = _CameraState.loading;
  bool _isAnalyzing = false;
  String? _errorMessage;

  // TODO: move this behind your backend before release — see notes in
  // GeminiMealService. For local testing, paste your key from
  // https://aistudio.google.com/apikey
  static const String _geminiApiKey = 'YOUR_API_KEY_HERE';
  late final GeminiMealService _mealService =
      GeminiMealService(apiKey: _geminiApiKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // Re-init/dispose camera when app goes to background/foreground so the
  // preview doesn't freeze or crash when resuming.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() => _cameraState = _CameraState.loading);

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _cameraState = _CameraState.permissionDenied);
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraState = _CameraState.ready);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _cameraState = _CameraState.error;
          _errorMessage = 'تعذر تشغيل الكاميرا. حاول مرة أخرى.';
        });
      }
    }
  }

  Future<void> _captureImage() async {
    if (_cameraState != _CameraState.ready ||
        _cameraController == null ||
        _isAnalyzing) {
      return;
    }
    setState(() => _isAnalyzing = true);
    try {
      final XFile file = await _cameraController!.takePicture();
      final result = await _mealService.analyzeMeal(File(file.path));
      if (!mounted) return;
      await showMealResultSheet(context, result);
    } on MealAnalysisException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('Error capturing/analyzing picture: $e');
      _showError('حدث خطأ غير متوقع. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                SvgIcons.decor,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  AppColors.primary.withValues(alpha: 0.05),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  SizedBox(height: 16.h),
                  _buildCodeInput(),
                  SizedBox(height: 24.h),
                  Expanded(child: _buildCameraArea()),
                ],
              ),
            ),
            if (_cameraState == _CameraState.ready) _buildCaptureButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.close_rounded,
                size: 28.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'مسح الوجبة',
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(width: 36.w),
        ],
      ),
    );
  }

  Widget _buildCodeInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ادخل الكود يدويا',
                  hintStyle: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.r),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: handle manual code lookup
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 0),
                ),
                child: Text(
                  'ارسال',
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraArea() {
    return Container(
      width: double.infinity,
      color: AppColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraState == _CameraState.ready && _cameraController != null)
            ClipRRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

          if (_cameraState == _CameraState.loading)
            Center(child: CircularProgressIndicator(color: AppColors.primary)),

          if (_cameraState == _CameraState.permissionDenied)
            _buildCenteredMessage(
              icon: Icons.no_photography_rounded,
              message: 'التطبيق يحتاج إذن الوصول للكاميرا لتصوير الوجبة',
              actionLabel: 'فتح الإعدادات',
              onAction: openAppSettings,
            ),

          if (_cameraState == _CameraState.error)
            _buildCenteredMessage(
              icon: Icons.error_outline_rounded,
              message: _errorMessage ?? 'حدث خطأ ما',
              actionLabel: 'إعادة المحاولة',
              onAction: _initCamera,
            ),

          if (_cameraState == _CameraState.ready) ...[
            Positioned.fill(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
                child: Stack(
                  children: [
                    Positioned(
                        top: 0,
                        left: 0,
                        child: _buildCorner(isTop: true, isLeft: true)),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: _buildCorner(isTop: true, isLeft: false)),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildCorner(isTop: false, isLeft: true)),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildCorner(isTop: false, isLeft: false)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'قم بمحاذاة الطعام داخل الاطار',
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Full-screen loading overlay while Gemini analyzes the photo.
          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16.h),
                    Text(
                      'جاري تحليل الوجبة...',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenteredMessage({
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.white, size: 48.sp),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyleManager.style11Medium.copyWith(color: AppColors.white),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 30.h,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _isAnalyzing ? null : _captureImage,
          child: Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.w),
              color: AppColors.primary.withValues(
                alpha: _isAnalyzing ? 0.4 : 0.8,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    final double length = 24.w;
    final double thickness = 3.w;
    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }
}
