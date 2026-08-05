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

    String _val(String key) => healthReport![key]?['value']?.toString() ?? '-';
    String _unit(String key) => healthReport![key]?['unit']?.toString() ?? '';
    String _status(String key) => healthReport![key]?['status']?.toString() ?? '';

    String _localizeUnit(String unitValue) {
      final u = unitValue.toLowerCase();
      if (u.contains('kg') || u.contains('كجم')) return LocaleKeys.visit_details_kg.tr();
      if (u.contains('cm') || u.contains('سم')) return LocaleKeys.visit_details_cm.tr();
      if (u.contains('kcal') || u.contains('cal') || u.contains('سع')) return LocaleKeys.visit_details_kcal.tr();
      return unitValue;
    }

    // Determine localized units with sensible defaults per field
    String weightUnit = _localizeUnit(_unit('weight'));
    if (weightUnit.isEmpty) weightUnit = LocaleKeys.visit_details_kg.tr();

    String heightUnit = _localizeUnit(_unit('height'));
    if (heightUnit.isEmpty) heightUnit = LocaleKeys.visit_details_cm.tr();

    String bmrUnit = _localizeUnit(_unit('bmr'));
    if (bmrUnit.isEmpty) bmrUnit = LocaleKeys.visit_details_kcal.tr();

    return InfoTableCard(
      title: LocaleKeys.visit_details_visit_summary_title.tr(),
      data: [
        TableRowData(label: '${LocaleKeys.visit_details_weight.tr()} :', value: _val('weight'), unit: weightUnit),
        TableRowData(label: '${LocaleKeys.visit_details_height.tr()} :', value: _val('height'), unit: heightUnit),
        TableRowData(label: '${LocaleKeys.visit_details_bmi.tr()} :', value: _val('bmi'), unit: _status('bmi')),
        TableRowData(label: '${LocaleKeys.visit_details_metabolic_rate.tr()} :', value: _val('bmr'), unit: bmrUnit),
        TableRowData(label: '${LocaleKeys.visit_details_fat_mass.tr()} :', value: _val('fatWeight'), unit: _localizeUnit(_unit('fatWeight'))),
        TableRowData(label: '${LocaleKeys.visit_details_body_fat_percentage.tr()} :', value: _val('fatPercentage'), unit: _localizeUnit(_unit('fatPercentage'))),
        TableRowData(label: '${LocaleKeys.visit_details_muscle_weight.tr()} :', value: _val('muscleWeight'), unit: _localizeUnit(_unit('muscleWeight'))),
        TableRowData(label: '${LocaleKeys.visit_details_muscle_percentage.tr()} :', value: _val('musclePercentage'), unit: _localizeUnit(_unit('musclePercentage'))),
        TableRowData(label: '${LocaleKeys.visit_details_protein.tr()} :', value: _val('protein'), unit: _localizeUnit(_unit('protein'))),
      ],
    );
  }
}

