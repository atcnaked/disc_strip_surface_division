//import 'package:equal_disc_strip_division_app/equaldiscstrips3.dart';
import 'package:disc_strip_surface_division/equaldiscstrips3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'disc_strip05.dart' as rotest;
import 'disc_strip_equal_surface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Disc MultiStrip'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 7;
  // static const _counterInit = 7;
  List<double> xSplits = [1];
  final List<Color>? testColors = [
    Colors.blueAccent,
    Colors.blueGrey,
    Colors.greenAccent,
    Colors.yellowAccent,
  ];

  /// rotate angle in rad
  double angle = 0;

  /// display options
  int optionsDisplayCount = -1;
  bool showNumbers = true;
  bool showHelpGraphics = true;
  bool showXaxis = true;

  /// static const angleInit = 1.0;
  // List<double> xSplits =  [0.11, 0.30, 0.42, 0.55, 0.69, 0.77];

  void _incrementCounter() {
    setState(() {
      _counter++;
      _setSplitsNoSetState();
    });
  }

  void _setSplitsNoSetState() {
    final List<DiscSliceResultPart> parts = getDiscSliceResultOf(_counter);
    /// conversion
    xSplits = getProportionnalXWithOneFrom(parts);
  }

  @override
  void initState() {
    super.initState();
    _setSplitsNoSetState();
  }

  void _toggleAllOptions() {
    optionsDisplayCount++;
    final int remain = optionsDisplayCount % 4;
    setState(() {
      /*   if (remain == 0) {
        showNumbers = true;
        showHelpGraphics = true;
        showXaxis = true;
      } else  */

      if (remain == 0) {
        showNumbers = !showNumbers;
        showHelpGraphics = !showHelpGraphics;
        showXaxis = !showXaxis;
      } else if (remain == 1) {
        showNumbers = true;
      } else if (remain == 2) {
        showHelpGraphics = true;
      } else if (remain == 3) {
        showXaxis = true;
      }
    });
  }

  void _rotate() {
    setState(() {
      angle = angle + 0.2;
    });
  }

  /// toggles between 2 RAZ values for demonstation purpose
  void _razCounters() {
    angle = 0;
    setState(() {
      if (_counter == 3) {
        _counter = 1;
      } else {
        _counter = 3;
      }
      optionsDisplayCount = -1;
      showNumbers = true;
      showHelpGraphics = true;
      showXaxis = true;

      _setSplitsNoSetState();
    });
  }

  @deprecated
  void _razAngle() {
    setState(() {
      angle = 0;
      _setSplitsNoSetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('BB');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
               Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 70,
                  minHeight: 70,
                ),
                child: CustomPaint(
                  painter: DiscStrips(
                      xSplits: xSplits,
                      angle: angle,
                      colorsP: xSplits.length % 5 == 0 ? testColors : null,
                      minDimensionParam: 100,
                      showNumbers: showNumbers,
                      showHelpGraphics: showHelpGraphics,
                      showXaxis: showXaxis),
                  child: Container(),
                ),
              ),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('CUT'),
                ),
                ElevatedButton(
                  onPressed: _rotate,
                  child: const Text('ROTATE'),
                ),
               
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleAllOptions,
                  child: const Text(
                    'change display',
                  ),
                ),
                ElevatedButton(
                  onPressed: _razCounters,
                  child: const Text(
                    'reset',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
