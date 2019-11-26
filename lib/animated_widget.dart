import 'package:flutter/material.dart';

class ScaleAnimation extends AnimatedWidget {
  final animation;
  final textValue;
  final textStyle;

  ScaleAnimation(this.animation, this.textValue, this.textStyle)
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        child: Text(
          textValue,
          style: textStyle,
        ),
      ),
    );
  }
}
