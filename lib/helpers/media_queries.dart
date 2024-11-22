import 'package:flutter/material.dart';

bool isLandscape(BuildContext context) {
  return MediaQuery.of(context).orientation == Orientation.landscape;
}

bool isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 720.0;
}

bool isMediumScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 640.0;
}

bool isSmallScreen(BuildContext context) {
  return MediaQuery.of(context).size.height < 480.0;
}
