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
  final Animation<double> sweepAngle;

  ArcData({
    required this.color,
    required this.sweepAngle,
  });
}

class NPieChart extends StatefulWidget {
  final double radius, textSize, strokeWidth, scale;

  final List<Data> dataset;

  const NPieChart({
    super.key,
    required this.radius,
    this.textSize = 20,
    this.strokeWidth = 8,
    required this.dataset,
    this.scale = 1,
  });

  @override
  State<NPieChart> createState() => _NPieChartState();
}

class _NPieChartState extends State<NPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<ArcData> arcs;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    var curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    final total = widget.dataset.fold(0.0, (a, data) => a + data.value);

    double currentSum = 0.0;
    arcs = widget.dataset.indexed.map(
      (item) {
        final (index, data) = item;
        currentSum += data.value;
        return ArcData(
          color: pieColors[index],
          sweepAngle: Tween<double>(
            begin: 0,
            end: (currentSum / total),
          ).animate(curvedAnimation),
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
          ..strokeCap = StrokeCap.butt
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
        radians(-90),
        radians(arc.sweepAngle.value * 360),
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
