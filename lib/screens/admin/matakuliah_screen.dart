import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/matakuliah_provider.dart';
import '../../providers/dosen_provider.dart';
import '../../models/mata_kuliah.dart';
import 'admin_screen_template.dart';

class MataKuliahScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _kodeMatakulController = TextEditingController();
  final _namaMatakulController = TextEditingController();
  final _sksController = TextEditingController();

  void _showFormDialog(BuildContext context, {MataKuliah? matakuliah}) {
    int? selectedDosenId;

    // Pre-fill form jika edit
    if (matakuliah != null) {
      _kodeMatakulController.text = matakuliah.kodeMatkul;
      _namaMatakulController.text = matakuliah.namaMatkul;
      _sksController.text = matakuliah.sks.toString();
      selectedDosenId = matakuliah.idDosen;
    } else {
      _kodeMatakulController.clear();
      _namaMatakulController.clear();
      _sksController.clear();
      selectedDosenId = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(matakuliah == null ? 'Tambah Mata Kuliah' : 'Edit Mata Kuliah'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _kodeMatakulController,
                  decoration: InputDecoration(
                    labelText: 'Kode Mata Kuliah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode mata kuliah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _namaMatakulController,
                  decoration: InputDecoration(
                    labelText: 'Nama Mata Kuliah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama mata kuliah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _sksController,
                  decoration: InputDecoration(
                    labelText: 'SKS',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'SKS tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'SKS harus berupa angka';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Consumer<DosenProvider>(
                  builder: (context, dosenProvider, child) {
                    return DropdownButtonFormField<int>(
                      value: selectedDosenId,
                      decoration: InputDecoration(
                        labelText: 'Dosen Pengampu',
                        border: OutlineInputBorder(),
                      ),
                      items: dosenProvider.dosenList.map((dosen) {
                        return DropdownMenuItem(
                          value: dosen.id,
                          child: Text('${dosen.nama} (${dosen.nidn})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedDosenId = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih dosen pengampu';
                        }
                        return null;
                      },
                    );
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
              if (_formKey.currentState!.validate() && selectedDosenId != null) {
                final provider = Provider.of<MataKuliahProvider>(
                  context, 
                  listen: false
                );

                bool success;
                if (matakuliah == null) {
                  // Create
                  success = await provider.addMataKuliah(
                    _kodeMatakulController.text,
                    _namaMatakulController.text,
                    int.parse(_sksController.text),
                    selectedDosenId!,
                  );
                } else {
                  // Update
                  success = await provider.updateMataKuliah(
                    matakuliah.id,
                    _kodeMatakulController.text,
                    _namaMatakulController.text,
                    int.parse(_sksController.text),
                    selectedDosenId!,
                  );
                }

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        matakuliah == null 
                          ? 'Berhasil menambah mata kuliah' 
                          : 'Berhasil mengupdate mata kuliah'
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
              matakuliah == null ? 'Tambah' : 'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MataKuliah matakuliah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus mata kuliah ini?'),
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
              final success = await Provider.of<MataKuliahProvider>(
                context, 
                listen: false
              ).deleteMataKuliah(matakuliah.id);

              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil menghapus mata kuliah'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus mata kuliah'),
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
    // Load dosen list for dropdown
    Future.microtask(() {
      Provider.of<DosenProvider>(context, listen: false).getAllDosen();
    });

    return AdminScreenTemplate(
      title: 'Manajemen Mata Kuliah',
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Show search dialog
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.add),
        onPressed: () => _showFormDialog(context),
      ),
      body: Consumer<MataKuliahProvider>(
        builder: (context, provider, child) {
          if (provider.mataKuliahList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data mata kuliah',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.mataKuliahList.length,
            itemBuilder: (context, index) {
              final matakuliah = provider.mataKuliahList[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    child: Text(
                      '${matakuliah.sks}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    matakuliah.namaMatkul,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Kode: ${matakuliah.kodeMatkul}'),
                      Text('SKS: ${matakuliah.sks}'),
                      if (matakuliah.namaDosen != null)
                        Text('Dosen: ${matakuliah.namaDosen}'),
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
                        _showFormDialog(context, matakuliah: matakuliah);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, matakuliah);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 