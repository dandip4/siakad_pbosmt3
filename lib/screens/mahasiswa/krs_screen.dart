import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/krs_provider.dart';
import '../../providers/matakuliah_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/krs.dart';

class KRSScreen extends StatefulWidget {
  @override
  _KRSScreenState createState() => _KRSScreenState();
}

class _KRSScreenState extends State<KRSScreen> {
  final _formKey = GlobalKey<FormState>();
  final _semesterController = TextEditingController();
  final _tahunAjaranController = TextEditingController();
  int? _selectedMatakuliah;

  @override
  void initState() {
    super.initState();
    _loadData();
    Provider.of<MataKuliahProvider>(context, listen: false).getAllMataKuliah();
  }

  @override
  void dispose() {
    _semesterController.dispose();
    _tahunAjaranController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      await Provider.of<KRSProvider>(context, listen: false).getKRSByMahasiswa(userId);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kartu Rencana Studi'),
        backgroundColor: Colors.blue[900],
      ),
      body: Consumer<KRSProvider>(
        builder: (context, provider, child) {
          if (provider.krsList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada KRS',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          // Group KRS by semester
          Map<String, List<KRS>> groupedKRS = {};
          for (var krs in provider.krsList) {
            String key = 'Semester ${krs.semester}';
            if (!groupedKRS.containsKey(key)) {
              groupedKRS[key] = [];
            }
            groupedKRS[key]!.add(krs);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: groupedKRS.length,
            itemBuilder: (context, index) {
              String semester = groupedKRS.keys.elementAt(index);
              List<KRS> krsList = groupedKRS[semester]!;

              // Hitung total SKS
              int totalSKS = 0;
              for (var krs in krsList) {
                totalSKS += krs.sks ?? 0;
              }

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
                                Icons.book,
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
                            'Total: $totalSKS SKS',
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
                      itemCount: krsList.length,
                      itemBuilder: (context, idx) {
                        final krs = krsList[idx];
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: idx < krsList.length - 1
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
                                      krs.namaMatkul ?? 'Mata Kuliah',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Kode: ${krs.kodeMatkul ?? '-'} (${krs.sks ?? 0} SKS)',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Dosen: ${krs.namaDosen ?? '-'}',
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
                                  color: _getStatusColor(krs.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  krs.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(krs.status),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Ambil KRS'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _semesterController,
                      decoration: InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Semester tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _tahunAjaranController,
                      decoration: InputDecoration(
                        labelText: 'Tahun Ajaran (contoh: 2023/2024)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tahun ajaran tidak boleh kosong';
                        }
                        if (!RegExp(r'^\d{4}/\d{4}$').hasMatch(value)) {
                          return 'Format tahun ajaran tidak valid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Consumer<MataKuliahProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedMatakuliah,
                          decoration: InputDecoration(
                            labelText: 'Mata Kuliah',
                            border: OutlineInputBorder(),
                          ),
                          items: provider.mataKuliahList.map((mk) {
                            return DropdownMenuItem(
                              value: mk.id,
                              child: Text('${mk.kodeMatkul} - ${mk.namaMatkul}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMatakuliah = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) return 'Pilih mata kuliah';
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final userId = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).user?.id;

                      if (userId != null) {
                        final success = await Provider.of<KRSProvider>(
                          context,
                          listen: false,
                        ).ajukanKRS(
                          userId,
                          _selectedMatakuliah!,
                          _semesterController.text,
                          _tahunAjaranController.text,
                        );

                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Berhasil mengajukan KRS'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengajukan KRS'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    'Ajukan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 