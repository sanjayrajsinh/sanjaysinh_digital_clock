// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/curve_clip_path.dart';
import 'package:digital_clock/animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

class DigitalClock extends StatefulWidget {
        const DigitalClock(this.model);
        final ClockModel model;
        
        @override
        _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with TickerProviderStateMixin {
        DateTime _dateTime = DateTime.now();
        AnimationController _animationController;
        Animation<double> _animation;
        Timer _timer;
        String _hour = "00",_minute = "00";
        bool isNewMinute = false, isNewHour = false;
        TextStyle largeStyle, mediumStyle;
        final fontSize = 80.00;
        double _height,_width;
        @override
        void initState() {
                super.initState();
                Future.delayed(Duration.zero,(){
                        widget.model.addListener(_updateModel);
                        _callAnimation();
                        _updateTime();
                        _updateModel();
                        final colors = Theme.of(context).brightness == Brightness.light ? _lightTheme : _darkTheme;
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
                                fontSize: fontSize / 2.5,
                                shadows: [
                                        Shadow(
                                                blurRadius: 12,
                                                color: colors[_Element.shadow],
                                                offset: Offset(1, 5),
                                        ),
                                ],
                        );
                });
        }
        
        @override
        void didUpdateWidget(DigitalClock oldWidget) {
                super.didUpdateWidget(oldWidget);
                if (widget.model != oldWidget.model) {
                        oldWidget.model.removeListener(_updateModel);
                        widget.model.addListener(_updateModel);
                }
        }
        
        void _updateModel() {
                setState(() {
                });
        }
        void _updateTime() {
                _dateTime = DateTime.now();
                var newHour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
                if (_hour != newHour) {
                        _hour=newHour;
                        isNewHour = true;
                        _callAnimation();
                } else {
                        isNewHour = false;
                }
                String newMinute = DateFormat('mm').format(_dateTime);
                if (_minute != newMinute) {
                        _minute=newMinute;
                        isNewMinute = true;
                        _callAnimation();
                } else {
                        isNewMinute = false;
                }
                // Update once per _minute. If you want to update every second, use the following code.
//                        _timer = Timer(
//                                Duration(minutes: 1) -
//                                    Duration(seconds: _dateTime.second) -
//                                    Duration(
//                                        milliseconds: _dateTime.millisecond),
//                                _updateTime,
//                        );
                // Update once per second, but make sure to do it at the beginning of each new second, so that the clock is accurate.
                _timer = Timer(
                        Duration(seconds: 1) -
                            Duration(milliseconds: _dateTime.millisecond),
                        _updateTime,
                );
        }

        void _callAnimation() {
                _animationController = AnimationController(
                        vsync: this,
                        duration: Duration(milliseconds: 600),
                )
                        ..addListener(() => setState(() {}));
                _animation = CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                );
                _animationController.forward();
        }
        
        @override
        Widget build(BuildContext context) {
                // Set landscape orientation
                initializeValue(context);
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
                                        CurveClipPath(height: _height,colors:  colorList[colorIndex]),
                                        Container(
                                                alignment: Alignment.center,
                                                child: Column(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                                _buildClockWidget(),
                                                                _buildDateWidget(),
                                                        ],
                                                ),
                                        ),
                                ],
                        ),
                );
        }

        void initializeValue(BuildContext context) {
                SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                ]);
                if (Theme.of(context).brightness == Brightness.light) {
                        colorIndex = 0;
                } else {
                        colorIndex = 1;
                }
                _height = MediaQuery.of(context).size.height / 1.8;
                _width = MediaQuery.of(context).size.width / 1.5;
        }
        
        Widget _buildClockWidget() {
                return Container(
                    width: _width,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        top: 15, bottom: 15, left: 40, right: 40),
                    decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                                    BoxShadow(blurRadius: 20,
                                        offset: Offset(0, 5),
                                        color: Colors.black)
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
                                    isNewHour
                                    ? ScaleAnimation(_animation,_hour,largeStyle)
                                    :Text(_hour, style: largeStyle,),
                                    Text(":", style: largeStyle,),
                                    isNewMinute
                                        ? ScaleAnimation(_animation,_minute,largeStyle)
                                        : Text(_minute, style: largeStyle,),
                            ],
                    ));
        }
        
        Widget _buildDateWidget() {
                return Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                       DateFormat("EEEE, dd MMM").format(_dateTime),
                                style: mediumStyle,
                        ),
                );
        }

        @override
        void dispose() {
                _timer?.cancel();
                widget.model.removeListener(_updateModel);
                widget.model.dispose();
                super.dispose();
        }

        var colorIndex = 0;
        final    darkColorList = [
                [
                        Color(0xff450822),
                        Colors.pink[900],
                        Colors.pink[800],
                        Colors.pink[600],
                        Colors.pink[400],
                ],
                [
                        Color(0xff004c56),
                        Color(0xff002e34),
                ],
        ];
        final colorList = [
                [
                        Colors.pink[800],
                        Colors.pink[600],
                        Colors.pink[400],
                ],
                [
                        Color(0xff004c56),
                        Color(0xff002e34),
                ],
        ];
}

