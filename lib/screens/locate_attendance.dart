import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocateAttendanceScreen extends StatefulWidget {
  const LocateAttendanceScreen({super.key});

  @override
  State<LocateAttendanceScreen> createState() => _LocateAttendanceScreenState();
}

class _LocateAttendanceScreenState extends State<LocateAttendanceScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchLocateUsers();

    // auto-refresh
    refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchLocateUsers();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel(); // hentikan timer bila screen dispose
    super.dispose();
  }

  Future<void> fetchLocateUsers() async {
    const url = 'https://attendtrack.skynue.com/api/get_locate_users.php';
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Locate Attendances',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            color: const Color(0xFFFFE8EA),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name',
                          style: TextStyle(
                              fontFamily: 'SFPro', fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Location',
                          style: TextStyle(
                              fontFamily: 'SFPro', fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Time',
                          style: TextStyle(
                              fontFamily: 'SFPro', fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table body
                isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
                    : Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: users.map((user) {
                        return TableRowWidget(
                          username: user['username'] ?? '',
                          location: user['location'] ?? '',
                          time: user['updated_at']?.substring(11, 19) ??
                              '',
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TableRowWidget extends StatelessWidget {
  final String username;
  final String location;
  final String time;

  const TableRowWidget({
    super.key,
    required this.username,
    required this.location,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(username)),
          Expanded(
            flex: 5,
            child: Text(
              location,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 2, child: Text(time)),
        ],
      ),
    );
  }
}
