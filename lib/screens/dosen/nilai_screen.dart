import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/nilai_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matakuliah_provider.dart';
import '../../models/nilai.dart';

class DosenNilaiScreen extends StatefulWidget {
  @override
  _DosenNilaiScreenState createState() => _DosenNilaiScreenState();
}

class _DosenNilaiScreenState extends State<DosenNilaiScreen> {
  List<Map<String, dynamic>> _matakuliahList = [];
  List<Map<String, dynamic>> _mahasiswaList = [];
  int? _selectedMatakuliah;
  int? _selectedMahasiswa;
  final _formKey = GlobalKey<FormState>();
  final _nilaiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadMatakuliah();
  }

  @override
  void dispose() {
    _nilaiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      await Provider.of<NilaiProvider>(context, listen: false).getNilaiByDosen(userId);
      await Provider.of<MataKuliahProvider>(context, listen: false).getMataKuliahByDosen(userId);
    }
  }

  Future<void> _loadMatakuliah() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      final matakuliah = await Provider.of<NilaiProvider>(context, listen: false)
          .getMatakuliahDosen(userId);
      setState(() {
        _matakuliahList = matakuliah;
      });
    }
  }

  Future<void> _loadMahasiswa(int idMatakuliah) async {
    final mahasiswa = await Provider.of<NilaiProvider>(context, listen: false)
        .getMahasiswaByMatakuliah(idMatakuliah);
    setState(() {
      _mahasiswaList = mahasiswa;
    });
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kelola Nilai'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Input Nilai'),
              Tab(text: 'List Nilai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Input Nilai
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown Mata Kuliah
                    DropdownButtonFormField<int>(
                      value: _selectedMatakuliah,
                      hint: Text('Pilih Mata Kuliah'),
                      decoration: InputDecoration(
                        labelText: 'Pilih Mata Kuliah',
                        border: OutlineInputBorder(),
                      ),
                      items: _matakuliahList.map((mk) {
                        return DropdownMenuItem(
                          value: mk['id'] as int,
                          child: Text('${mk['nama_matkul']} (${mk['kode_matakul']})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMatakuliah = value;
                          _selectedMahasiswa = null; // Reset pilihan mahasiswa
                          _mahasiswaList = []; // Reset list mahasiswa
                        });
                        if (value != null) {
                          _loadMahasiswa(value);
                        }
                      },
                      validator: (value) {
                        if (value == null) return 'Pilih mata kuliah';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Dropdown Mahasiswa
                    DropdownButtonFormField<int>(
                      value: _selectedMahasiswa,
                      hint: Text('Pilih Mahasiswa'),
                      decoration: InputDecoration(
                        labelText: 'Pilih Mahasiswa',
                        border: OutlineInputBorder(),
                      ),
                      items: _mahasiswaList.map((mhs) {
                        return DropdownMenuItem(
                          value: mhs['id'] as int,
                          child: Text('${mhs['npm']} - ${mhs['nama']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMahasiswa = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Pilih mahasiswa';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Input Nilai
                    TextFormField(
                      controller: _nilaiController,
                      decoration: InputDecoration(
                        labelText: 'Nilai (0-100)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan nilai';
                        }
                        final nilai = double.tryParse(value);
                        if (nilai == null) return 'Nilai harus berupa angka';
                        if (nilai < 0 || nilai > 100) return 'Nilai harus antara 0-100';
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    ElevatedButton(
                      child: Text('Simpan Nilai'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await Provider.of<NilaiProvider>(
                            context, 
                            listen: false
                          ).addNilai(
                            _selectedMahasiswa!,
                            _selectedMatakuliah!,
                            double.parse(_nilaiController.text),
                          );

                          if (success) {
                            // Refresh data setelah menambah nilai
                            final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
                            if (userId != null) {
                              await Provider.of<NilaiProvider>(context, listen: false).getNilaiByDosen(userId);
                            }

                            // Reset form
                            setState(() {
                              _selectedMatakuliah = null;
                              _selectedMahasiswa = null;
                              _mahasiswaList = [];
                              _nilaiController.clear();
                            });
                            _formKey.currentState!.reset();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Berhasil menambah nilai'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menambah nilai'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Tab List Nilai
            Consumer<NilaiProvider>(
              builder: (context, provider, child) {
                if (provider.nilaiList.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada data nilai',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                // Kelompokkan berdasarkan mata kuliah
                Map<String, List<Nilai>> groupedNilai = {};
                for (var nilai in provider.nilaiList) {
                  String key = '${nilai.namaMatkul} (${nilai.kodeMatkul})';
                  if (!groupedNilai.containsKey(key)) {
                    groupedNilai[key] = [];
                  }
                  groupedNilai[key]!.add(nilai);
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: groupedNilai.length,
                  itemBuilder: (context, index) {
                    String matkul = groupedNilai.keys.elementAt(index);
                    List<Nilai> nilaiList = groupedNilai[matkul]!;

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          matkul,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        subtitle: Text('${nilaiList.length} mahasiswa'),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: nilaiList.length,
                            itemBuilder: (context, idx) {
                              final nilai = nilaiList[idx];
                              return ListTile(
                                title: Text('${nilai.namaMahasiswa} (${nilai.npm})'),
                                subtitle: Text('Nilai: ${nilai.nilai}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Show edit dialog
                                  },
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
          ],
        ),
      ),
    );
  }
} 