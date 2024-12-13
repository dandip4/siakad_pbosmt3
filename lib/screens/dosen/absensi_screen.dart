import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/absensi_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/absensi.dart';

class DosenAbsensiScreen extends StatefulWidget {
  @override
  _DosenAbsensiScreenState createState() => _DosenAbsensiScreenState();
}

class _DosenAbsensiScreenState extends State<DosenAbsensiScreen> {
  List<Map<String, dynamic>> _matakuliahList = [];
  List<Map<String, dynamic>> _mahasiswaList = [];
  int? _selectedMatakuliah;
  int? _selectedMahasiswa;
  String _selectedStatus = 'Hadir';
  int _pertemuan = 1;
  int _selectedPertemuan = 1;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMatakuliah();
  }

  Future<void> _loadMatakuliah() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      final matakuliah = await Provider.of<AbsensiProvider>(
        context, 
        listen: false
      ).getMatakuliahDosen(userId);
      
      setState(() {
        _matakuliahList = matakuliah;
      });
    }
  }

  Future<void> _loadMahasiswa(int idMatakuliah) async {
    final mahasiswa = await Provider.of<AbsensiProvider>(
      context, 
      listen: false
    ).getMahasiswaByMatakuliah(idMatakuliah);
    
    setState(() {
      _mahasiswaList = mahasiswa;
      _selectedMahasiswa = null; // Reset pilihan mahasiswa
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kelola Absensi'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Input Absensi'),
              Tab(text: 'List Absensi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Input Absensi
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown Mata Kuliah
                  DropdownButtonFormField<int>(
                    value: _selectedMatakuliah,
                    decoration: InputDecoration(
                      labelText: 'Pilih Mata Kuliah',
                      border: OutlineInputBorder(),
                    ),
                    items: _matakuliahList.map<DropdownMenuItem<int>>((mk) {
                      return DropdownMenuItem<int>(
                        value: mk['id'] as int,
                        child: Text('${mk['nama_matkul']} (${mk['kode_matakul']})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMatakuliah = value;
                      });
                      if (value != null) {
                        _loadMahasiswa(value);
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Dropdown Mahasiswa
                  DropdownButtonFormField<int>(
                    value: _selectedMahasiswa,
                    decoration: InputDecoration(
                      labelText: 'Pilih Mahasiswa',
                      border: OutlineInputBorder(),
                    ),
                    items: _mahasiswaList.map<DropdownMenuItem<int>>((mhs) {
                      return DropdownMenuItem<int>(
                        value: mhs['id'] as int,
                        child: Text('${mhs['npm']} - ${mhs['nama']}'),
                      );
                    }).toList(),
                    onChanged: _selectedMatakuliah == null 
                      ? null 
                      : (value) {
                          setState(() {
                            _selectedMahasiswa = value;
                          });
                        },
                  ),
                  SizedBox(height: 16),

                  // Input lainnya seperti sebelumnya
                  ListTile(
                    title: Text('Tanggal'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2025),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Pertemuan ke-',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _pertemuan.toString(),
                    onChanged: (value) {
                      setState(() {
                        _pertemuan = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status Kehadiran',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Hadir', 'Izin', 'Sakit', 'Alpa'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    child: Text('Simpan Absensi'),
                    onPressed: () async {
                      if (_selectedMatakuliah == null || _selectedMahasiswa == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pilih mata kuliah dan mahasiswa terlebih dahulu')),
                        );
                        return;
                      }

                      final success = await Provider.of<AbsensiProvider>(
                        context, 
                        listen: false
                      ).tambahAbsensi(
                        _selectedMahasiswa!,
                        _selectedMatakuliah!,
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        _selectedStatus,
                        _pertemuan,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Absensi berhasil disimpan')),
                        );
                        setState(() {
                          _selectedMahasiswa = null;
                        });
                        // Refresh list absensi
                        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
                        if (userId != null) {
                          await Provider.of<AbsensiProvider>(
                            context, 
                            listen: false
                          ).getAbsensiByDosen(userId, pertemuan: _selectedPertemuan);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan absensi')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Tab List Absensi
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('Filter Pertemuan: '),
                      SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _selectedPertemuan,
                        items: List.generate(16, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text('Pertemuan ${index + 1}'),
                          );
                        }),
                        onChanged: (value) async {
                          setState(() {
                            _selectedPertemuan = value!;
                          });
                          final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
                          if (userId != null) {
                            await Provider.of<AbsensiProvider>(
                              context, 
                              listen: false
                            ).getAbsensiByDosen(userId, pertemuan: _selectedPertemuan);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<AbsensiProvider>(
                    builder: (context, provider, child) {
                      if (provider.absensiList.isEmpty) {
                        return Center(
                          child: Text('Belum ada data absensi'),
                        );
                      }

                      // Kelompokkan berdasarkan mata kuliah
                      Map<String, List<Absensi>> groupedAbsensi = {};
                      for (var absensi in provider.absensiList) {
                        String key = '${absensi.namaMatkul} (${absensi.kodeMatkul})';
                        if (!groupedAbsensi.containsKey(key)) {
                          groupedAbsensi[key] = [];
                        }
                        groupedAbsensi[key]!.add(absensi);
                      }

                      return ListView.builder(
                        itemCount: groupedAbsensi.length,
                        itemBuilder: (context, index) {
                          String matkul = groupedAbsensi.keys.elementAt(index);
                          var absensiList = groupedAbsensi[matkul]!;
                          
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ExpansionTile(
                              title: Text(
                                matkul,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${absensiList.length} mahasiswa'),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: absensiList.length,
                                  itemBuilder: (context, idx) {
                                    var absensi = absensiList[idx];
                                    return ListTile(
                                      title: Text('${absensi.namaMahasiswa} (${absensi.npm})'),
                                      subtitle: Text(
                                        'Status: ${absensi.status}',
                                        style: TextStyle(
                                          color: absensi.status.toLowerCase() == 'hadir' 
                                            ? Colors.green 
                                            : absensi.status.toLowerCase() == 'alpa'
                                              ? Colors.red
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        initialValue: absensi.status,
                                        onSelected: (String status) async {
                                          await provider.updateStatusAbsensi(absensi.id, status);
                                          final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
                                          if (userId != null) {
                                            await provider.getAbsensiByDosen(userId, pertemuan: _selectedPertemuan);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ['Hadir', 'Izin', 'Sakit', 'Alpa']
                                              .map((String status) {
                                            return PopupMenuItem<String>(
                                              value: status,
                                              child: Text(status),
                                            );
                                          }).toList();
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 