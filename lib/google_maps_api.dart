/*
https://maps.googleapis.com/maps/api/place/findplacefromtext/json
  ?fields=formatted_address%2Cname%2Crating%2Copening_hours%2Cgeometry
  &input=Museum%20of%20Contemporary%20Art%20Australia
  &inputtype=textquery
  &key=YOUR_API_KEY
 */

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_ride_booking/api_key.dart';
import 'package:voice_ride_booking/place_model.dart';

class GoogleMapsAPI {
  final String baseUrl = "maps.googleapis.com";
  http.Client client = http.Client();

  Future<PlaceModel> findPlace(String placeName) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=formatted_address%2Cname%2Cplace_id%2Cgeometry&input=$placeName&inputtype=textquery&language=en-GB&key=$PLACES_API_KEY";
    final result = await client.get(Uri.parse(url));
    final json = jsonDecode(result.body);

    return PlaceModel.fromJson(json);
  }
}
