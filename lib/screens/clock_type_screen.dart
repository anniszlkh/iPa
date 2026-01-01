import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class ClockTypeScreen extends StatefulWidget {
  final String username;
  const ClockTypeScreen({super.key, required this.username});

  @override
  State<ClockTypeScreen> createState() => _ClockTypeScreenState();
}

class _ClockTypeScreenState extends State<ClockTypeScreen> {
  String clockType = 'Clock In';
  DateTime currentTime = DateTime.now();
  String location = 'Detecting...';
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Request background location permission (Android 10+)
  Future<bool> requestBackgroundLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Location permission is permanently denied. Please enable it in settings to track location.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    // Request background location permission if only "whileInUse"
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always;
  }

  /// Get current location for UI display
  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = 'Location service disabled';
        isLoadingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          location = 'Location permission denied';
          isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        location = 'Location permission permanently denied';
        isLoadingLocation = false;
      });
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = pos.latitude;
      longitude = pos.longitude;

      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      String address= '';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          location =
          '${place.street}, ${place.locality}, ${place.administrativeArea}';
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        location = 'Unable to determine address';
        isLoadingLocation = false;
      });
    }
  }

  /// Confirm Clock In / Clock Out
  Future<void> _confirmClock() async {
    setState(() {
      currentTime = DateTime.now();
    });

    final url = Uri.parse('https://attendtrack.skynue.com/api/clock.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
        'clock_type': clockType,
        'clock_time': currentTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success',
                style: TextStyle(
                    fontFamily: 'SFPro', fontWeight: FontWeight.w700)),
            content: Text(
              clockType == 'Clock In'
                  ? 'Clock In successful! Background tracking started.'
                  : 'Clock Out successful! Background tracking stopped.',
              style: const TextStyle(fontFamily: 'SFPro'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK',
                    style: TextStyle(
                        fontFamily: 'SFPro', fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

        if (clockType == 'Clock In') {
          bool granted = await requestBackgroundLocationPermission();
          if (granted) {
            // Send location immediately
            await sendLocationToServer(latitude, longitude, location);

            // Start background tracking every 10 minutes
            startBackgroundTracking();
          } else {
            print('Background location permission not granted');
          }
        } else {
          stopBackgroundTracking();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to clock')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to server')),
      );
    }
  }

  /// Send location immediately
  Future<void> sendLocationToServer(double lat, double lng, String address) async {
    try {
      await http.post(
        Uri.parse('https://attendtrack.skynue.com/api/locate_users.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'latitude': lat,
          'longitude': lng,
          'location': address,
        }),
      );
    } catch (e) {
      print('Failed to send location: $e');
    }
  }

  /// Start background service
  void startBackgroundTracking() async {
    final service = FlutterBackgroundService();
    await service.startService();
    service.invoke('setUser', {'username': widget.username});
  }

  /// Stop background service
  void stopBackgroundTracking() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock Tap',
            style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoCard('USERNAME', widget.username),
              _infoCard(
                'LOCATION',
                isLoadingLocation ? 'Detecting...' : location,
              ),
              _dropdownClockType(),
              _infoCard(
                  'TIME',
                  '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:${currentTime.second.toString().padLeft(2, '0')}'),
              _infoCard(
                  'DATE',
                  '${currentTime.day.toString().padLeft(2, '0')}/${currentTime.month.toString().padLeft(2, '0')}/${currentTime.year}'),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: _confirmClock,
                child: const Text('Confirm',
                    style: TextStyle(
                        fontFamily: 'SFPro',
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _dropdownClockType() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CLOCK TYPE',
                style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            DropdownButton<String>(
              value: clockType,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Clock In', child: Text('Clock In')),
                DropdownMenuItem(value: 'Clock Out', child: Text('Clock Out')),
              ],
              onChanged: (val) {
                setState(() {
                  clockType = val!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
