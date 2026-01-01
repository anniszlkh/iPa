import 'package:flutter/material.dart';

class ApproveClockOutScreen extends StatelessWidget {
  const ApproveClockOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Attendances')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ApproveCard(
            username: 'Ali',
            clockType: 'Clock Out',
            location: '777, Jalan Pintu Sepuluh, Alor Setar',
          ),
          ApproveCard(
            username: 'Lia',
            clockType: 'Clock Out',
            location:
            'No. 1, Sultanah Bahiyah, Bandar Baru Mergong, Alor Setar, Kedah',
          ),
          ApproveCard(
            username: 'Mamat',
            clockType: 'Clock Out',
            location: '777, Jalan Pintu Sepuluh, Alor Setar',
          ),
        ],
      ),
    );
  }
}

class ApproveCard extends StatelessWidget {
  final String username;
  final String clockType;
  final String location;

  const ApproveCard({
    super.key,
    required this.username,
    required this.clockType,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.black,
            width: 1.5,
          )
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $username'),
            const SizedBox(height: 4),
            Text('Clock Type: $clockType'),
            const SizedBox(height: 4),
            Text('Location: $location'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Approve'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
