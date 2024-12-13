import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/mahasiswa/mahasiswa_dashboard.dart';
import 'screens/dosen/dosen_dashboard.dart';
import 'screens/admin/mahasiswa_screen.dart';
import 'providers/mahasiswa_provider.dart';
import 'providers/dosen_provider.dart';
import 'screens/admin/dosen_screen.dart';
import 'providers/matakuliah_provider.dart';
import 'screens/admin/matakuliah_screen.dart';
import 'providers/jadwal_provider.dart';
import 'screens/admin/jadwal_screen.dart';
import 'providers/nilai_provider.dart';
import 'screens/admin/user_screen.dart';
import 'providers/user_provider.dart';
import 'providers/krs_provider.dart';
import 'screens/mahasiswa/jadwal_screen.dart';
import 'screens/mahasiswa/nilai_screen.dart';
import 'screens/mahasiswa/absensi_screen.dart';
import 'screens/mahasiswa/krs_screen.dart' as mahasiswa;
import 'screens/admin/krs_screen.dart';
import 'screens/dosen/absensi_screen.dart';
import 'screens/dosen/nilai_screen.dart';
import 'providers/absensi_provider.dart';
import 'screens/dosen/jadwal_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MahasiswaProvider()),
        ChangeNotifierProvider(create: (_) => DosenProvider()),
        ChangeNotifierProvider(create: (_) => MataKuliahProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => NilaiProvider()),
        ChangeNotifierProvider(create: (_) => AbsensiProvider()),
        ChangeNotifierProvider(create: (_) => KRSProvider()),
      ],
      child: MaterialApp(
        title: 'SIAKAD',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/admin': (context) => AdminDashboard(),
          '/mahasiswa': (context) => MahasiswaDashboard(),
          '/dosen': (context) => DosenDashboard(),
          '/admin/mahasiswa': (context) => MahasiswaScreen(),
          '/admin/dosen': (context) => DosenScreen(),
          '/admin/matakuliah': (context) => MataKuliahScreen(),
          '/admin/jadwal': (context) => JadwalScreen(),
          '/admin/user': (context) => UserScreen(),
          '/mahasiswa/jadwal': (context) => MahasiswaJadwalScreen(),
          '/mahasiswa/nilai': (context) => MahasiswaNilaiScreen(),
          '/mahasiswa/absensi': (context) => MahasiswaAbsensiScreen(),
          '/mahasiswa/krs': (context) => mahasiswa.KRSScreen(),
          '/admin/krs': (context) => AdminKRSScreen(),
          '/dosen/absensi': (context) => DosenAbsensiScreen(),
          '/dosen/nilai': (context) => DosenNilaiScreen(),
          '/dosen/jadwal': (context) => DosenJadwalScreen(),
        },
      ),
    );
  }
}
