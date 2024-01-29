import 'package:flutter/material.dart';
import 'dart:math' as math;

double radians(double degrees) {
  return degrees * (math.pi / 180.0);
}

class NPieChart extends StatefulWidget {
  final double radius, textSize, strokeWidth, scale;
  final int win, draw, loss;

  const NPieChart({
    super.key,
    required this.radius,
    required this.win,
    required this.draw,
    required this.loss,
    this.textSize = 20,
    this.strokeWidth = 8,
    this.scale = 1,
  });

  @override
  State<NPieChart> createState() => _NPieChartState();
}

class _NPieChartState extends State<NPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _win, _draw, _loss;

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

    final total = (widget.win + widget.draw + widget.loss) / 360;
    _win = Tween<double>(
      begin: 0,
      end: (widget.win / total),
    ).animate(curvedAnimation);
    _draw = Tween<double>(
      begin: 0,
      end: ((widget.win + widget.draw) / total),
    ).animate(curvedAnimation);
    _loss = Tween<double>(
      begin: 0,
      end: ((widget.win + widget.draw + widget.loss) / total),
    ).animate(curvedAnimation);

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
                winProgress: _win.value,
                drawProgress: _draw.value,
                lossProgress: _loss.value,
              ),
              child: child,
            );
          },
          child: Center(child: Text("Hello World")),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  double strokeWidth, winProgress, drawProgress, lossProgress;

  _ProgressPainter({
    required this.strokeWidth,
    required this.winProgress,
    required this.drawProgress,
    required this.lossProgress,
  });

  Paint paintFacade({
    Color color = Colors.black,
    StrokeCap strokeCap = StrokeCap.butt,
    PaintingStyle style = PaintingStyle.stroke,
  }) {
    return Paint()
      ..color = color
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    // Paint winPaint = Paint()
    //   ..color = Colors.black
    //   ..strokeCap = StrokeCap.butt
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      radians(-90),
      radians(winProgress),
      false,
      paintFacade(),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      radians(-90),
      radians(drawProgress),
      false,
      paintFacade(color: Colors.black38),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      radians(-90),
      radians(lossProgress),
      false,
      paintFacade(color: Colors.black26),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
