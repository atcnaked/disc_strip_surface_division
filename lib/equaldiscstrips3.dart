import 'dart:math';

/// affiche les cosinus et angles pour les k divisions du disques en bandes verticales (n croissant de 2 à n)
/// les x et les angles sont mesurés dans le cercle trigonométrique.
///
/// permet de découper diviser surface disque A en 2tiers 1 tiers avec un trait vertical,,
/// à 75 degré (ou cosinus 0.27) tirer trait vertical (#corde, segment de disque, cercle, tarte, égal
void main(List<String> arguments) {
  final int? nMax;
  if (arguments.length == 1) {
    nMax = int.tryParse(arguments.first);
  } else {
    nMax = null;
  }
  final int n = nMax ?? 10;

  Map<int, List<DiscSliceResultPart>> discSliceResult = {};
  for (var i = 2; i <= n; i++) {
    discSliceResult[i] = getDiscSliceResultOf(i);
  }
  print(
      'affiche les cosinus et angles pour les k divisions du disques en bandes verticales (n croissant de 2 à n)');
  print('les x et les angles sont mesurés dans le cercle trigonométrique');
  for (var i = 2; i <= n; i++) {
    final List<DiscSliceResultPart> discSliceResultParts = discSliceResult[i]!;
    if (i == 2) {
      final int microStripNumber = discSliceResultParts.first.microStripNumber;
      print('precision: $microStripNumber on x axxis');
    }
    final int divNb = discSliceResultParts.first.n;

    print('$divNb divisions');
    for (var part in discSliceResultParts) {
      part.display();
    }
  }
}

/// the x ang angle values of the nth divisions from left to right.
///
/// n and precision is repeated inside each element
List<DiscSliceResultPart> getDiscSliceResultOf(int n) {
  /// the x coordinates of circle 1 (centered on (0,0) and y>=0)
  final List<double> circleX = [];

  /// the x,y coordinates of the top of disc (centered on (0,0) and y>=0) from left to right
  final List<Point> circleHeights = [];

  /// the List of (x, surface of strip at x)  from left to right
  ///
  /// the strip is a full slice of a disc not a half disc
  final List<Point> discStrips = [];

  /// hte number of vertical slices. Higher number means higher the accuracy of the computation.
  //int microStripNumber = 50;
  final int microStripNumber = 10000;

  final double xintegralStart = -1;
  final double xintegralEnd = 1;
  final double xSpan = xintegralEnd - xintegralStart;
  final double dx = xSpan / microStripNumber;

  for (var i = 0; i < microStripNumber; i++) {
    final double theX = xintegralStart + i / microStripNumber * xSpan;
    circleX.add(theX);
    final double theY = sin(acos(theX));
    // checking that cos remplaces hFunc properly. desactivated for production, should be in test
    final double hF = hFunc(theX);
    final double diff = hF - theY;
    if (diff.abs() > 0.0001) {
      throw Exception(
          'diff.abs()>0.0001, theX: $theX diff: $diff, hF: $hF theY: $theY');
    }
    final Point point = Point(theX, theY);
    circleHeights.add(point);
    final double areaOfStrip = theY * dx * 2;
    final Point stripPoint = Point(theX, areaOfStrip);
    discStrips.add(stripPoint);
  }
  final double nThOfCircle = pi / n;
  int nThCount = 0;

  double sum = 0;
  final List<DiscSliceResultPart> res = [];

  for (var aStrip in discStrips) {
    sum += aStrip.y;
    if (sum >= nThOfCircle) {
      nThCount++;
      final double xResult = aStrip.x;
      // print(          '$nThCount nTh of circle: $nThCount x pi / $n reached at xResult: ${xResult.toStringAsFixed(3)}');

      final double equivalentAngleRad = acos(xResult);
      final String equivalentAngleFixed = equivalentAngleRad.toStringAsFixed(3);
      // print(          '=> l angle équivalent est: $equivalentAngleFixed radian ou ${(equivalentAngleRad * 180 / pi).toStringAsFixed(3)} degré');

      res.add(DiscSliceResultPart(
          n: n,
          microStripNumber: microStripNumber,
          xResult: xResult,
          equivalentAngleRad: equivalentAngleRad,
          nThCount: nThCount));
      sum = 0;
    }
  }
  return res;
}

double hFunc(double x) {
  //return x ; // * x+1;
  return sqrt(1 - x * x);
}

class Point {
  final double x;
  final double y;
  Point(
    this.x,
    this.y,
  );

  @override
  String toString() => 'x:${x.toStringAsFixed(3)}, y:${y.toStringAsFixed(3)}';
}

class DiscSliceResultPart {
  final int n;
  final int microStripNumber;
  int nThCount;
  final double xResult;
  final double equivalentAngleRad;
  DiscSliceResultPart({
    required this.n,
    required this.microStripNumber,
    required this.nThCount,
    required this.xResult,
    required this.equivalentAngleRad,
  });

  @override
  String toString() {
    return 'DSRP($n,$microStripNumber,x: $xResult,aRad: $equivalentAngleRad)';
  }

  void display() {
    final String equivalentAngleFixed = equivalentAngleRad.toStringAsFixed(3);
    final spacing1 = xResult >= 0 ? ' ' : '';
    // print(        ' $nThCount nTh of circle: $nThCount x pi / $n at x: $spacing1${xResult.toStringAsFixed(2)}, angle: ${(equivalentAngleRad * 180 / pi).toStringAsFixed(0)} degré');
    print(
        ' $nThCount cut x: $spacing1${xResult.toStringAsFixed(2)}, angle: ${(equivalentAngleRad * 180 / pi).toStringAsFixed(0)} degré');

    // print(        '=> l angle équivalent est: $equivalentAngleFixed radian ou ${(equivalentAngleRad * 180 / pi).toStringAsFixed(3)} degré');
  }

  String dataclassToString() {
    return 'DiscSliceResultPart(n: $n, microStripNumber: $microStripNumber, nThCount: $nThCount, xResult: $xResult, equivalentAngleRad: $equivalentAngleRad)';
  }
}
