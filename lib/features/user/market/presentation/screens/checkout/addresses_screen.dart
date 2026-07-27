import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/user/market/domain/entities/address_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/addresses_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/checkout_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/edit_address_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/payment_method_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/order_summary_panel.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddressesCubit>()..load(),
      child: const _AddressesView(),
    );
  }
}

class _AddressesView extends StatelessWidget {
  const _AddressesView();

  Future<void> _openEdit(BuildContext context, {AddressData? address}) {
    final cubit = context.read<AddressesCubit>();
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditAddressScreen(address: address),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AddressData address) async {
    final cubit = context.read<AddressesCubit>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('market.delete_address_title'.tr()),
        content: Text('market.delete_address_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('market.cancel_sub_back'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'market.delete_button'.tr(),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final bool ok = await cubit.deleteAddress(address.id);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('market.address_delete_error'.tr()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              child: BlocBuilder<AddressesCubit, AddressesState>(
                builder: (context, state) {
                  if (state is AddressesFailure) {
                    return _buildErrorState(context, state.message);
                  }
                  if (state is AddressesSuccess) {
                    return state.addresses.isEmpty
                        ? _buildEmptyState()
                        : _buildAddressesList(context, state);
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<AddressesCubit, AddressesState>(
        builder: (context, state) {
          // Nothing to deliver to yet — there is no order to summarise, so the
          // bottom bar only offers "add an address".
          if (state is AddressesSuccess && state.addresses.isEmpty) {
            return _buildAddAddressBottomBar(context);
          }
          final String? selectedId =
              state is AddressesSuccess ? state.selectedAddressId : null;
          final bool isMutating =
              state is AddressesSuccess && state.isMutating;
          return _buildBottomButton(context, selectedId, isMutating);
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.addresses_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20.sp,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.read<AddressesCubit>().load(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'market.retry_button'.tr(),
                style: TextStyleManager.style11Medium
                    .copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300.w,
              height: 300.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(AppImages.emptyAddress),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              'market.no_addresses_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesList(BuildContext context, AddressesSuccess state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'market.saved_addresses_title'.tr(),
            style: TextStyleManager.style13Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 16.h),
          ...state.addresses.map(
            (address) => _buildAddressCard(context, address, state),
          ),
          SizedBox(height: 33.h),
          Container(
            width: double.infinity,
            height: 1.h,
            color: AppColors.divider,
          ),
          SizedBox(height: 33.h),
          _buildAddNewAddressButton(context),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressData address,
    AddressesSuccess state,
  ) {
    final bool isSelected = state.selectedAddressId == address.id;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.2),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                context.read<AddressesCubit>().selectAddress(address.id),
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPlaceholder,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.circle, size: 10.sp, color: AppColors.white)
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<AddressesCubit>().selectAddress(address.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style: TextStyleManager.style10Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${address.district}، ${address.street}',
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => _openEdit(context, address: address),
            child: Icon(Icons.edit, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => _confirmDelete(context, address),
            child: Icon(Icons.delete_outline, size: 20.sp, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewAddressButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openEdit(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_ios, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              'market.add_new_address'.tr(),
              style: TextStyleManager.style13Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rounded white sheet the bottom bar always sits in.
  Widget _buildBottomSheetShell(List<Widget> children) {
    return Container(
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
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom bar for the empty state: a single "add address" call to action
  /// instead of the order summary and the confirm button.
  Widget _buildAddAddressBottomBar(BuildContext context) {
    return _buildBottomSheetShell([
      SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed: () => _openEdit(context),
          icon: Icon(Icons.add_location_alt_outlined,
              size: 20.sp, color: AppColors.white),
          label: Text(
            'market.add_new_address'.tr(),
            style: TextStyleManager.style15Medium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 0,
          ),
        ),
      ),
    ]);
  }

  Widget _buildBottomButton(
    BuildContext context,
    String? selectedAddressId,
    bool isMutating,
  ) {
    return _buildBottomSheetShell([
      const OrderSummaryPanel(),
      SizedBox(height: 16.h),
      SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: selectedAddressId == null || isMutating
              ? null
              : () {
                  final checkoutCubit = context.read<CheckoutCubit>();
                  checkoutCubit.setAddress(selectedAddressId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: checkoutCubit,
                        child: const PaymentMethodScreen(),
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor:
                AppColors.textSecondary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'market.confirm_button'.tr(),
            style: TextStyleManager.style15Medium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ]);
  }
}
