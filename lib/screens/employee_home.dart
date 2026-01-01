import 'package:attend_track/screens/notifications_screen.dart';
import 'package:attend_track/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'package:attend_track/screens/clock_type_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final String username;
  const EmployeeHomeScreen({super.key, required this.username});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    //pas usn to HomeContent
    _pages = [
      HomeContent(username: widget.username),
      NotificationsScreen(username: widget.username),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AttendTrack',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,

      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Original home content
class HomeContent extends StatelessWidget {
  final String username;
  const HomeContent({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'Welcome, $username !',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make Your Attendance Easier',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            // Clock Tap Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: const Text(
                  'Clock Tap',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Color(0xFF8D3F73),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClockTypeScreen(username: username),
                    ),
                  );

                },
              ),
            ),
            const SizedBox(height: 20),
            // other Button

          ],
        ),
      ),
    );
  }
}

// Placeholder pages
class NotificationsContent extends StatelessWidget {
  const NotificationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Notifications Page', style: TextStyle(fontSize: 18)),
    );
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Page', style: TextStyle(fontSize: 18)),
    );
  }
}
