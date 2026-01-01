import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {
  final String username;
  const NotificationsScreen({super.key, required this.username});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchNotifications();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationsFuture = fetchNotifications(); // refresh setiap kali page muncul
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final url = Uri.parse(
        'https://attendtrack.skynue.com/api/notifications.php?username=${widget.username}');
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      notifications = List<Map<String, dynamic>>.from(data['data']);
      return notifications;
    }
    return [];
  }

  Future<void> markAsRead(int id) async {
    final url = Uri.parse('https://attendtrack.skynue.com/api/mark_notifications.php');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': [id]}), // hantar sebagai array
    );

    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      if (!mounted) return;
      setState(() {
        notifications.removeWhere((item) => item['id'] == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              return NotificationCard(
                id: item['id'],
                message: item['message'] ?? 'No message',
                onMarkRead: () => markAsRead(item['id']), // callback mark as read
              );
            },
          );
        },
      ),
    );
  }
}


class NotificationCard extends StatelessWidget {
  final int? id;
  final String message;
  final VoidCallback? onMarkRead; // tambah callback

  const NotificationCard({super.key, this.id, required this.message, this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onMarkRead, // panggil callback
                child: const Text(
                  'Mark As Read',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
