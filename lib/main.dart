import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'services/background_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/employee_home.dart';
import 'screens/admin_home.dart';
import 'screens/clock_in_confirm.dart';
import 'screens/clock_out_confirm.dart';
import 'screens/notifications_screen.dart';
import 'screens/approve_clock_in.dart';
import 'screens/approve_clock_out.dart';
import 'screens/locate_attendance.dart';
import 'screens/admin_approve_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const AttendTrackApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // **return Future<bool>**
      autoStart: false,
      isForegroundMode: true, // notification muncul otomatis
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart, // **return Future<bool>**
      onBackground: onStart, // **return Future<bool>**
    ),
  );
}

class AttendTrackApp extends StatelessWidget {
  const AttendTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AttendTrack',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/employee-home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return EmployeeHomeScreen(username: args);
        },
        '/clock-in': (context) => const ClockInConfirmScreen(),
        '/clock-out': (context) => const ClockOutConfirmScreen(),
        '/notifications': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return NotificationsScreen(username: args ?? '');
        },
        '/admin-home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return AdminHomeScreen(username: args);
        },
        '/approve-clock-in': (context) => const ApproveClockInScreen(),
        '/approve-clock-out': (context) => const ApproveClockOutScreen(),
        '/locate-attendance': (context) => const LocateAttendanceScreen(),
        '/admin-approve': (context) => const AdminApproveScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
