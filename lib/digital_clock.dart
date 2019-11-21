// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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
  _Element.shadow: Color(0xFF174EA6),
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
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(seconds: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
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
    final fontSize = 70.00;
    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
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
    final mediumStyle = TextStyle(
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
    final smallStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'DaysOne',
      fontSize: fontSize - 45,
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
        // Box decoration takes a gradient
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.5, 0.7, 0.9],
          colors: [
            // Colors are easy thanks to Flutter's Colors class.
            Colors.black,
            Colors.pink[900],
            Colors.pink[800],
            Colors.pink[600],
          ],
        ),
      ),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                hour,
                style: defaultStyle,
              ),
              Text(":", style: defaultStyle),
              Text(
                minute,
                style: defaultStyle,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  " " + ampm,
                  style: mediumStyle,
                ),
              )
            ],
          )),
        ],
      ),
    );
  }
}
