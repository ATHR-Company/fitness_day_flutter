import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/info_table_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class HealthReportCard extends StatelessWidget {
  final Map<String, dynamic>? healthReport;
  const HealthReportCard({super.key, this.healthReport});

  @override
  Widget build(BuildContext context) {
    if (healthReport == null) {
      return InfoTableCard(
        title: LocaleKeys.visit_details_visit_summary_title.tr(),
        data: [],
      );
    }

    String val(String key) => healthReport![key]?['value']?.toString() ?? '-';
    String unit(String key) => healthReport![key]?['unit']?.toString() ?? '';
    String status(String key) => healthReport![key]?['status']?.toString() ?? '';

    String localizeUnit(String unitValue) {
      final u = unitValue.toLowerCase();
      if (u.contains('kg') || u.contains('كجم')) return LocaleKeys.visit_details_kg.tr();
      if (u.contains('cm') || u.contains('سم')) return LocaleKeys.visit_details_cm.tr();
      if (u.contains('kcal') || u.contains('cal') || u.contains('سع')) return LocaleKeys.visit_details_kcal.tr();
      return unitValue;
    }

    // Determine localized units with sensible defaults per field
    String weightUnit = localizeUnit(unit('weight'));
    if (weightUnit.isEmpty) weightUnit = LocaleKeys.visit_details_kg.tr();

    String heightUnit = localizeUnit(unit('height'));
    if (heightUnit.isEmpty) heightUnit = LocaleKeys.visit_details_cm.tr();

    String bmrUnit = localizeUnit(unit('bmr'));
    if (bmrUnit.isEmpty) bmrUnit = LocaleKeys.visit_details_kcal.tr();

    return InfoTableCard(
      title: LocaleKeys.visit_details_visit_summary_title.tr(),
      data: [
        TableRowData(label: '${LocaleKeys.visit_details_weight.tr()} :', value: val('weight'), unit: weightUnit),
        TableRowData(label: '${LocaleKeys.visit_details_height.tr()} :', value: val('height'), unit: heightUnit),
        TableRowData(label: '${LocaleKeys.visit_details_bmi.tr()} :', value: val('bmi'), unit: status('bmi')),
        TableRowData(label: '${LocaleKeys.visit_details_metabolic_rate.tr()} :', value: val('bmr'), unit: bmrUnit),
        TableRowData(label: '${LocaleKeys.visit_details_fat_mass.tr()} :', value: val('fatWeight'), unit: localizeUnit(unit('fatWeight'))),
        TableRowData(label: '${LocaleKeys.visit_details_body_fat_percentage.tr()} :', value: val('fatPercentage'), unit: localizeUnit(unit('fatPercentage'))),
        TableRowData(label: '${LocaleKeys.visit_details_muscle_weight.tr()} :', value: val('muscleWeight'), unit: localizeUnit(unit('muscleWeight'))),
        TableRowData(label: '${LocaleKeys.visit_details_muscle_percentage.tr()} :', value: val('musclePercentage'), unit: localizeUnit(unit('musclePercentage'))),
        TableRowData(label: '${LocaleKeys.visit_details_protein.tr()} :', value: val('protein'), unit: localizeUnit(unit('protein'))),
      ],
    );
  }
}

