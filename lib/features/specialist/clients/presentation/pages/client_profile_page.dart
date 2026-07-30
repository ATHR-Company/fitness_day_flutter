import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/network_error_view.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/specialist_client_profile_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/specialist_client_profile_state.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/tabs/client_data_tab.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/tabs/client_visits_tab.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/tabs/client_progress_tab.dart';

class ClientProfilePage extends StatefulWidget {
  final String userId;

  const ClientProfilePage({super.key, required this.userId});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpecialistClientProfileCubit>(
      create: (context) => getIt<SpecialistClientProfileCubit>()
        ..getSpecialistClientProfile(userId: widget.userId),
      child: BlocBuilder<SpecialistClientProfileCubit, SpecialistClientProfileState>(
        builder: (context, state) {
          if (state is SpecialistClientProfileLoading) {
            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          } else if (state is SpecialistClientProfileFailure) {
            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: NetworkErrorView(
                onRetry: () => context.read<SpecialistClientProfileCubit>().getSpecialistClientProfile(
                      userId: widget.userId,
                    ),
              ),
            );
          } else if (state is SpecialistClientProfileSuccess) {
            return _buildContent(state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(SpecialistClientProfileDataModel clientData) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.profileGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'clients_page.client_profile'.tr(),
            style: TextStyleManager.style15Medium.copyWith(
              color: AppColors.black,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: AppSegmentedControl(
                items: [
                  'clients_page.client_data'.tr(),
                  'clients_page.visits'.tr(),
                  'clients_page.progress'.tr(),
                ],
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(child: _buildTabContent(clientData)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(SpecialistClientProfileDataModel clientData) {
    switch (_selectedIndex) {
      case 0:
        return ClientDataTab(data: clientData);
      case 1:
        return ClientVisitsTab(userId: widget.userId);
      case 2:
        return ClientProgressTab(userId: widget.userId);
      default:
        return const SizedBox.shrink();
    }
  }
}
