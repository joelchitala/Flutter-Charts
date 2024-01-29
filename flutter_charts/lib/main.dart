import 'package:flutter/material.dart';
import 'package:flutter_charts/charts/donut_chart.dart';
import 'package:flutter_charts/charts/gap_pie_chart/dataset.dart';
import 'package:flutter_charts/charts/gap_pie_chart/gap_pie_chart.dart';
import 'package:flutter_charts/charts/n_pie_chart.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: MainScreen(),
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return _testCharts(
                      title: "NPieChart",
                      const NPieChart(
                        radius: 100,
                        win: 4,
                        draw: 2,
                        loss: 1,
                      ),
                    );
                  },
                ),
              );
            },
            child: const Text("NPie-Chart"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return _testCharts(
                      title: "Gap Pie Chart",
                      GapPieChart(
                        radius: 100,
                        dataset: dataset,
                        strokeWidth: 14,
                        gap: 16,
                      ),
                    );
                  },
                ),
              );
            },
            child: const Text("Gap-Pie-Chart"),
          ),
        ],
      ),
    );
  }
}

Widget _testCharts(Widget chart, {String title = ""}) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      centerTitle: true,
    ),
    body: Center(
      child: chart,
    ),
  );
}
