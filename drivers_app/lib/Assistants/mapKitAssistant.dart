import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitAssistant {
  static double getMarkerRotation(double sLat, double sLng, double dLat, double dLng) {
    var rot = SphericalUtil.computeHeading(LatLng(sLat, sLng), LatLng(dLat, dLng));
    return rot.toDouble();
  }
}