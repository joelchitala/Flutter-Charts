import 'package:flutter/material.dart';
import 'dart:math' as math;

double radians(double degrees) {
  return degrees * (math.pi / 180.0);
}

final pieColors = [
  Colors.blue,
  Colors.red,
  Colors.purple,
  Colors.black,
];

class PieData {
  final String label;
  final double value;
  final Color color;

  PieData({
    this.label = "",
    required this.value,
    this.color = Colors.black45,
  });
}

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
  final Widget? body;
  final List<PieData> dataset;

  const GapPieChart({
    super.key,
    required this.radius,
    this.textSize = 20,
    this.strokeWidth = 8,
    required this.dataset,
    this.scale = 1,
    this.gap = 10,
    this.body,
  });

  @override
  State<GapPieChart> createState() => _GapPieChartState();
}

class _GapPieChartState extends State<GapPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<ArcData> arcs;
  late Widget data;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final rem = 360 - (widget.dataset.length * widget.gap);
    final total = widget.dataset.fold(0.0, (a, data) => a + data.value) / rem;

    double currentSum = 0.0;
    arcs = widget.dataset.indexed.map(
      (item) {
        final (index, data) = item;
        var startAngle = currentSum + (index * widget.gap);
        currentSum += data.value / total;
        return ArcData(
          color: data.color,
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

    var temp = widget.dataset.map((item) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.color,
                  ),
                ),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.color,
                  ),
                ),
              ],
            ),
            Text(
              "${item.value}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
            )
          ],
        ),
      );
    }).toList();

    data = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [for (var item in temp) item],
    );

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.fromSize(
            size: Size.fromRadius(widget.radius),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ProgressPainter(
                    strokeWidth: widget.strokeWidth,
                    arcs: arcs,
                  ),
                  child: child,
                );
              },
              child: widget.body,
            ),
          ),
          const SizedBox(height: 8),
          data
        ],
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
