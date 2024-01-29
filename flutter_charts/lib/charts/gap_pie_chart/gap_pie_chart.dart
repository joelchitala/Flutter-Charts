import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_charts/charts/gap_pie_chart/dataset.dart';

double radians(double degrees) {
  return degrees * (math.pi / 180.0);
}

final pieColors = [
  Colors.blue,
  Colors.red,
  Colors.purple,
  Colors.black,
];

class ArcData {
  final Color color;
  final double startAngle;
  final Animation<double> sweepAngle;

  ArcData({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
  });
}

class GapPieChart extends StatefulWidget {
  final double radius, textSize, strokeWidth, scale, gap;

  final List<Data> dataset;

  const GapPieChart({
    super.key,
    required this.radius,
    this.textSize = 20,
    this.strokeWidth = 8,
    required this.dataset,
    this.scale = 1,
    this.gap = 10,
  });

  @override
  State<GapPieChart> createState() => _GapPieChartState();
}

class _GapPieChartState extends State<GapPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<ArcData> arcs;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final rem = 360 - (widget.dataset.length * widget.gap);
    final total = widget.dataset.fold(0.0, (a, data) => a + data.value) / rem;

    final intervalGap = 1 / widget.dataset.length;

    double currentSum = 0.0;
    arcs = widget.dataset.indexed.map(
      (item) {
        final (index, data) = item;
        var startAngle = currentSum + (index * widget.gap);
        currentSum += data.value / total;
        return ArcData(
          color: pieColors[index],
          startAngle: startAngle - 90,
          sweepAngle: Tween<double>(
            begin: 0,
            end: (data.value / total),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        );
      },
    ).toList();
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.scale,
      child: SizedBox.fromSize(
        size: Size.fromRadius(widget.radius),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ProgressPainter(
                strokeWidth: widget.strokeWidth,
                arcs: arcs,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  double strokeWidth;

  final List<ArcData> arcs;

  _ProgressPainter({
    required this.strokeWidth,
    required this.arcs,
  });

  List<Paint> get paints => arcs.map((arc) {
        return Paint()
          ..color = arc.color
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
      }).toList();

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    arcs.indexed.map((item) {
      final (index, arc) = item;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        radians(arc.startAngle),
        radians(arc.sweepAngle.value),
        false,
        paints[index],
      );
    }).toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
