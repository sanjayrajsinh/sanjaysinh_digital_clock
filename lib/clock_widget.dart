import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'animated_widget.dart';

class ClockWidget extends StatefulWidget {
  final ClockModel model;
  final List<Color> bgColor;
  final TextStyle largeStyle, smallStyle, dateStyle;

  ClockWidget(this.model, this.bgColor, this.largeStyle, this.smallStyle,
      this.dateStyle);

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget>
    with TickerProviderStateMixin {
  Timer _timer;
  Animation<double> _animation;
  AnimationController _animationController;
  String _hour = "00", _minute = "00", _second = "00", _AM_PM = "",_todayDate="";
  bool isSecondChange = true, isMinuteChange = true, isHourChange = true,isDateChange=true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      widget.model.addListener(_updateModel);
      _runAnimation();
      _updateTime();
      _updateModel();
    });
  }

  @override
  void didUpdateWidget(ClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    DateTime _dateTime = DateTime.now();
    String newMinute = DateFormat('mm').format(_dateTime);
    if (_minute != newMinute) {
      _minute = newMinute;
      isMinuteChange = true;
    } else {
      isMinuteChange = false;
    }
    var newHour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    if (_hour != newHour) {
      _hour = newHour;
      _AM_PM = DateFormat('aa').format(_dateTime);
      isHourChange = true;
      _runAnimation();
    } else {
      isHourChange = false;
    }
    var newDate=DateFormat("EEEE, dd MMM").format(_dateTime);
    if(_todayDate != newDate){
      _todayDate=newDate;
      isDateChange=true;
    }else{
      isDateChange=false;
    }
    String newSecond = DateFormat("ss").format(_dateTime);
    if (_second != newSecond) {
      _second = newSecond;
      isSecondChange = true;
      _runAnimation();
    } else {
      isSecondChange = false;
    }
    _timer = Timer(
      // Update once per second
      Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      _updateTime,
    );
    
    
//    _timer = Timer(
//           //Update once per _minute
//            Duration(minutes: 1) -
//                Duration(seconds: _dateTime.second) -
//                Duration(
//                    milliseconds: _dateTime.millisecond),
//            _updateTime,
//    );
  }

  void _runAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..addListener(() => setState(() {}));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 60),
              decoration: buildBoxDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildHour(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(":", style: widget.largeStyle),
                  ),
                  _buildMinute(),
                  _buildSecond()
                ],
              ),
            ),
          ),
         _buildDate()
        ]);
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: Offset(0, 5),
                    color: Colors.black)
              ],
              // Box decoration takes a gradient
              gradient: LinearGradient(
                // Where the linear gradient begins and ends
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Add one stop for each color. Stops should increase from 0 to 1
                colors: widget.bgColor,
              ),
            );
  }

  Widget _buildHour() {
    return isHourChange
        ? ScaleAnimation(_animation, _hour, widget.largeStyle)
        : Text(
            _hour,
            style: widget.largeStyle,
          );
  }
  Widget _buildMinute() {
    return isMinuteChange
        ? ScaleAnimation(_animation, _minute, widget.largeStyle)
        : Text(
      _minute,
      style: widget.largeStyle,
    );
  }
  Container _buildSecond() {
    return Container(
      width: 70,
      margin: EdgeInsets.only(left: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          isSecondChange
              ? ScaleAnimation(_animation, _second, widget.smallStyle)
              : Text(
            _second,
            style: widget.smallStyle,
          ),
          Text(
            _AM_PM,
            style: widget.smallStyle,
          ),
        ],
      ),
    );
  }
  Padding _buildDate() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: isDateChange
          ? ScaleAnimation(_animation,
          _todayDate, widget.dateStyle)
          : Text(
        _todayDate,
        style: widget.dateStyle,
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
}
