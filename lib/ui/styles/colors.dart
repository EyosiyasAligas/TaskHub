import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff1A73E8);
const Color secondaryColor = Color(0xffeca100);


const Color onPrimaryColor = Colors.white;
const Color onSecondaryColor = Colors.white;

//scaffoldBackgroundColor
Color lightModeScaffoldBackgroundColor =  Colors.grey.shade50;

//success and error color
Color successColor = Colors.green.shade400;
Color lightModeErrorColor = Colors.red.shade300;
Color darkModeErrorColor = Colors.red.shade200;

//shimmer loading colors
final Color shimmerBaseColor = Colors.grey.shade300;
final Color shimmerHighlightColor = Colors.grey.shade100;
final Color shimmerContentColor = Colors.white.withOpacity(0.85);

List<Color> noteColors = [
  Colors.transparent,
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
  Colors.pink,
  Colors.teal,
  Colors.brown,
  Colors.grey,
  Colors.cyan,
  Colors.deepPurple,
  Colors.indigo,
  Colors.lime,
  Colors.amber,
  Colors.lightBlue,
];

Color adjustColorIntensity(String colorString, scaffoldColor, BuildContext context) {
  Color color = Color(int.parse(colorString));
  bool isDarkMode = scaffoldColor != lightModeScaffoldBackgroundColor;

  // Adjust the color intensity
  double factor = 0.6;
  if(isDarkMode) {
    return Color.alphaBlend(Colors.black.withOpacity(factor), color);
  } else {
    return Color.alphaBlend(Colors.white.withOpacity(factor), color);
  }
}
