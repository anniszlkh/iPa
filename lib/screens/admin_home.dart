import 'package:flutter/material.dart';
import 'package:attend_track/screens/settings_screen.dart';
import 'package:attend_track/screens/clock_type_screen.dart';

class HomeContent extends StatelessWidget {
  final String username;
  const HomeContent({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome, $username !', // dynamic username
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage Team Hours',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton.icon(
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
          const SizedBox(height: 16),

          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text(
              'Approve',
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
              backgroundColor: Color(0xFF497152),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/admin-approve');
            },
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text(
              'Locate',
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
              backgroundColor: Color(0xFF8D3F40),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/locate-attendance');
            },
          ),
        ],
      ),
    );
  }
}

// Bottom navigation Home + Settings
class AdminHomeScreen extends StatefulWidget {
  final String username; // pass username
  const AdminHomeScreen({super.key, required this.username});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(username: widget.username),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
