import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_ride_booking/home_screen.dart';
import 'package:voice_ride_booking/location_permission_cubit.dart';
import 'package:voice_ride_booking/map_bloc.dart';
import 'package:voice_ride_booking/microphone_permission_cubit.dart';
import 'package:voice_ride_booking/speech_cubit.dart';

late MicrophonePermissionStatus microphonePermissionStatus;
late LocationPermissionStatus locationPermissionStatus;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  microphonePermissionStatus = await determineMicrophonePermissionStatus();
  locationPermissionStatus = await determineLocationPermissionStatus();
  runApp(const MyApp());
}

Future<MicrophonePermissionStatus> determineMicrophonePermissionStatus() async {
  final status = await Permission.microphone.status;
  if (status == PermissionStatus.granted) {
    return MicrophonePermissionStatus.granted;
  } else if (status == PermissionStatus.permanentlyDenied) {
    return MicrophonePermissionStatus.permanentlyDenied;
  } else {
    return MicrophonePermissionStatus.denied;
  }
}

Future<LocationPermissionStatus> determineLocationPermissionStatus() async {
  final status = await Permission.microphone.status;
  if (status == PermissionStatus.granted) {
    return LocationPermissionStatus.granted;
  } else if (status == PermissionStatus.permanentlyDenied) {
    return LocationPermissionStatus.permanentlyDenied;
  } else {
    return LocationPermissionStatus.denied;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SpeechToText speechToText = SpeechToText();
    return RepositoryProvider(
      create: (context) => speechToText,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => LocationPermissionCubit(locationPermissionStatus)
              ..requestLocationPermission(),
            lazy: false,
          ),
          BlocProvider(
            create: (_) => SpeechCubit(speechToText),
          ),
          BlocProvider(
            create: (_) =>
                MicrophonePermissionCubit(microphonePermissionStatus),
          ),
          BlocProvider(create: (_) => MapBloc()),
        ],
        child: MaterialApp(home: HomeScreen()),
      ),
    );
  }
}
