import 'package:flutter/material.dart';

class ApproveClockInScreen extends StatelessWidget {
  const ApproveClockInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Approve Attendances',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true, // Center title
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ApproveCard(
              username: 'Ali',
              clockType: 'Clock In',
              location: '777, Jalan Pintu Sepuluh, Alor Setar',
              date: '20.12.2025',
              time: '9:10:15 am'
          ),
          ApproveCard(
            username: 'Lia',
            clockType: 'Clock In',
            location: '777, Jalan Pintu Sepuluh, Alor Setar',
            date: '20.12.2025',
            time: '8:53:12 am',
          ),
          ApproveCard(
            username: 'Mamat',
            clockType: 'Clock In',
            location: '777, Jalan Pintu Sepuluh, Alor Setar',
            date: '20.12.2025',
            time: '9:30:19 am',
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
  final String date;
  final String time;

  const ApproveCard({
    super.key,
    required this.username,
    required this.clockType,
    required this.location,
    required this.date,
    required this.time
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
            Text(
              'Username: $username',
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Clock Type: $clockType',
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Location: $location',
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: $date',
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: $time',
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
