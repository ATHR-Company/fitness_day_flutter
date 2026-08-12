import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/user_home/data/datasources/meal_analysis_exception.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/scan_meal_controller.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/scan_meal/meal_result_sheet.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/scan_meal/scan_meal_app_bar.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/scan_meal/scan_meal_camera_area.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/scan_meal/scan_meal_capture_button.dart';

/// Points the camera at a meal and turns the photo into a nutritional
/// breakdown. [ScanMealController] owns the camera and the analysis call; this
/// screen only wires the pieces together and surfaces the result.
class ScanMealScreen extends StatefulWidget {
  const ScanMealScreen({super.key});

  @override
  State<ScanMealScreen> createState() => _ScanMealScreenState();
}

class _ScanMealScreenState extends State<ScanMealScreen>
    with WidgetsBindingObserver {
  final ScanMealController _controller = ScanMealController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.handleAppLifecycle(state);
  }

  Future<void> _captureAndShowResult() async {
    try {
      final result = await _controller.captureAndAnalyze();
      if (result == null || !mounted) return;
      await showMealResultSheet(context, result);
    } on MealAnalysisException catch (e) {
      _showError(e.messageKey.tr(namedArgs: e.args));
    } catch (e) {
      debugPrint('[ScanMealScreen] capture failed: $e');
      _showError('scan_meal.unexpected_error'.tr());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showAppSnackBar(context, text: message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: AppImage(
                  SvgIcons.decor,
                  fit: BoxFit.fill,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const ScanMealAppBar(),
                    SizedBox(height: 40.h),
                    Expanded(
                      child: ScanMealCameraArea(
                        controller: _controller,
                        onRetry: _controller.initCamera,
                      ),
                    ),
                  ],
                ),
              ),
              if (_controller.isPreviewLive)
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ScanMealCaptureButton(
                      isBusy: _controller.isAnalyzing,
                      onTap: _captureAndShowResult,
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
