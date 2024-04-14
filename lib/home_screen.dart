import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_ride_booking/location_permission_cubit.dart';
import 'package:voice_ride_booking/microphone_permission_cubit.dart';
import 'package:voice_ride_booking/speech_cubit.dart';

import 'map_bloc.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _inputController = TextEditingController();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final DraggableScrollableController _dragController =
      DraggableScrollableController();
  final ValueNotifier<String> _inputNotifier = ValueNotifier<String>("source");

  HomeScreen({super.key});

  Future<LatLng> getLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  LatLngBounds generateBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double north = points.first.latitude;
    double east = points.first.longitude;
    double west = points.first.longitude;

    for (int i = 1; i < points.length; i++) {
      south = min(south, points[i].latitude);
      north = max(north, points[i].latitude);
      east = max(east, points[i].longitude);
      west = min(west, points[i].longitude);
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocListener<LocationPermissionCubit, LocationPermissionStatus>(
          listener: (context, state) async {
            if (state == LocationPermissionStatus.granted) {
              final location = await getLocation();
              final mapController = await _mapController.future;
              mapController.animateCamera(
                CameraUpdate.newLatLngZoom(location, 18),
              );
            }
          },
          child: StreamBuilder<ServiceStatus>(
            stream: Geolocator.getServiceStatusStream(),
            builder: (context, snapshot) {
              return snapshot.data == ServiceStatus.disabled
                  ? MaterialBanner(
                      content: const Text("Enable location services"),
                      actions: [
                        TextButton(
                            onPressed: () async =>
                                await Geolocator.openLocationSettings(),
                            child: const Text("Enable"))
                      ],
                    )
                  : const SizedBox();
            },
          ),
        ),
        BlocBuilder<LocationPermissionCubit, LocationPermissionStatus>(
          builder: (context, locationPermissionStatus) {
            return BlocConsumer<MapBloc, MapState>(
              listener: (context, state) async {
                final mapController = await _mapController.future;

                LatLngBounds bounds =
                    generateBounds(state.polylines.first.points);

                mapController.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    bounds,
                    40.0,
                  ),
                );
              },
              builder: (context, state) {
                return GoogleMap(
                  initialCameraPosition:
                      const CameraPosition(target: LatLng(0.0, 0.0)),
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  myLocationEnabled: locationPermissionStatus ==
                          LocationPermissionStatus.granted
                      ? true
                      : false,
                  mapToolbarEnabled: true,
                  padding: EdgeInsets.only(
                    top: 45.0,
                    bottom: MediaQuery.sizeOf(context).height * 0.22,
                  ),
                  markers: state.markers,
                  polylines: state.polylines,
                );
              },
            );
          },
        ),
        DraggableScrollableSheet(
          controller: _dragController,
          initialChildSize: 0.22,
          minChildSize: 0.22,
          maxChildSize: 0.22,
          shouldCloseOnMinExtent: false,
          builder: (context, scrollController) {
            return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.drag_handle),
                    ),
                    const SizedBox(height: 20.0),
                    ValueListenableBuilder(
                      valueListenable: _inputNotifier,
                      builder: (context, value, _) {
                        String speechState = context.watch<SpeechCubit>().state;
                        if (speechState == "") {
                          _inputController.clear();
                        } else {
                          _inputController.text = speechState;
                        }

                        if (value == "confirm") {
                          return Row(
                            children: [
                              const Text(
                                "Confirm trip?",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              FloatingActionButton.extended(
                                elevation: 0.0,
                                shape: const StadiumBorder(),
                                onPressed: () {},
                                label: const Text("Yes"),
                              )
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _inputController,
                                    decoration: InputDecoration(
                                      hintText: value == "source"
                                          ? "Enter pick-up location"
                                          : "Enter drop-off location",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(32.0),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                BlocConsumer<MicrophonePermissionCubit,
                                    MicrophonePermissionStatus>(
                                  listener: (context, state) {
                                    if (state ==
                                            MicrophonePermissionStatus
                                                .granted &&
                                        !context
                                            .read<SpeechToText>()
                                            .isAvailable) {
                                      context.read<SpeechCubit>().initialize();
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state ==
                                        MicrophonePermissionStatus.granted) {
                                      return FloatingActionButton(
                                        elevation: 0.0,
                                        shape: const CircleBorder(),
                                        onPressed: () => context
                                                .read<SpeechToText>()
                                                .isListening
                                            ? context.read<SpeechCubit>().stop()
                                            : context
                                                .read<SpeechCubit>()
                                                .listen(),
                                        child: context
                                                .watch<SpeechToText>()
                                                .isListening
                                            ? const Icon(Icons.mic_off)
                                            : const Icon(Icons.mic),
                                      );
                                    } else {
                                      return FloatingActionButton.extended(
                                        elevation: 0.0,
                                        shape: const StadiumBorder(),
                                        onPressed: () => context
                                            .read<MicrophonePermissionCubit>()
                                            .requestPermission(),
                                        label: const Text("Enable microphone"),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                            TextButton(
                              onPressed: () async {
                                await context
                                    .read<MapBloc>()
                                    .getPlace(_inputController.text);
                                await context.read<SpeechCubit>().stop();
                                if (value == "source") {
                                  _inputNotifier.value = "destination";
                                } else if (value == "destination") {
                                  _inputNotifier.value = "confirm";
                                }
                              },
                              child: const Text("Confirm"),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
