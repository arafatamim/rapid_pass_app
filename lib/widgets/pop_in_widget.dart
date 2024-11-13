import 'package:flutter/material.dart';

class PopInWidget extends StatefulWidget {
  final Widget child;

  const PopInWidget({
    super.key,
    required this.child,
  });

  @override
  State<PopInWidget> createState() => _PopInWidgetState();
}

class _PopInWidgetState extends State<PopInWidget> {
  static const duration = Duration(milliseconds: 100);
  double _scale = 2;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: duration,
      curve: Curves.easeInOut,
      scale: _scale,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(duration, () {
      setState(() {
        _scale = 1.0;
      });
    });
  }
}
