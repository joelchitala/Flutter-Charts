import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChart extends StatefulWidget {
  const DonutChart({super.key});

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  showTitle: false,
                  radius: 20,
                  badgePositionPercentageOffset: 2,
                ),
                PieChartSectionData(
                  color: Colors.red,
                  showTitle: false,
                  radius: 20,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
