// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/clip_shadow_part.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.deepOrange,
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
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

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  TextStyle largeStyle;
  TextStyle mediumStyle;
  var colorIndex = 3;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
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
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
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
      // Update once per minute. If you want to update every second, use the following code.
      _timer = Timer(
        Duration(minutes: 1) - Duration(seconds: _dateTime.second) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      
      // Update once per second, but make sure to do it at the beginning of each new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final seconds = DateFormat('ss').format(_dateTime);
    final ampm = DateFormat('aaa').format(_dateTime);
    final _height = MediaQuery.of(context).size.height / 1.8;
    final _width = MediaQuery.of(context).size.width / 2;
    final fontSize = 60.00;
    final date = DateFormat("EEEE, dd MMM").format(_dateTime);
    largeStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'DaysOne',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 12,
          color: colors[_Element.shadow],
          offset: Offset(1, 5),
        ),
      ],
    );
    mediumStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'DaysOne',
      fontSize: fontSize - 30,
      shadows: [
        Shadow(
          blurRadius: 12,
          color: colors[_Element.shadow],
          offset: Offset(1, 5),
        ),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            colors: darkColorList[colorIndex]),
      ),
      child: Stack(
        children: <Widget>[
          buildUpperBodyContainer(_height),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildClock(_width, hour, minute, ampm),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    date,
                    style: mediumStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildUpperBodyContainer(double _height) {
    return Container(
      height: _height,
      child: ClipShadowPath(
        clipper: RoundedClipper(),
        shadow: Shadow(blurRadius: 30),
        child: Container(
          decoration: BoxDecoration(
            // Box decoration takes a gradient
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Add one stop for each color. Stops should increase from 0 to 1
              colors: colorList[colorIndex],

              // Colors are easy thanks to Flutter's Colors class.
            ),
          ),
        ),
      ),
    );
  }

  Container buildClock(double _width, String hour, String minute, String ampm) {
    return Container(
        width: _width,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(blurRadius: 20, offset: Offset(0, 5), color: Colors.black)
          ],
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            colors: colorList[colorIndex],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              hour,
              style: largeStyle,
            ),
            Text(":", style: largeStyle),
            Text(
              minute,
              style: largeStyle,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                " " + ampm,
                style: mediumStyle,
              ),
            )
          ],
        ));
  }

  List<List<Color>> colorList = [
    [
      Colors.pink[900],
      Colors.pink[900],
      Colors.pink[800],
      Colors.pink[600],
      Colors.pink[400],
    ],
    [
      Color(0xff4CA1AF),
      Color(0xffC4E0E5),
    ],
    [
      Colors.pink[600],
      Colors.pink[400],
      Colors.pink[200],
    ],  [
      Colors.pink[600],
      Colors.pink[400],
      Colors.pink[200],
    ],
   
  ];
  
  
  List<List<Color>> darkColorList = [
    [
      Color(0xff526293),
      Color(0xff2e3652),
    ],
    [
      Color(0xFFD81B60),
      Color(0xffce1867),
      Color(0xff450822),
    ],
    [
      Color(0xffc31432),
      Color(0xff240b36),
    ],
    [
      Colors.pink[900],
      Colors.pink[900],
      Colors.pink[800],
      Colors.pink[600],
      Colors.pink[400],
    ],
  ];
}
