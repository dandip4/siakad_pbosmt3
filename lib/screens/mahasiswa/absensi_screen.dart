import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/absensi_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/absensi.dart';

class MahasiswaAbsensiScreen extends StatefulWidget {
  @override
  _MahasiswaAbsensiScreenState createState() => _MahasiswaAbsensiScreenState();
}

class _MahasiswaAbsensiScreenState extends State<MahasiswaAbsensiScreen> {
  @override
  void initState() {
    super.initState();
    _loadAbsensi();
  }

  Future<void> _loadAbsensi() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      await Provider.of<AbsensiProvider>(context, listen: false).getAbsensiByMahasiswa(userId);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'izin':
      case 'sakit':
        return Colors.orange;
      case 'alpa':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi'),
        backgroundColor: Colors.blue[900],
      ),
      body: Consumer<AbsensiProvider>(
        builder: (context, provider, child) {
          if (provider.absensiList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data absensi',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          // Group absensi by mata kuliah
          Map<String, List<Absensi>> groupedAbsensi = {};
          for (var absensi in provider.absensiList) {
            String key = '${absensi.namaMatkul} (${absensi.kodeMatkul})';
            if (!groupedAbsensi.containsKey(key)) {
              groupedAbsensi[key] = [];
            }
            groupedAbsensi[key]!.add(absensi);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: groupedAbsensi.length,
            itemBuilder: (context, index) {
              String matkul = groupedAbsensi.keys.elementAt(index);
              List<Absensi> absensiList = groupedAbsensi[matkul]!;

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            matkul,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: absensiList.length,
                      itemBuilder: (context, idx) {
                        final absensi = absensiList[idx];
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: idx < absensiList.length - 1
                                ? Border(bottom: BorderSide(color: Colors.grey[300]!))
                                : null,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'P${absensi.pertemuan}',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanggal: ${absensi.tanggal}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(absensi.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  absensi.status,
                                  style: TextStyle(
                                    color: _getStatusColor(absensi.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
} 