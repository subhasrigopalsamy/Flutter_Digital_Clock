// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

import 'ui_elements_animation.dart';

enum _Element { background, text, circle }

final _lightTheme = {
  _Element.background: Color(0xFFAB6382),
  _Element.text: Color(0xFFFCBB6D),
  _Element.circle: Color(0xFFFCBB6D),
};

final _darkTheme = {
  _Element.background: Color(0xFF475c7a),
  _Element.text: Color(0xFFD8737F),
  _Element.circle: Color(0xFFFCBB6D),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  Timer _animTimer;
  TextStyle bigStyle;
  TextStyle mediumStyle;
  TextStyle mediumSmallStyle;
  TextStyle smallStyle;
  TextStyle verySmallStyle;
  double screenWidth;
  double screenHeight;

  Map<_Element, Color> colors;

  AnimationController _controller;
  UIelementsAnimation animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: new Duration(seconds: 10));

    animation = new UIelementsAnimation(_controller);

    _controller.forward();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      }
    });

    _animTimer = Timer.periodic(
        Duration(seconds: 12), (Timer t) => runShakraAnimWidgets());
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animTimer.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      //  _timer = Timer(
      //  Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      // _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final am_pm =
        !widget.model.is24HourFormat ? DateFormat('a').format(_dateTime) : "";
    final dayMonth = DateFormat('d MMM').format(_dateTime);
    final weekday = DateFormat('EEE').format(_dateTime);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final fontSize = MediaQuery.of(context).size.width / 6;

    bigStyle = GoogleFonts.workSans(
      textStyle: TextStyle(color: colors[_Element.text]),
      fontSize: fontSize,
    );

    mediumStyle = GoogleFonts.workSans(
      textStyle: TextStyle(color: colors[_Element.text]),
      fontSize: fontSize / 4,
    );
    mediumSmallStyle = GoogleFonts.workSans(
      textStyle: TextStyle(color: colors[_Element.text]),
      fontSize: fontSize / 6,
    );

    smallStyle = GoogleFonts.workSans(
      textStyle: TextStyle(color: colors[_Element.text]),
      fontSize: fontSize / 8,
    );
    verySmallStyle = GoogleFonts.workSans(
      textStyle: TextStyle(color: colors[_Element.text]),
      fontSize: fontSize / 10,
    );

    return Container(
      decoration: BoxDecoration(color: colors[_Element.background]),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          bottomShakraWidget(),
          topLeftShakraWidget(),
          baseClockWidget(
              hour + ":" + minute, am_pm, weekday + ", " + dayMonth),
        ],
      ),
    );
  }

  bottomShakraWidget() {
    double x, y;
    x = screenWidth / 5;
    y = screenHeight / 4;

    return Container(
        child: AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: animation.circleRandomOpacity.value,
            child: Container(
              height: animation.circleRandomOpacity.value,
              width: animation.circleRandomOpacity.value,
              child: CustomPaint(
                  painter: DrawCircle(
                      100,
                      x,
                      y,
                      colors[_Element.circle]
                          .withOpacity(animation.circleRandomOpacity.value))),
            ),
          ),
        );
      },
    ));
  }

  topLeftShakraWidget() {
    double x, y;
    x = -screenWidth / 5;
    y = -screenHeight / 4;

    return Container(
        child: AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: animation.circleRandomOpacity.value,
            child: Container(
              height: animation.circleRandomOpacity.value,
              width: animation.circleRandomOpacity.value,
              child: CustomPaint(
                  painter: DrawCircle(
                      50,
                      x,
                      y,
                      colors[_Element.circle]
                          .withOpacity(animation.circleRandomOpacity.value))),
            ),
          ),
        );
      },
    ));
  }

  baseClockWidget(String time, String am_pm, String date) {
    return Container(
      margin: EdgeInsets.all(30),
      child: Column(
        children: <Widget>[
          // time row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(time, style: bigStyle),
              Text(am_pm.toLowerCase(), style: mediumStyle),
            ],
          ),
          //date row
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  date,
                  style: mediumSmallStyle,
                ),
              ],
            ),
          ),

          showWeatherIcons(widget.model.weatherString),
          //weather row
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.model.temperatureString,
                  style: mediumStyle,
                ),
              ],
            ),
          ),
          //location name
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.model.location,
                  style: verySmallStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  runShakraAnimWidgets() {
    bottomShakraWidget();
    topLeftShakraWidget();
  }

  showWeatherIcons(String weatherString) {
    String assetName;
    switch (weatherString.toLowerCase()) {
      case 'foggy':
        assetName = 'assets/fog.svg';
        break;
      case 'sunny':
        assetName = 'assets/sunny.svg';
        break;
      case 'windy':
        assetName = 'assets/windy.svg';
        break;
      case 'cloudy':
        assetName = 'assets/cloudy.svg';
        break;
      case 'rainy':
        assetName = 'assets/rainy.svg';
        break;
      case 'thunderstorm':
        assetName = 'assets/thunder.svg';
        break;
      case 'snow':
        assetName = 'assets/snow.svg';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          child: new SvgPicture.asset(
            assetName,
            color: colors[_Element.text],
          ),
          width: 56,
          height: 56,
          padding: EdgeInsets.only(top: 6, bottom: 6),
        )
      ],
    );
  }
}

class DrawCircle extends CustomPainter {
  Paint _paint;
  int num;
  double x, y;

  DrawCircle(int num, double x, double y, Color opaqueColor) {
    _paint = Paint()
      ..color = opaqueColor //Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    this.num = num;
    this.x = x;
    this.y = y;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var random = new Random();
    double radius = random.nextInt(num).toDouble();
    canvas.drawCircle(Offset(x, y), radius, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
