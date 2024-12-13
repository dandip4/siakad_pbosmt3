import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/matakuliah_provider.dart';
import '../../models/jadwal.dart';
import 'admin_screen_template.dart';

class JadwalScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _ruanganController = TextEditingController();
  final _jamController = TextEditingController();
  String? _selectedHari;
  int? _selectedMatakuliah;

  final List<String> _hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  void _showFormDialog(BuildContext context, {Jadwal? jadwal}) {
    // Pre-fill form jika edit
    if (jadwal != null) {
      _ruanganController.text = jadwal.ruangan;
      _jamController.text = jadwal.jam;
      _selectedHari = jadwal.hari;
      _selectedMatakuliah = jadwal.idMatakuliah;
    } else {
      _ruanganController.clear();
      _jamController.clear();
      _selectedHari = null;
      _selectedMatakuliah = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<MataKuliahProvider>(
                  builder: (context, matakuliahProvider, child) {
                    return DropdownButtonFormField<int>(
                      value: _selectedMatakuliah,
                      decoration: InputDecoration(
                        labelText: 'Mata Kuliah',
                        border: OutlineInputBorder(),
                      ),
                      items: matakuliahProvider.mataKuliahList.map((mk) {
                        return DropdownMenuItem(
                          value: mk.id,
                          child: Text('${mk.kodeMatkul} - ${mk.namaMatkul}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _selectedMatakuliah = value;
                      },
                      validator: (value) {
                        if (value == null) return 'Pilih mata kuliah';
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedHari,
                  decoration: InputDecoration(
                    labelText: 'Hari',
                    border: OutlineInputBorder(),
                  ),
                  items: _hariList.map((hari) {
                    return DropdownMenuItem(
                      value: hari,
                      child: Text(hari),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedHari = value;
                  },
                  validator: (value) {
                    if (value == null) return 'Pilih hari';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _ruanganController,
                  decoration: InputDecoration(
                    labelText: 'Ruangan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ruangan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _jamController,
                  decoration: InputDecoration(
                    labelText: 'Jam (HH:mm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jam tidak boleh kosong';
                    }
                    // Validasi format jam
                    final RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
                    if (!timeRegex.hasMatch(value)) {
                      return 'Format jam tidak valid (HH:mm)';
                    }
                    return null;
                  },
                ),
              ],
            ),
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
                final provider = Provider.of<JadwalProvider>(
                  context, 
                  listen: false
                );

                bool success;
                if (jadwal == null) {
                  // Create
                  success = await provider.addJadwal(
                    _selectedMatakuliah!,
                    _selectedHari!,
                    _jamController.text,
                    _ruanganController.text,
                  );
                } else {
                  // Update
                  success = await provider.updateJadwal(
                    jadwal.id,
                    _selectedMatakuliah!,
                    _selectedHari!,
                    _jamController.text,
                    _ruanganController.text,
                  );
                }

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        jadwal == null 
                          ? 'Berhasil menambah jadwal' 
                          : 'Berhasil mengupdate jadwal'
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Terjadi kesalahan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              jadwal == null ? 'Tambah' : 'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Jadwal jadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final success = await Provider.of<JadwalProvider>(
                context, 
                listen: false
              ).deleteJadwal(jadwal.id);

              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil menghapus jadwal'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus jadwal'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load mata kuliah list for dropdown
    Future.microtask(() {
      Provider.of<MataKuliahProvider>(context, listen: false).getAllMataKuliah();
    });

    return AdminScreenTemplate(
      title: 'Manajemen Jadwal',
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.add),
        onPressed: () => _showFormDialog(context),
      ),
      body: Consumer<JadwalProvider>(
        builder: (context, provider, child) {
          if (provider.jadwalList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data jadwal',
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hari,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  ...jadwalList.map((jadwal) => Card(
                    margin: EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        '${jadwal.namaMatkul}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ruangan: ${jadwal.ruangan}'),
                          Text('Jam: ${jadwal.jam}'),
                          if (jadwal.namaDosen != null)
                            Text('Dosen: ${jadwal.namaDosen}'),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: Colors.blue[900]),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit, color: Colors.blue[900]),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Hapus'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showFormDialog(context, jadwal: jadwal);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, jadwal);
                          }
                        },
                      ),
                    ),
                  )).toList(),
                  SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 