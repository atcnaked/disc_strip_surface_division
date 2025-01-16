import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'equaldiscstrips3.dart';

/// paints a disc with vertical colored strips starting at xSplits proportion.  angle is experimental.
///
/// xSplits are increasing double between 0 and 1 and represent the proportion of the width of the disc
/// Colors is determined by looping over the _colors List (which has a default value).
/// shouldRepaint has been optimized
/// TODO: implement minimum size
/// minimum size was implemented but the center of rotation is no longer the disc center
class DiscStrips extends CustomPainter {
  /// xSplits list of double between 0 and 100
  final List<double> xSplits; // = [11, 30, 42, 75];
  //  final List<double> xSplits = [11, 30, 42, 75];
  static const List<Color> defautlColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.grey,
    Colors.yellow,
  ];
  final List<Color> _colors;
  final double angle;
  final double minDimension;
  final bool showNumbers;
  final bool showHelpGraphics;
  final bool showXaxis;

  const DiscStrips({
    super.repaint,
    required this.xSplits,
    required this.angle,
    required this.showNumbers,
    required this.showHelpGraphics,
    required this.showXaxis,
    List<Color>? colorsP,
    double? minDimensionParam,
  })  : _colors = colorsP ?? defautlColors,
        minDimension = minDimensionParam ?? 50;
  @override
  void paint(Canvas canvas, Size size) {
    //  canvas.clipRect(Rect.fromLTWH(0, 0,size. width, size.height));
    var center = size / 2;

    // the size of the Rect where we will draw later on
    // we need this numbers here in order to do a canvas.clipRect
    final double freeSquareSideLength =
        size.width < size.height ? size.width : size.height;
    final Offset SquareTLCorner = size.width < size.height
        ? Offset(0, (size.height - size.width) / 2)
        : Offset((size.width - size.height) / 2, 0);
    final squareRect = Rect.fromLTWH(SquareTLCorner.dx, SquareTLCorner.dy,
        freeSquareSideLength, freeSquareSideLength);

    canvas.clipRect(squareRect);

    // this Path shows the border of the canvas
    if (showHelpGraphics) {
      canvas.drawPath(
          Path()
            ..addRect(Rect.fromCenter(
                center: Offset(center.width, center.height),
                width: size.width,
                height: size.height)),
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke);
    }
    if (showHelpGraphics) {
      canvas.drawPath(
          Path()..addRect(squareRect),
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke);
    }

    canvas.save();
    canvas.translate(center.width, center.height);
    canvas.rotate(angle);
    canvas.translate(-center.width, -center.height);

    // we can draw from TL or from the center
    canvas.translate(SquareTLCorner.dx, SquareTLCorner.dy);

    /// shows the TL corner of the enclosing square
    if (showHelpGraphics) {
      canvas.drawPath(
          Path()
            ..addOval(
                Rect.fromCenter(center: Offset(0, 0), width: 10, height: 10)),
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.fill);
    }

    final double minSize = minDimension;
    final double dim =
        freeSquareSideLength < minSize ? minSize : freeSquareSideLength;

    int colorIndex = _colors.length - 1;
    double left = -1;
    double leftInSquare = -1;
    double right = 0;
    double rightInSquare = 0;
    var paint = Paint();
    bool parity = true;
    for (var xCoord in xSplits) {
      left = right;
      right = xCoord * dim;
      leftInSquare = rightInSquare;
      rightInSquare = xCoord * freeSquareSideLength;
//
      colorIndex = colorIndex == _colors.length - 1 ? 0 : colorIndex + 1;
      final Color color = _colors[colorIndex];
      paintStripInSquare(canvas, paint, leftInSquare, rightInSquare, color,
          freeSquareSideLength);
    }
    for (var xCoord in xSplits) {
      left = right;
      right = xCoord * dim;
      colorIndex = colorIndex == _colors.length - 1 ? 0 : colorIndex + 1;

      final Color color = _colors[colorIndex];
      if (showNumbers && freeSquareSideLength > 150) {
        paintTextInSquare(canvas, paint, left, right, xCoord, color,
            freeSquareSideLength, parity);
      }
      if (showXaxis) {
        paintHorizontalAxxis(canvas, paint, freeSquareSideLength);
      }
      parity = !parity;
    }

    if (showHelpGraphics) {
      // this Path shows the center of the canvas which will be the rotating point
      canvas.drawPath(
          Path()
            ..addOval(Rect.fromCenter(
                center:
                    Offset(freeSquareSideLength / 2, freeSquareSideLength / 2),
                // center: Offset(center.width, center.height),
                width: 5,
                height: 5)),
          Paint()..color = Colors.black);
      // this Path shows the border of the canvas
      canvas.drawPath(
          Path()
            ..addRect(Rect.fromCenter(
                center:
                    Offset(freeSquareSideLength / 2, freeSquareSideLength / 2),
                width: freeSquareSideLength,
                height: freeSquareSideLength)),
          Paint()
            ..color = Colors.green
            ..style = PaintingStyle.stroke);
    }
    canvas.restore();

    print('DiscStrip02CustomPainter repainted !');
  }

  @override
  bool shouldRepaint(DiscStrips oldDelegate) {
    if (angle != oldDelegate.angle) {
      print('repainted: shouldRepaint = true');
      return true;
    }
    if (_colors != oldDelegate._colors) {
      print('repainted: shouldRepaint = true');
      return true;
    }
    if (xSplits != oldDelegate.xSplits) {
      print('repainted: shouldRepaint = true');
      return true;
    }
    //TODO optimize
    print('repainted: shouldRepaint = false');
    return false;
  }
}

