// Response
/*
{
  candidates:
     [
        {formatted_address: Mumbai, Maharashtra, India, geometry: {location: {lat: 19.0759837, lng: 72.8776559}, viewport: {northeast: {lat: 19.2716339, lng: 72.9864994}, southwest: {lat: 18.8928676, lng: 72.7758729}}}, name: Mumbai, place_id: ChIJwe1EZjDG5zsRaYxkjY_tpF0}
     ],
     status: OK
}
 */

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  String formattedAddress;
  LatLng latLng;
  LatLng northeast;
  LatLng southwest;
  String name;

  PlaceModel({
    required this.formattedAddress,
    required this.latLng,
    required this.northeast,
    required this.southwest,
    required this.name,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      formattedAddress: json["candidates"][0]["formatted_address"].toString(),
      latLng: LatLng(
        json["candidates"][0]["geometry"]["location"]["lat"],
        json["candidates"][0]["geometry"]["location"]["lng"],
      ),
      northeast: LatLng(
        json["candidates"][0]["geometry"]["viewport"]["northeast"]["lat"],
        json["candidates"][0]["geometry"]["viewport"]["northeast"]["lng"],
      ),
      southwest: LatLng(
        json["candidates"][0]["geometry"]["viewport"]["southwest"]["lat"],
        json["candidates"][0]["geometry"]["viewport"]["southwest"]["lng"],
      ),
      name: json["candidates"][0]["name"].toString(),
    );
  }
}
