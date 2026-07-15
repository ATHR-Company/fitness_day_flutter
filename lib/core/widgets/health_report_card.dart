import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/info_table_card.dart';

class HealthReportCard extends StatelessWidget {
  final Map<String, dynamic>? healthReport;
  const HealthReportCard({super.key, this.healthReport});

  @override
  Widget build(BuildContext context) {
    if (healthReport == null) {
      return const InfoTableCard(
        title: 'تقريرك الصحي',
        data: [],
      );
    }

    String _val(String key) => healthReport![key]?['value']?.toString() ?? '-';
    String _unit(String key) => healthReport![key]?['unit']?.toString() ?? '';
    String _status(String key) => healthReport![key]?['status']?.toString() ?? '';

    return InfoTableCard(
      title: 'تقريرك الصحي',
      data: [
        TableRowData(label: 'الوزن :', value: _val('weight'), unit: _unit('weight')),
        TableRowData(label: 'الطول :', value: _val('height'), unit: _unit('height')),
        TableRowData(label: 'BMI :', value: _val('bmi'), unit: _status('bmi')),
        TableRowData(label: 'معدل الحرق :', value: _val('bmr'), unit: _unit('bmr')),
        TableRowData(label: 'وزن الدهون :', value: _val('fatWeight'), unit: _unit('fatWeight')),
        TableRowData(label: 'نسبة الدهون :', value: _val('fatPercentage'), unit: _unit('fatPercentage')),
        TableRowData(label: 'وزن العضلات :', value: _val('muscleWeight'), unit: _unit('muscleWeight')),
        TableRowData(label: 'نسبة العضلات :', value: _val('musclePercentage'), unit: _unit('musclePercentage')),
        TableRowData(label: 'البروتين :', value: _val('protein'), unit: _unit('protein')),
      ],
    );
  }
}

