import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nilai_provider.dart';
import '../../providers/absensi_provider.dart';
import '../../providers/krs_provider.dart';

class MahasiswaDashboard extends StatefulWidget {
  @override
  _MahasiswaDashboardState createState() => _MahasiswaDashboardState();
}

class _MahasiswaDashboardState extends State<MahasiswaDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      await Provider.of<NilaiProvider>(context, listen: false).getNilaiByMahasiswa(userId);
      await Provider.of<AbsensiProvider>(context, listen: false).getAbsensiByMahasiswa(userId);
      await Provider.of<KRSProvider>(context, listen: false).getKRSByMahasiswa(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Mahasiswa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blue[900]!,
                    Colors.blue[800]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[900]!.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mahasiswa',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Overview Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Mata Kuliah',
                      context.watch<KRSProvider>().krsList.length.toString(),
                      Icons.book_outlined,
                      Colors.blue[700]!,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildOverviewCard(
                      'Total SKS',
                      context.watch<KRSProvider>().totalSKS.toString(),
                      Icons.school_outlined,
                      Colors.blue[800]!,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Kehadiran',
                      '${_calculateAttendance(context)}%',
                      Icons.timer_outlined,
                      Colors.blue[600]!,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildOverviewCard(
                      'IPK',
                      _calculateGPA(context),
                      Icons.grade_outlined,
                      Colors.blue[900]!,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMenuItem(
                    'Jadwal Kuliah',
                    Icons.calendar_today_outlined,
                    () => Navigator.pushNamed(context, '/mahasiswa/jadwal'),
                  ),
                  _buildMenuItem(
                    'Kartu Hasil Studi',
                    Icons.grade_outlined,
                    () => Navigator.pushNamed(context, '/mahasiswa/nilai'),
                  ),
                  _buildMenuItem(
                    'Absensi',
                    Icons.assignment_outlined,
                    () => Navigator.pushNamed(context, '/mahasiswa/absensi'),
                  ),
                  _buildMenuItem(
                    'KRS',
                    Icons.edit_outlined,
                    () => Navigator.pushNamed(context, '/mahasiswa/krs'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateGPA(BuildContext context) {
    final nilaiList = context.watch<NilaiProvider>().nilaiList;
    if (nilaiList.isEmpty) return '0.00';

    double totalNilai = 0;
    int totalSKS = 0;

    for (var nilai in nilaiList) {
      totalNilai += nilai.nilai * (nilai.sks ?? 0);
      totalSKS += nilai.sks ?? 0;
    }

    return (totalNilai / (totalSKS > 0 ? totalSKS : 1)).toStringAsFixed(2);
  }

  String _calculateAttendance(BuildContext context) {
    final absensiList = context.watch<AbsensiProvider>().absensiList;
    if (absensiList.isEmpty) return '0';

    int totalHadir = absensiList.where((a) => a.status.toLowerCase() == 'hadir').length;
    return ((totalHadir / absensiList.length) * 100).toStringAsFixed(0);
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blue[900]),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.blue[900],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.blue[900]),
      ),
    );
  }
} 