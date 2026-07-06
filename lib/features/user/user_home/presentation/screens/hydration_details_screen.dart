import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/time_picker_bottom_sheet.dart';

class HydrationDetailsScreen extends StatefulWidget {
  const HydrationDetailsScreen({super.key});

  @override
  State<HydrationDetailsScreen> createState() => _HydrationDetailsScreenState();
}

class _HydrationDetailsScreenState extends State<HydrationDetailsScreen> {
  double currentWater = 0.000;
  final double goalWater = 2.25;

  void addWater(double amount) {
    setState(() {
      currentWater += amount;
      if (currentWater > goalWater) {
        currentWater = goalWater;
      }
    });
  }

  void removeWater(double amount) {
    setState(() {
      currentWater -= amount;
      if (currentWater < 0) {
        currentWater = 0;
      }
    });
  }

  /// يفتح Bottom Sheet الإدخال اليدوي
  void _showManualAddSheet() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: _ManualAddSheet(onAdd: addWater),
      ),
    );
  }

  /// يفتح صفحة إعدادات التذكير
  void _showWaterReminderScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _WaterReminderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double percent = currentWater / goalWater;
    if (percent > 1.0) percent = 1.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ScreenBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                SvgIcons.decor,
                fit: BoxFit.fill,
                color: const Color(0xff017D9E0D),
              ),
            ),
            // Bottom wave background
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: SvgPicture.asset(SvgIcons.WaterBG, fit: BoxFit.cover),
            ),
        
            SafeArea(
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          'شرب الماء',
                          style: TextStyleManager.heading3.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
        
                  // Main Circular Indicator
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        child: CircularPercentIndicator(
                          radius: 120.r,
                          lineWidth: 10.w,
                          percent: percent,
        
                          backgroundColor: AppColors.inactiveGray.withValues(
                            alpha: 0.2,
                          ),
                          progressColor: const Color(0xFF23C4D7),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                SvgIcons.water_wave,
                                width: 30.w,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 25.h),
                              Text(
                                currentWater.toStringAsFixed(3),
                                style: TextStyleManager.heading1.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'L $goalWater  /',
                                style: TextStyleManager.style10Medium.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
        
                      // 1L center button
                      Positioned(
                        bottom: -20.h,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _buildActionButton(
                            iconWidget: SvgPicture.asset(
                              SvgIcons.waterGlass,
                              width: 40.w,
                              height: 40.h,
                            ),
                            label: '1 L',
                            onTap: () => addWater(1.0),
                            isFilled: true,
                            size: 80.w,
                          ),
                        ),
                      ),
                    ],
                  ),
        
                  // Action Buttons Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // زر يدوي
                            Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: _buildActionButton(
                                iconWidget: SvgPicture.asset(
                                  SvgIcons.WarterAdd,
                                  width: 30.w,
                                  height: 30.w,
                                  fit: BoxFit.contain,
                                ),
                                label: 'يدوي',
                                onTap: _showManualAddSheet,
                                isFilled: true,
                                size: 80.w,
                              ),
                            ),
                            // زر الوقت / التذكير
                            Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: _buildActionButton(
                                iconWidget: SvgPicture.asset(
                                  SvgIcons.WaterClock,
                                  width: 30.w,
                                  height: 30.w,
                                  fit: BoxFit.contain,
                                ),
                                label: '12:15صباحا',
                                onTap: _showWaterReminderScreen,
                                isOutlined: true,
                                size: 80.w,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
        
                  const Spacer(),
        
                  // Minus Button
                  Padding(
                    padding: EdgeInsets.only(bottom: 50.h, right: 30.w),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => removeWater(0.25),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: const Color(0xFF23C4D7),
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required VoidCallback onTap,
    bool isFilled = false,
    bool isOutlined = false,
    double? size,
  }) {
    final buttonSize = size ?? 60.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: const Color(0xFFDAF6FF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC9F2FF), width: 1.5),
          boxShadow: isFilled || isOutlined
              ? [
                  BoxShadow(
                    color: const Color(0xFF23C4D7).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget ??
                  (icon != null
                      ? Icon(icon, color: const Color(0xFF23C4D7), size: 18.sp)
                      : SvgPicture.asset(
                          SvgIcons.WarterAdd,
                          width: buttonSize * 0.4,
                          fit: BoxFit.contain,
                        )),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet: الإضافة اليدوية
// ─────────────────────────────────────────────────────────────────────────────

class _ManualAddSheet extends StatefulWidget {
  final void Function(double) onAdd;

  const _ManualAddSheet({required this.onAdd});

  @override
  State<_ManualAddSheet> createState() => _ManualAddSheetState();
}

class _ManualAddSheetState extends State<_ManualAddSheet> {
  // الكميات المتاحة وأيقوناتها (بالترتيب من الأكبر للأصغر)
  final List<_WaterOption> _options = [
    _WaterOption(amount: 1.0, label: '1 L', iconAsset: SvgIcons.water1L),
    _WaterOption(amount: 0.75, label: '.75 L', iconAsset: SvgIcons.water75L),
    _WaterOption(amount: 0.5, label: '.5 L', iconAsset: SvgIcons.water5L),
    _WaterOption(amount: 0.3, label: '.3 L', iconAsset: SvgIcons.water3L),
    _WaterOption(amount: 0.2, label: '.2 L', iconAsset: SvgIcons.waterGlass),
  ];

  int _selectedIndex = 3; // الافتراضي 0.3L → .25L نقرّبها
  double _manualAmount = 0.25;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 3; // .3 L افتراضي
    _manualAmount = _options[_selectedIndex].amount;
  }

  void _selectOption(int index) {
    setState(() {
      _selectedIndex = index;
      _manualAmount = _options[index].amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23C4D7).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40.h),
                // أيقونة الماء في المنتصف
                Column(
                  children: [
                    SvgPicture.asset(
                      SvgIcons.water_bg,
                      width: 60.w,
                      height: 80.h,
                    ),
                  ],
                ),

                // زر X في الزاوية اليمنى
                SizedBox(height: 12.h),

                // العنوان
                Text(
                  'أدخل الكمية يدوياً',
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),

                // الكمية المختارة
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF23C4D7).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    '.${(_manualAmount * 100).toStringAsFixed(0)} L',
                    style: TextStyleManager.heading2.copyWith(
                      color: const Color(0xFF23C4D7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // صفوف الاختيارات (زجاجات / أكواب)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_options.length, (index) {
                    final opt = _options[index];
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _selectOption(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ?  Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF23C4D7)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // أيقونة الوعاء (نستخدم حجم مختلف بناءً على الكمية)
                            _buildContainerIcon(index, isSelected),
                            SizedBox(height: 4.h),
                            Text(
                              opt.label,
                              style: TextStyleManager.style10Medium.copyWith(
                                color: isSelected
                                    ? const Color(0xFF23C4D7)
                                    : AppColors.black,
                                fontWeight: 
                                     FontWeight.bold
                                  
                              
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24.h),

                // زر الحفظ
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.6.w,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAdd(_manualAmount);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8ED0F2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'حفظ',
                      style: TextStyleManager.heading3.copyWith(
                        color: Color(0xFF017D9E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF23C4D7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainerIcon(int index, bool isSelected) {
    // نستخدم أحجام مختلفة لمحاكاة الأوعية المختلفة الحجم
    final heights = [52.0, 44.0, 36.0, 30.0, 26.0];
    final widths = [22.0, 22.0, 20.0, 20.0, 22.0];
    final opt = _options[index];

    return SvgPicture.asset(
      opt.iconAsset,
      width: widths[index].w,
      height: heights[index].h,
      color: isSelected ? const Color(0xFF23C4D7) : const Color(0xFF8DDCE8),
    );
  }
}

class _WaterOption {
  final double amount;
  final String label;
  final String iconAsset;

  const _WaterOption({
    required this.amount,
    required this.label,
    required this.iconAsset,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// شاشة إعدادات التذكير
// ─────────────────────────────────────────────────────────────────────────────

class _WaterReminderScreen extends StatefulWidget {
  const _WaterReminderScreen();

  @override
  State<_WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<_WaterReminderScreen> {
  // القيم الحالية (قابلة للتعديل)
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 10);
  int _intervalMinutes = 10;
  int _reminderCount = 3;
  final double _dailyGoal = 2.25;

  // القيم الأصلية لمقارنة التغييرات
  late TimeOfDay _originalStartTime;
  late TimeOfDay _originalEndTime;
  late int _originalIntervalMinutes;
  late int _originalReminderCount;

  @override
  void initState() {
    super.initState();
    _originalStartTime = _startTime;
    _originalEndTime = _endTime;
    _originalIntervalMinutes = _intervalMinutes;
    _originalReminderCount = _reminderCount;
  }

  bool get _hasChanges =>
      _startTime != _originalStartTime ||
      _endTime != _originalEndTime ||
      _intervalMinutes != _originalIntervalMinutes ||
      _reminderCount != _originalReminderCount;

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF23C4D7).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                SvgIcons.water_bg,
                width: 80.w,
                height: 80.h,
              ),
              SizedBox(height: 33.h),
              Text(
                'حفظ التغييرات؟',
                style: TextStyleManager.heading3.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'لديك تغييرات غير محفوظة في إعدادات التذكير',
                textAlign: TextAlign.center,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 50.h),
              Row(
                children: [
                  // زر تجاهل
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDAF6FF),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'تجاهل',
                          style: TextStyleManager.style11Medium.copyWith(
                            color: const Color(0xFF23C4D7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // زر حفظ
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF23C4D7),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'حفظ',
                          style: TextStyleManager.style11Medium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      // حفظ → نحدّث القيم الأصلية ثم نرجع
      _originalStartTime = _startTime;
      _originalEndTime = _endTime;
      _originalIntervalMinutes = _intervalMinutes;
      _originalReminderCount = _reminderCount;
      return true;
    } else if (result == false) {
      // تجاهل → نرجع بدون حفظ
      return true;
    }
    // أغلق الـ dialog بدون اختيار → نبقى في الشاشة
    return false;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TimePickerBottomSheet(
        initialTime: isStart ? _startTime : _endTime,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              SvgIcons.decor,
              fit: BoxFit.fill,
              color: const Color(0xff017D9E0D),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: SvgPicture.asset(SvgIcons.WaterBG, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (AppBar)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        'تذكير شرب الماء',
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final shouldPop = await _onWillPop();
                          if (shouldPop && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 20.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // بطاقة الهدف اليومي
                        _buildSettingCard(
                          label: 'هدفك اليومي من الماء',
                          value: '$_dailyGoal L',
                          onTap: null,
                        ),
                        SizedBox(height: 30.h),

                        // عنوان "اشعارات شرب المياه"
                        Padding(
                          padding: EdgeInsets.only(right: 4.w, bottom: 10.h),
                          child: Text(
                            'اشعارات  شرب المياه',
                            style: TextStyleManager.heading3.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),

                        _buildSettingCard(
                          label: 'بداية التنبيه',
                          value: _formatTime(_startTime),
                          onTap: () => _pickTime(isStart: true),
                        ),
                        SizedBox(height: 8.h),

                        _buildSettingCard(
                          label: 'نهاية التنبيه',
                          value: _formatTime(_endTime),
                          onTap: () => _pickTime(isStart: false),
                        ),
                        SizedBox(height: 8.h),

                        _buildSettingCard(
                          label: 'مدة التنبيه',
                          value: '$_intervalMinutes دقائق',
                          onTap: () => _showIntervalPicker(),
                        ),
                        SizedBox(height: 8.h),

                        _buildSettingCard(
                          label: 'مرات التنبيه',
                          value: '$_reminderCount مرات',
                          onTap: () => _showCountPicker(),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),   // Scaffold
    );   // PopScope
  }

  Widget _buildSettingCard({
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: const Color(0xFF23C4D7).withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF23C4D7).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyleManager.heading3.copyWith(
                color: const Color(0xFF23C4D7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntervalPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) {
        final intervals = [5, 10, 15, 20, 30, 45, 60];
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مدة التنبيه',
                  style: TextStyleManager.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  alignment: WrapAlignment.center,
                  children: intervals.map((mins) {
                    final isSelected = _intervalMinutes == mins;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _intervalMinutes = mins);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF23C4D7)
                              : const Color(0xFFDAF6FF),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '$mins دقيقة',
                          style: TextStyleManager.style11Medium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCountPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) {
        final counts = [1, 2, 3, 4, 5, 6, 7, 8];
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مرات التنبيه',
                  style: TextStyleManager.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  alignment: WrapAlignment.center,
                  children: counts.map((count) {
                    final isSelected = _reminderCount == count;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _reminderCount = count);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF23C4D7)
                              : const Color(0xFFDAF6FF),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '$count مرات',
                          style: TextStyleManager.style11Medium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
