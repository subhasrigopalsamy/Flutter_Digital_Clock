import 'package:flutter/material.dart';

class UIelementsAnimation {
  UIelementsAnimation(this.controller)
      : circleRandomOpacity = new TweenSequence(<TweenSequenceItem<double>>[
    TweenSequenceItem<double>(
      tween: new Tween(begin: 0.0, end: 1.0),
      weight: 50.0,
    ),
    TweenSequenceItem<double>(
      tween: new Tween(begin: 1.0, end: 0.0),
      weight: 50.0,
    ),
  ],
  ).animate(
    CurvedAnimation(
      parent: controller,
      curve: Interval(0.0, 1.000, curve: Curves.ease),
    ),
  );



  final AnimationController controller;
  final Animation<double> circleRandomOpacity;

}