import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/jadwal.dart';

class MahasiswaJadwalScreen extends StatefulWidget {
  @override
  _MahasiswaJadwalScreenState createState() => _MahasiswaJadwalScreenState();
}

class _MahasiswaJadwalScreenState extends State<MahasiswaJadwalScreen> {
  final List<String> _hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      await Provider.of<JadwalProvider>(context, listen: false).getJadwalMahasiswa(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Kuliah'),
        backgroundColor: Colors.blue[900],
      ),
      body: Consumer<JadwalProvider>(
        builder: (context, provider, child) {
          if (provider.jadwalList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada jadwal kuliah',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          // Group jadwal by hari
          Map<String, List<Jadwal>> groupedJadwal = {};
          for (var jadwal in provider.jadwalList) {
            if (!groupedJadwal.containsKey(jadwal.hari)) {
              groupedJadwal[jadwal.hari] = [];
            }
            groupedJadwal[jadwal.hari]!.add(jadwal);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _hariList.length,
            itemBuilder: (context, index) {
              String hari = _hariList[index];
              List<Jadwal> jadwalList = groupedJadwal[hari] ?? [];

              if (jadwalList.isEmpty) return SizedBox.shrink();

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
                            hari,
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
                      itemCount: jadwalList.length,
                      itemBuilder: (context, idx) {
                        final jadwal = jadwalList[idx];
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: idx < jadwalList.length - 1
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
                                  jadwal.jam,
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
                                      jadwal.namaMatkul ?? 'Mata Kuliah',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Kode: ${jadwal.kodeMatkul ?? '-'}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          jadwal.ruangan ?? 'Ruangan belum ditentukan',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          jadwal.namaDosen ?? 'Dosen belum ditentukan',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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