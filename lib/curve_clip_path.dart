import 'package:flutter/material.dart';

class CurveClipPath extends StatelessWidget {
        final height;
        final List<Color> colors;
        
        CurveClipPath({
                @required this.height,
                @required this.colors,
        });
        
        @override
        Widget build(BuildContext context) {
                return Container(
                        height: height,
                        child: CustomPaint(
                                painter: _ClipShadowPainter(
                                        clipper: RoundedClipper(),
                                        shadow: Shadow(blurRadius: 30),
                                ),
                                child: ClipPath(
                                        clipper: RoundedClipper(),
                                        child: Container(
                                                decoration: BoxDecoration(
                                                        // Box decoration takes a gradient
                                                        gradient: LinearGradient(
                                                                // Where the linear gradient begins and ends
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                                colors: colors,
                                                                // Colors are easy thanks to Flutter's Colors class.
                                                        ),
                                                ),
                                        ),
                                ),
                        ),
                );
        }
}

class _ClipShadowPainter extends CustomPainter {
        final Shadow shadow;
        final CustomClipper<Path> clipper;
        
        _ClipShadowPainter({@required this.shadow, @required this.clipper});
        
        @override
        void paint(Canvas canvas, Size size) {
                var paint = shadow.toPaint();
                var clipPath = clipper.getClip(size).shift(shadow.offset);
                canvas.drawPath(clipPath, paint);
        }
        
        @override
        bool shouldRepaint(CustomPainter oldDelegate) {
                return true;
        }
}

class RoundedClipper extends CustomClipper<Path> {
        @override
        Path getClip(Size size) {
                var path = Path();
                path.lineTo(0.0, size.height - 100);
                path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 100);
                path.lineTo(size.width, 0.0);
                path.close();
                return path;
        }
        
        @override
        bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
