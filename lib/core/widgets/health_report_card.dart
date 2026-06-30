import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/info_table_card.dart';

class HealthReportCard extends StatelessWidget {
  const HealthReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoTableCard(
      title: 'تقريرك الصحي',
      data: [
        TableRowData(label: 'الوزن :', value: '58.4', unit: 'كجم'),
        TableRowData(label: 'الطول :', value: '167', unit: 'سم'),
        TableRowData(label: 'BMI :', value: '22.0', unit: 'طبيعي'),
        TableRowData(label: 'معدل الحرق :', value: '1284.4'),
        TableRowData(label: 'وزن الدهون :', value: '15.7', unit: 'كجم'),
        TableRowData(label: 'نسبة الدهون :', value: '24%'),
        TableRowData(label: 'وزن العضلات :', value: '3.7', unit: 'كجم'),
        TableRowData(label: 'نسبة العضلات :', value: '24%'),
        TableRowData(label: 'البروتين :', value: '17.8'),
      ],
    );
  }
}

