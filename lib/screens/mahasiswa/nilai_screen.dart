import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/nilai_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/nilai.dart';

class MahasiswaNilaiScreen extends StatefulWidget {
  @override
  _MahasiswaNilaiScreenState createState() => _MahasiswaNilaiScreenState();
}

class _MahasiswaNilaiScreenState extends State<MahasiswaNilaiScreen> {
  @override
  void initState() {
    super.initState();
    _loadNilai();
  }

  Future<void> _loadNilai() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      await Provider.of<NilaiProvider>(context, listen: false).getNilaiByMahasiswa(userId);
    }
  }

  String _getGrade(double nilai) {
    if (nilai >= 85) return 'A';
    if (nilai >= 80) return 'A-';
    if (nilai >= 75) return 'B+';
    if (nilai >= 70) return 'B';
    if (nilai >= 65) return 'B-';
    if (nilai >= 60) return 'C+';
    if (nilai >= 55) return 'C';
    if (nilai >= 40) return 'D';
    return 'E';
  }

  Color _getGradeColor(String grade) {
    switch (grade[0]) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kartu Hasil Studi'),
        backgroundColor: Colors.blue[900],
      ),
      body: Consumer<NilaiProvider>(
        builder: (context, provider, child) {
          if (provider.nilaiList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data nilai',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          // Group nilai by semester
          Map<String, List<Nilai>> groupedNilai = {};
          for (var nilai in provider.nilaiList) {
            String key = 'Semester ${nilai.semester}';
            if (!groupedNilai.containsKey(key)) {
              groupedNilai[key] = [];
            }
            groupedNilai[key]!.add(nilai);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: groupedNilai.length,
            itemBuilder: (context, index) {
              String semester = groupedNilai.keys.elementAt(index);
              List<Nilai> nilaiList = groupedNilai[semester]!;

              // Hitung IP Semester
              double totalNilai = 0;
              double totalSKS = 0;
              for (var nilai in nilaiList) {
                totalNilai += nilai.nilai * (nilai.sks ?? 0);
                totalSKS += (nilai.sks ?? 0).toDouble();
              }
              double ipSemester = totalNilai / (totalSKS > 0 ? totalSKS : 1);

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                semester,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'IP: ${ipSemester.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
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
                      itemCount: nilaiList.length,
                      itemBuilder: (context, idx) {
                        final nilai = nilaiList[idx];
                        final grade = _getGrade(nilai.nilai);
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: idx < nilaiList.length - 1
                                ? Border(bottom: BorderSide(color: Colors.grey[300]!))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nilai.namaMatkul ?? 'Mata Kuliah',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Kode: ${nilai.kodeMatkul ?? '-'} (${nilai.sks ?? 0} SKS)',
                                      style: TextStyle(
                                        color: Colors.grey[600],
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
                                  color: _getGradeColor(grade).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  grade,
                                  style: TextStyle(
                                    color: _getGradeColor(grade),
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