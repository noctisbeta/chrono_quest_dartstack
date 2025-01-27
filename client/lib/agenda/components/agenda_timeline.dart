import 'package:chrono_quest/agenda/components/agenda_painter.dart';
import 'package:flutter/material.dart';

class AgendaTimeline extends StatefulWidget {
  const AgendaTimeline({super.key});

  @override
  State<AgendaTimeline> createState() => _AgendaTimelineState();
}

class _AgendaTimelineState extends State<AgendaTimeline>
    with TickerProviderStateMixin {
  double offset = 0;

  DateTime currentTime = DateTime.now();

  late AnimationController _animationController;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _animationController.reset();
    _animation = Tween<double>(begin: offset, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    )..addListener(() {
        setState(() {
          offset = _animation.value;
        });
      });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  offset += details.primaryDelta!;
                });
              },
              child: CustomPaint(
                painter: AgendaPainter(
                  offset: offset,
                  currentTime: currentTime,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _startAnimation,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
}
