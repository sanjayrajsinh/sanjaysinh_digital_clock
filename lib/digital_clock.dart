import 'dart:async';

import 'package:sanjaysinh_digital_clock/clock_widget.dart';
import 'package:sanjaysinh_digital_clock/curve_clip_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';


enum _Element {
        background,
        text,
        shadow,
}

final _lightTheme = {
        _Element.background: Colors.blue,
        _Element.text: Colors.white,
        _Element.shadow: Colors.black,
};

final _darkTheme = {
        _Element.background: Colors.blueGrey[800],
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
        TextStyle hourTextStyle, dateStyle,secondTextStyle;
        final fontSize = 80.00;
        @override
        void initState() {
                super.initState();
                Future.delayed(Duration.zero,(){
                        widget.model.addListener(_updateModel);
                        _updateModel();
                });
        }
        void _updateModel() {
                setState(() {});
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
        Widget build(BuildContext context) {
                initializeTheme(context);
                return Container(
                        decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: darkColorList[colorIndex]),
                        ),
                        child: Stack(
                                children: <Widget>[
                                        CurveClipPath(height: MediaQuery.of(context).size.height / 1.8,colors:  colorList[colorIndex]),
                                        ClockWidget(widget.model,colorList[colorIndex],hourTextStyle,secondTextStyle,dateStyle),
                                ],
                        ),
                );
        }

        void initializeTheme(BuildContext context) {
                // Set landscape orientation
                SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                ]);
                if (Theme.of(context).brightness == Brightness.light) {
                        colorIndex = 0;
                } else {
                        colorIndex = 1;
                }
                final colors = Theme.of(context).brightness == Brightness.light ? _lightTheme : _darkTheme;
                hourTextStyle = TextStyle(
                        color: colors[_Element.text],
                        fontFamily: 'DaysOne',
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize,
                        shadows: [
                                Shadow(
                                        blurRadius: 12,
                                        color: colors[_Element.shadow],
                                        offset: Offset(1, 5),
                                ),
                        ],
                );
                dateStyle = TextStyle(
                        color: colors[_Element.text],
                        fontFamily: 'Merienda',
                        fontSize: fontSize / 3,
                        shadows: [
                                Shadow(
                                        blurRadius: 12,
                                        color: colors[_Element.shadow],
                                        offset: Offset(1, 5),
                                ),
                        ],
                );
                secondTextStyle = TextStyle(
                        color: colors[_Element.text],
                        fontFamily: 'DaysOne',
                        fontSize: fontSize /3.5,
                        fontWeight: FontWeight.w500,
                        shadows: [
                                Shadow(
                                        blurRadius: 12,
                                        color: colors[_Element.shadow],
                                        offset: Offset(1, 5),
                                ),
                        ],
                );
        }
        
        @override
        void dispose() {
                widget.model.removeListener(_updateModel);
                widget.model.dispose();
                super.dispose();
        }

        var colorIndex = 0;
        final    darkColorList = [
                [
                        Color(0xff2f3278),
                        Color(0xff8f94fb),
                ],
                [
                        Color(0xff002e34),
                        Color(0xff004c56),

                ],
                [
                        Color(0xff450822),
                        Colors.pink[900],
                        Colors.pink[800],
                        Colors.pink[600],
                        Colors.pink[400],
                ],
        ];
        final colorList = [
                [
                        Color(0xff4e54c8),
                        Color(0xff8f94fb),
                ],
                [
                        Color(0xff004c56),
                        Color(0xff002e34),
                ],
                [
                        Colors.pink[800],
                        Colors.pink[600],
                        Colors.deepOrange[200],
                ],
        ];
}

