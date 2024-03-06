import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
class HelperFunctions {
  static late CameraController cameraController;
  static late Future<void> initializedCameraController;
  static Future<bool> urlLauncherApplication(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
            enableDomStorage: false, enableJavaScript: false),
      );
    } else {
      throw Exception('Unable to launch url');
    }
  }

  Future<List<File>?> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result == null) {
      return null;
    }

    List<File> files = result.paths.map((path) => File(path!)).toList();

    return files;
  }

  static initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    cameraController = CameraController(firstCamera, ResolutionPreset.high, enableAudio: false);
    await cameraController.initialize();
  }
  Future<void> requestCameraPermission() async {
    // Check the current status of the camera permission
    PermissionStatus status = await Permission.camera.status;

    // If the permission is not granted, then request it
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      final newStatus = await Permission.camera.request();

      // Handle the outcome of the permission request here
      if (newStatus.isGranted) {
        // Permission granted, proceed with accessing the camera
      } else {
        // Permission denied, show an appropriate message or handle the denial
      }
    } else if (status.isGranted) {
      // Permission already granted, proceed with accessing the camera
    } else {
      // Handle other cases, such as "limited" permission on iOS
    }
  }
}
