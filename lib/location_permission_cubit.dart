import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationPermissionStatus { granted, denied, permanentlyDenied }

class LocationPermissionCubit extends Cubit<LocationPermissionStatus> {
  LocationPermissionCubit(super.initialState);

  Future<void> requestLocationPermission() async {
    await Permission.location
        .onGrantedCallback(() => emit(LocationPermissionStatus.granted))
        .onDeniedCallback(() => emit(LocationPermissionStatus.denied))
        .onPermanentlyDeniedCallback(
          () => emit(LocationPermissionStatus.permanentlyDenied),
        )
        .request();
  }
}
