import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  print('BACKGROUND SERVICE STARTED');

  String username = '';

  service.on('setUser').listen((event) {
    username = event?['username'] ?? '';
    print('USER SET: $username');
  });

  service.on('stopService').listen((event) {
    print('SERVICE STOPPED');
    service.stopSelf();
  });

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    print('TIMER TICK');

    if (username.isEmpty) {
      print('USERNAME EMPTY – SKIP');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String address =
      placemarks.isNotEmpty
          ? "${placemarks[0].street}, ${placemarks[0].locality}"
          : "${position.latitude}, ${position.longitude}";

      final response = await http.post(
        Uri.parse('https://attendtrack.skynue.com/api/locate_users.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'location': address,
        }),
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
    } catch (e) {
      print('LOCATION SEND ERROR: $e');
    }
  });

  return true;
}
