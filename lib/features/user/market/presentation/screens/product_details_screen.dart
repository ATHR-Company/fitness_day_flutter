import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/user/market/presentation/screens/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductData product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageSection(),
                    SizedBox(height: 16.h),
                    _buildTitleAndQuantity(),
                    SizedBox(height: 8.h),
                    _buildPrice(),
                    SizedBox(height: 8.h),
                    _buildTag(),
                    SizedBox(height: 16.h),
                    _buildDescription(),
                    SizedBox(height: 16.h),
                    _buildSpecsSection(),
                    SizedBox(height: 16.h),
                    _buildFeaturesSection(),
                    SizedBox(height: 16.h),
                    _buildWhyChooseSection(),
                    SizedBox(height: 16.h),
                    _buildOffersSection(),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAddToCart(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'تفاصيل المنتج', // Details
            textAlign: TextAlign.center,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button (Right in RTL)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded, // Right arrow for back in RTL
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                ),
              ),
              // Cart Button (Left in RTL)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: SvgPicture.asset(
                    SvgIcons.market_icon,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Image.network(
              widget.product.imageUrl,
              height: 250.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Row(
                children: [
                  _buildIconBtn(Icons.favorite_border, AppColors.primary),
                  SizedBox(width: 8.w),
                  _buildIconBtn(Icons.share, AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }

  Widget _buildTitleAndQuantity() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              widget.product.name,
              style: TextStyleManager.heading3.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                },
                child: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '$quantity',
                style: TextStyleManager.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
                child: Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${widget.product.currentPrice.toInt()}',
            style: TextStyleManager.heading1.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'ريال',
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.black,
            ),
          ),
          SizedBox(width: 12.w),
          if (widget.product.oldPrice != null)
            Text(
              '${widget.product.oldPrice!.toInt()} ريال',
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.error,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        'الأقوى عالمياً!',
        style: TextStyleManager.style11Medium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: RichText(
        text: TextSpan(
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          children: [
            const TextSpan(
              text:
                  'أضف لمسة من الصحة والحيوية إلى يومك مع جول فت كوفي! الآن، يمكنك الحصول على حبتين بسعر 295 ريال فقط بدلاً من 500 ريال، مع خصم 40% و شحن مجاني لفتره محدوده. ',
            ),
            TextSpan(
              text: 'معرفة المزيد',
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsSection() {
    return _buildSection(
      title: 'المواصفات:',
      items: [
        'نوع المنتج: شاي أعشاب طبيعية للتخسيس والتنقية.',
        'الوزن: 36 جرام.',
        'الجودة: طبيعي 100%، خالي من المواد الحافظة والإضافات الصناعية.',
        'اعتماد (نسمع): مصرح من هيئة الغذاء والدواء السعودية.',
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return _buildSection(
      title: 'المميزات والفوائد الصحية:',
      items: [
        'تنظيم الهضم بشكل طبيعي:',
        'يخفف من الإمساك ويحسن من راحة المعدة والأمعاء.',
        'حرق الدهون وتسريع الأيض:',
        'يساعد على زيادة معدل الحرق والتخلص من الدهون الزائدة للحصول على قوام مثالي.',
        'تنقية الجسم من السموم:',
        'يطرد السموم الضارة ويعزز صحة الكلى والوظائف الحيوية.',
        'تقليل احتباس السوائل:',
        'يوازن السوائل داخل الجسم ويمنع الانتفاخ.',
        'دعم ضغط الدم الصحي:',
        'يساهم في ضبط ضغط الدم بشكل آمن وطبيعي.',
        'تحسين صحة الجهاز الهضمي:',
        'يحتوي على الزنجبيل لتخفيف آلام المعدة ودعم الهضم.',
        'زيادة كفاءة التمثيل الغذائي:',
        'غني بالشاي الأخضر والأعشاب البرية لتعزيز أكسدة الدهون.',
        'مضاد أكسدة قوي:',
        'يحارب الجذور الحرة ويمنح الجسم حيوية ونشاط.',
        'مذاق لذيذ وطبيعي:',
        'خفيف على المعدة، مناسب للاستخدام اليومي.',
      ],
    );
  }

  Widget _buildWhyChooseSection() {
    return _buildSection(
      title: 'لماذا تختار شاي كلينز من متجر هدف الرشاقة؟',
      items: [
        'منتج طبيعي وآمن 100%.',
        'معتمد من هيئة الغذاء والدواء السعودية.',
        'مناسب لمن يبحث عن فقدان وزن صحي بدون آثار جانبية.',
        'نتائج مثبتة وتجارب عملاء ناجحة.',
      ],
    );
  }

  Widget _buildOffersSection() {
    return _buildSection(
      title: 'العروض المتاحة',
      items: [
        'علبة واحدة بسعر 199 ريال بدلاً من 250 ريال.',
        'عرض حبتين بسعر 299 ريال بدلاً من 500 ريال.',
        'اختر العرض المناسب لك من خانة الخيارات قبل إضافة المنتج إلى السلة',
      ],
    );
  }

  Widget _buildSection({required String title, required List<String> items}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
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

  Widget _buildBottomAddToCart() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        SvgIcons.market_icon,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20.w,
                        height: 20.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'اضافة الى السلة',
                        style: TextStyleManager.style15Medium.copyWith(
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
        ),
      ),
    );
  }
}
