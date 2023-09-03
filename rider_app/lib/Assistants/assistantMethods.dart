// ignore_for_file: unnecessary_new, prefer_interpolation_to_compose_strings

import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandle/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/configMaps.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != 'failed') {
      st1 = response["results"][0]["address_components"][3]["long_name"];
      st2 = response["results"][0]["address_components"][4]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];

      placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address userPickupAddress = Address(
        longitude: position.longitude,
        latitude: position.latitude,
        placeName: placeAddress,
      );

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickupAddress);
    }

    String pickupPlaceName =
        Provider.of<AppData>(context)?.pickUpLocation?.placeName ?? "";

    return pickupPlaceName;
  }
}