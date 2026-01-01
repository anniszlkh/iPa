import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminApproveScreen extends StatefulWidget {
  const AdminApproveScreen({super.key});

  @override
  State<AdminApproveScreen> createState() => _AdminApproveScreenState();
}

class _AdminApproveScreenState extends State<AdminApproveScreen> {
  bool showClockIn = true; // toggle Clock In / Clock Out
  List<Map<String, dynamic>> attendances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendances();
  }

  Future<void> fetchAttendances() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
        'https://attendtrack.skynue.com/api/approve_clock.php?clock_type=${showClockIn ? 'Clock In' : 'Clock Out'}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            attendances =
            List<Map<String, dynamic>>.from(data['data'] ?? []);
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateAttendance(int id, String action) async {
    final url =
    Uri.parse('https://attendtrack.skynue.com/api/update_clock.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'action': action}),
      );
      if (response.statusCode == 200) {
        await fetchAttendances(); // refresh list
      }
    } catch (e) {
      print("Error updating attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Approve Attendances',
          style: TextStyle(
              fontFamily: 'SFPro', fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showClockIn = true;
                    });
                    fetchAttendances();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showClockIn ? Colors.blue : Colors.grey[300],
                    foregroundColor: showClockIn ? Colors.white : Colors.black,
                  ),
                  child: const Text('Clock In'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showClockIn = false;
                    });
                    fetchAttendances();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !showClockIn ? Colors.blue : Colors.grey[300],
                    foregroundColor: !showClockIn ? Colors.white : Colors.black,
                  ),
                  child: const Text('Clock Out'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Attendance List
            isLoading
                ? const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
                : Expanded(
              child: attendances.isEmpty
                  ? const Center(child: Text("No pending records"))
                  : ListView.builder(
                itemCount: attendances.length,
                itemBuilder: (context, index) {
                  final item = attendances[index];
                  return ApproveCard(
                    username: item['username'],
                    clockType: item['clock_type'],
                    location: item['location'],
                    date: item['date'],
                    time: item['time'],
                    onApprove: () => updateAttendance(item['id'], 'approve'),
                    onReject: () => updateAttendance(item['id'], 'reject'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApproveCard extends StatelessWidget {
  final String username;
  final String clockType;
  final String location;
  final String date;
  final String time;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApproveCard({
    super.key,
    required this.username,
    required this.clockType,
    required this.location,
    required this.date,
    required this.time,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $username',
                style: const TextStyle(
                    fontFamily: 'SFPro', fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Clock Type: $clockType',
                style: const TextStyle(
                    fontFamily: 'SFPro', fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text('Location: $location',
                style: const TextStyle(
                    fontFamily: 'SFPro', fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text('Date: $date',
                style: const TextStyle(
                    fontFamily: 'SFPro', fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text('Time: $time',
                style: const TextStyle(
                    fontFamily: 'SFPro', fontWeight: FontWeight.w400)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Approve', style: TextStyle(fontFamily: 'SFPro')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Reject', style: TextStyle(fontFamily: 'SFPro')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
