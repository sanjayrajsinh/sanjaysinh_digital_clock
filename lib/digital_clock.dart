// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/clip_shadow_part.dart';
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
        TextStyle largeStyle;
        TextStyle mediumStyle;
        var colorIndex = 0;
        AnimationController animationController;
        Animation<double> animation;
        Animation<double> animationOpacity;
        String hour = "";
        String minute = "";
        String seconds = "";
        String ampm = "";
        bool isNewMinute = true;
        final fontSize = 80.00;
        final date = DateFormat("EEEE, dd MMM").format(DateTime.now());
        
        @override
        void initState() {
                super.initState();
                callAnimation();
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
                        if (colorIndex < colorList.length - 1)
                                colorIndex++;
                        else
                                colorIndex = 0;
                });
        }
        
        void _updateTime() {
                setState(() {
                        callAnimation();
                        _dateTime = DateTime.now();
                        hour = DateFormat(
                            widget.model.is24HourFormat ? 'HH' : 'hh').format(
                            _dateTime);
                        seconds = DateFormat('ss').format(_dateTime);
                        ampm = DateFormat('aaa').format(_dateTime);
                        String newMinute = DateFormat('mm').format(_dateTime);
                        if (minute != newMinute) {
                                minute = newMinute;
                                isNewMinute = true;
                        } else {
                                isNewMinute = false;
                        }
                        // Update once per minute. If you want to update every second, use the following code.
                        _timer = Timer(
                                Duration(minutes: 1) -
                                    Duration(seconds: _dateTime.second) -
                                    Duration(
                                        milliseconds: _dateTime.millisecond),
                                _updateTime,
                        );
                        // Update once per second, but make sure to do it at the beginning of each new second, so that the clock is accurate.
//                        _timer = Timer(
//                                Duration(seconds: 1) - Duration(
//                                    milliseconds: _dateTime.millisecond),
//                                _updateTime,
//                        );
                });
        }
        
        void callAnimation() {
                animationController = AnimationController(
                        vsync: this,
                        duration: Duration(milliseconds: 600),
                )
                        ..addListener(() => setState(() {}));
                animation = CurvedAnimation(
                        parent: animationController,
                        curve: Curves.easeInOut,
                );
                
                animationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                    animationController);
                animationController.forward();
        }
        
        @override
        Widget build(BuildContext context) {
                // Set landscape orientation
                SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                ]);
                final colors = Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? _lightTheme
                    : _darkTheme;
                final _height = MediaQuery
                    .of(context)
                    .size
                    .height / 1.8;
                final _width = MediaQuery
                    .of(context)
                    .size
                    .width / 1.5;
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
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                                buildClock(
                                                                    _width),
                                                                buildDate(),
                                                        ],
                                                ),
                                        ),
                                ],
                        ),
                );
        }
        
        Container buildClock(double _width) {
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
                                    Text(hour, style: largeStyle,),
                                    Text(":", style: largeStyle,),
                                    isNewMinute ?
                                    buildMinuteText(minute) :
                                    Text(minute, style: largeStyle,),
                                    Container(
                                        padding: EdgeInsets.only(top: 30),
                                        alignment: Alignment.bottomLeft,
                                        child: Container()
//                                            child: Column(
//                                                    crossAxisAlignment: CrossAxisAlignment.end,
//                                                    children: <Widget>[
//                                                            buildMediumText(seconds),
//                                                            Text(" " + ampm, style: mediumStyle,),
//                                                    ],
//                                            ),
                                    ),
                            ],
                    ));
        }
        
        Padding buildDate() {
                return Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(date, style: mediumStyle,),
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
                                                        begin: Alignment
                                                            .topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        // Add one stop for each color. Stops should increase from 0 to 1
                                                        colors: colorList[colorIndex],
                                                        
                                                        // Colors are easy thanks to Flutter's Colors class.
                                                ),
                                        ),
                                ),
                        ),
                );
        }
        
        Widget buildMediumText(String value) {
                return AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: animationOpacity.value,
                    child: ScaleTransition(
                            scale: animation,
                            child: Container(
                                    child: Text(
                                            value,
                                            style: mediumStyle,
                                    ),
                            ),
                    ));
        }
        
        ScaleTransition buildMinuteText(String value) {
                return ScaleTransition(
                        scale: animation,
                        child: Container(
                                child: Text(
                                        value,
                                        style: largeStyle,
                                ),
                        ),
                );
        }
        
        List<List<Color>> colorList = [
                [
                        Color(0xff004c56),
                        Color(0xff002e34),
                ],
                [
                        Color(0xff622774),
                        Color(0xffc53364),
                ],
                [
                        Color(0xff526293),
                        Color(0xff2e3652),
                ],
                [
                        Colors.pink[800],
                        Colors.pink[600],
                        Colors.pink[400],
                ],
        ];
        
        List<List<Color>> darkColorList = [
                [
                        Color(0xff004c56),
                        Color(0xff002e34),
                ],
                [
                        Color(0xff622774),
                        Color(0xffc53364),
                ],
                [
                        Color(0xff526293),
                        Color(0xff2e3652),
                ],
                [
                        Color(0xff450822),
                        Colors.pink[900],
                        Colors.pink[800],
                        Colors.pink[600],
                        Colors.pink[400],
                ],
        ];
}
