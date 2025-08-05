import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_shapes/material_shapes.dart';

const pastelColors = [
  Color(0xffCAE8BD),
  Color(0xffF2E2B1),
  Color(0xff9ECAD6),
  Color(0xffFCD8CD),
  Color(0xffF0C1E1),
  Color(0xffFFB38E),
  Color(0xffFEF9D9),
  Color(0xffFF8A8A),
  Color(0xffCADABF),
  Color(0xffDEE791),
  Color(0xffECCA9C)
];

class ExpressiveStyle {
  final TextStyle textStyle;
  final Color color;
  final RoundedPolygon backgroundShape;
  final RoundedPolygon foregroundShape;

  const ExpressiveStyle({
    required this.textStyle,
    required this.color,
    required this.backgroundShape,
    required this.foregroundShape,
  });
}

final expressiveStyles = [
  ExpressiveStyle(
    backgroundShape: MaterialShapes.cookie4Sided,
    foregroundShape: MaterialShapes.diamond,
    color: pastelColors[8],
    textStyle: GoogleFonts.caprasimo(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.clover8Leaf,
    foregroundShape: MaterialShapes.verySunny,
    color: pastelColors[0],
    textStyle: GoogleFonts.caveat(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.circle,
    foregroundShape: MaterialShapes.softBoom,
    color: pastelColors[2],
    textStyle: GoogleFonts.lora(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.gem,
    foregroundShape: MaterialShapes.heart,
    color: pastelColors[4],
    textStyle: GoogleFonts.dancingScript(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.cookie6Sided,
    foregroundShape: MaterialShapes.pentagon,
    color: pastelColors[1],
    textStyle: GoogleFonts.pacifico(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.pentagon,
    foregroundShape: MaterialShapes.clover4Leaf,
    color: pastelColors[6],
    textStyle: GoogleFonts.comicNeue(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.puffyDiamond,
    foregroundShape: MaterialShapes.softBoom,
    color: pastelColors[3],
    textStyle: GoogleFonts.righteous(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.verySunny,
    foregroundShape: MaterialShapes.cookie4Sided,
    color: pastelColors[7],
    textStyle: GoogleFonts.fredoka(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.clover4Leaf,
    foregroundShape: MaterialShapes.diamond,
    color: pastelColors[9],
    textStyle: GoogleFonts.quicksand(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.heart,
    foregroundShape: MaterialShapes.circle,
    color: pastelColors[5],
    textStyle: GoogleFonts.bubblegumSans(),
  ),
  ExpressiveStyle(
    backgroundShape: MaterialShapes.softBoom,
    foregroundShape: MaterialShapes.pentagon,
    color: pastelColors[10],
    textStyle: GoogleFonts.kalam(),
  ),
];

/// Returns a consistent ExpressiveStyle based on a string input.
/// The same string will always return the same style.
ExpressiveStyle getExpressiveStyleFromString(String input) {
  // Create a simple hash from the string
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xFFFFFFFF;
  }

  // Use the hash to select a consistent index from the styles list
  final index = hash.abs() % expressiveStyles.length;
  return expressiveStyles[index];
}
