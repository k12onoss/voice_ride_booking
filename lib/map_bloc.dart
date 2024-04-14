import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voice_ride_booking/api_key.dart';
import 'package:voice_ride_booking/google_maps_api.dart';
import 'package:voice_ride_booking/place_model.dart';

class MapState {
  Set<Marker> markers;
  Set<Polyline> polylines;

  MapState({required this.markers, required this.polylines});
}

class MapBloc extends Cubit<MapState> {
  final GoogleMapsAPI _googleMapsAPI = GoogleMapsAPI();

  MapBloc()
      : super(MapState(
          markers: {},
          polylines: {
            Polyline(
              polylineId: const PolylineId("path"),
              points: [],
              startCap: Cap.roundCap,
              endCap: Cap.buttCap,
              width: 4,
              color: Colors.blue,
            )
          },
        ));

  Future getPlace(String placeName) async {
    final PlaceModel place = await _googleMapsAPI.findPlace(placeName);

    Set<Marker> prevMarkers = state.markers;
    Set<Polyline> prevPolylines = state.polylines;

    Marker placeMarker = Marker(
      markerId: MarkerId(place.name),
      position: place.latLng,
      infoWindow: InfoWindow(title: place.formattedAddress),
    );

    prevMarkers.add(placeMarker);
    prevPolylines.first.points.add(place.latLng);

    if (prevPolylines.first.points.length > 1) {
      LatLng origin = prevPolylines.first.points[0];
      LatLng destination = prevPolylines.first.points[1];
      PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        PLACES_API_KEY,
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
      );
      prevPolylines.first.points.clear();
      prevPolylines.first.points.addAll(
        result.points.map((point) => LatLng(point.latitude, point.longitude)),
      );
    }

    final newState = MapState(markers: prevMarkers, polylines: prevPolylines);

    emit(newState);
  }
}
