import 'package:permission_handler/permission_handler.dart';

/// Ilova ishga tushganda kamera ruxsatini so‘raydi (agar hali berilmagan bo‘lsa).
Future<PermissionStatus> requestCameraPermissionOnLaunch() async {
  var status = await Permission.camera.status;
  if (!status.isGranted && !status.isPermanentlyDenied) {
    status = await Permission.camera.request();
  }
  return status;
}

/// Skaner sahifasida qayta urinish uchun.
Future<PermissionStatus> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    status = await Permission.camera.request();
  }
  return status;
}