/// paint a disc strip on canvas within the square of side length squareDim (from TL).
///
/// 0 <= left <??= right <= squareDim
void paintStripInSquare(Canvas canvas, Paint paint, double left, double right,
    Color color, double squareDim) {
  const double top = 0;
  paint = paint..color = color;
  var pathCombine = Path.combine(
    PathOperation.intersect,
    Path()..addRect(Rect.fromLTRB(left, top, right, squareDim)),
    Path()..addOval(Rect.fromLTRB(0, top, squareDim, squareDim)),
  );

  canvas.drawPath(pathCombine, paint);
}

void paintHorizontalAxxis(Canvas canvas, Paint paint, double squareDim) {
  canvas.drawLine(
      Offset(0, squareDim / 2),
      Offset(squareDim, squareDim / 2),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke);
}

void paintText(Canvas canvas, Paint paint, Size size, double left, double right,
    double xCoord, Color color, double dim, bool parity) {
  const double upToText = 7;
  final smallestDimension = dim;
  paint = paint..color = color;
  var style = TextStyle(color: Colors.black);

  final double xCos = cosEquivFrom(xCoord);

  final ui.ParagraphBuilder paragraphBuilder =
      ui.ParagraphBuilder(ui.ParagraphStyle(
    fontSize: style.fontSize,
    fontFamily: style.fontFamily,
    fontStyle: style.fontStyle,
    fontWeight: style.fontWeight,
    textAlign: TextAlign.justify,
  ))
        ..pushStyle(style.getTextStyle())
        ..addText('${xCos.toStringAsFixed(2)}');
  final ui.Paragraph paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size.width));
  canvas.drawParagraph(
      paragraph,
      Offset(
          right - 12, smallestDimension / 2 + (parity ? upToText : -upToText)));
}

/// values above and below the horizontal axxis. Does not scale when disc is too small
void paintTextInSquare(Canvas canvas, Paint paint, double left, double right,
    double xCoord, Color color, double freeSquareSideLength, bool parity) {
  const double upToText = 8;
  final smallestDimensizon = freeSquareSideLength;
  paint = paint..color = color;
  var style = TextStyle(color: Colors.black);

  final double xCos = cosEquivFrom(xCoord);

  final ui.ParagraphBuilder paragraphBuilder =
      ui.ParagraphBuilder(ui.ParagraphStyle(
    fontSize: style.fontSize,
    fontFamily: style.fontFamily,
    fontStyle: style.fontStyle,
    fontWeight: style.fontWeight,
    textAlign: TextAlign.justify,
  ))
        ..pushStyle(style.getTextStyle())
        ..addText('${xCos.toStringAsFixed(2)}');
  final ui.Paragraph paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: freeSquareSideLength));
  canvas.drawParagraph(
      paragraph,
      Offset(right - 12,
          (freeSquareSideLength - 20) / 2 + (parity ? upToText : -upToText)));
}

double cosEquivFrom(double x0FromLeft) {
  return 2 * x0FromLeft - 1;
}

/// extract and convert x values (that are all between -1 and 1) into values between 0 and 1
List<double> getProportionnalXWithOneFrom(List<DiscSliceResultPart> parts) {
  // final List<DiscSliceResultPart> parts = getDiscSliceResultOf(_counter);
  //  print('_counter: $_counter');
  //  print('parts: $parts');
  final List<double> xSplitsParts = parts.map((e) => e.xResult).toList();
  // print('xSplitsParts: $xSplitsParts');
  final List<double> xSplitsRes = xSplitsParts.map((e) => (e + 1) / 2).toList();
  xSplitsRes.add(1.0);
  //  print('xSplitsRes: $xSplitsRes');
  return xSplitsRes;
}
