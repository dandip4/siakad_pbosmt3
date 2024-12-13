import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mahasiswa_provider.dart';
import '../../providers/dosen_provider.dart';
import '../../providers/matakuliah_provider.dart';
import '../../providers/krs_provider.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<MahasiswaProvider>(context, listen: false).getAllMahasiswa();
    await Provider.of<DosenProvider>(context, listen: false).getAllDosen();
    await Provider.of<MataKuliahProvider>(context, listen: false).getAllMataKuliah();
    await Provider.of<KRSProvider>(context, listen: false).getAllKRS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Admin',
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
            Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
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
                        Icons.account_circle,
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
                            'Admin',
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
            ),
            
            // Overview Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Total Mahasiswa',
                      context.watch<MahasiswaProvider>().mahasiswaList.length.toString(),
                      Icons.people_outline,
                      Colors.blue[700]!,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildOverviewCard(
                      'Total Dosen',
                      context.watch<DosenProvider>().dosenList.length.toString(),
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
                      'Mata Kuliah',
                      context.watch<MataKuliahProvider>().mataKuliahList.length.toString(),
                      Icons.book_outlined,
                      Colors.blue[600]!,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildOverviewCard(
                      'KRS Pending',
                      context.watch<KRSProvider>().krsList
                          .where((krs) => krs.status == 'pending')
                          .length
                          .toString(),
                      Icons.pending_outlined,
                      Colors.blue[900]!,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Menu Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildMenuItem(
                        'Manajemen Mahasiswa',
                        Icons.people_outline,
                        () => Navigator.pushNamed(context, '/admin/mahasiswa'),
                      ),
                      _buildMenuItem(
                        'Manajemen Dosen',
                        Icons.school_outlined,
                        () => Navigator.pushNamed(context, '/admin/dosen'),
                      ),
                      _buildMenuItem(
                        'Manajemen Mata Kuliah',
                        Icons.book_outlined,
                        () => Navigator.pushNamed(context, '/admin/matakuliah'),
                      ),
                      _buildMenuItem(
                        'Manajemen Jadwal',
                        Icons.calendar_today_outlined,
                        () => Navigator.pushNamed(context, '/admin/jadwal'),
                      ),
                      _buildMenuItem(
                        'Persetujuan KRS',
                        Icons.assignment_outlined,
                        () => Navigator.pushNamed(context, '/admin/krs'),
                      ),
                      _buildMenuItem(
                        'Manajemen User',
                        Icons.manage_accounts_outlined,
                        () => Navigator.pushNamed(context, '/admin/user'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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