import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

enum MicrophonePermissionStatus { granted, denied, permanentlyDenied }

class MicrophonePermissionCubit extends Cubit<MicrophonePermissionStatus> {
  MicrophonePermissionCubit(super.initialState);

  Future<void> requestPermission() async {
    await Permission.microphone
        .onGrantedCallback(() => emit(MicrophonePermissionStatus.granted))
        .onDeniedCallback(() => emit(MicrophonePermissionStatus.denied))
        .onPermanentlyDeniedCallback(
          () => emit(MicrophonePermissionStatus.permanentlyDenied),
        )
        .request();
  }
}
