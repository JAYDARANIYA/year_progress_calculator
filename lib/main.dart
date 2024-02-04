import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YearProgressCalculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late double percentage;

  @override
  void initState() {
    super.initState();

    percentage = calculateYearPassedPercentage();
    setTitle('$percentage% Year Progress');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(hours: 1), (timer) {
        var newP = calculateYearPassedPercentage();

        if (newP != percentage) {
          setState(() {
            percentage = newP;
            setTitle('$percentage% Year Progress');
          });
        }
      });
    });
  }

  setTitle(String title) {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: title, // '$percentage% Year Progress',
        primaryColor: 0xffaaaaaa, // This line is required
      ),
    );
  }

  double calculateYearPassedPercentage() {
    DateTime now = DateTime.now();

    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    DateTime firstDayOfNextYear = DateTime(now.year + 1, 1, 1);

    int totalSecondsInYear =
        firstDayOfNextYear.difference(firstDayOfYear).inHours;
    int secondsPassedInYear = now.difference(firstDayOfYear).inHours;

    return (secondsPassedInYear / totalSecondsInYear) * 100;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var minSize = min(width, height);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        leading: Image.asset(
          'assets/logo.png',
          width: 30,
          height: 30,
        ),
        title: const Text(
          'Year Progress Calculator',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 10.0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: LoaderPaint(
              percentage: percentage / 100,
            ),
            child: Container(
              width: minSize * 0.66,
              height: minSize * 0.66,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: minSize * 0.055,
                    ),
                  ),
                  Text(
                    'Year Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: minSize * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

class LoaderPaint extends CustomPainter {
  final double percentage;
  const LoaderPaint({
    required this.percentage,
  });

  deg2Rand(double deg) => deg * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final sweepAngle = deg2Rand(360 * percentage);

    final midOffset = Offset(radius, radius);

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    // draw background arc
    canvas.drawArc(
      Rect.fromCenter(
          center: midOffset, width: size.width, height: size.height),
      deg2Rand(-90),
      deg2Rand(360),
      false,
      paint..color = Colors.grey[800]!,
    );

    canvas.drawArc(
      Rect.fromCenter(
          center: midOffset, width: size.width, height: size.height),
      deg2Rand(-90),
      sweepAngle,
      false,
      paint..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
