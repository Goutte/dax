part of dax_cli;


/**
 * A very simple RGB Color model extending Vector3, to work with shaders.
 * RGB values are stored in that order as values between 0 and 1.
 */
class Color extends Vector3 {

  /// CONSTRUCTORS -------------------------------------------------------------

  Color(double _x, double _y, double _z) : super(_x, _y, _z);

  factory Color.hex(String hexCode) {
    Map<String, int> rgb = hexToRgb(hexCode);
    return new Color(rgb['r'] / 256, rgb['g'] / 256, rgb['b'] / 256);
  }

  /// OVERRIDES ----------------------------------------------------------------

  /// API ----------------------------------------------------------------------

  static Map<String, int> hexToRgb(String hexCode) {
    if (hexCode.startsWith('#')) {
      hexCode = hexCode.substring(1, hexCode.length);
    }
    List<String> hexDigits = hexCode.split('');
    return {
        'r': int.parse(hexDigits.sublist(0, 2).join(), radix: 16),
        'g': int.parse(hexDigits.sublist(2, 4).join(), radix: 16),
        'b': int.parse(hexDigits.sublist(4).join(), radix: 16)
    };
  }

  /// TESTING UTILS ------------------------------------------------------------

  /// PRIVVIES -----------------------------------------------------------------

}