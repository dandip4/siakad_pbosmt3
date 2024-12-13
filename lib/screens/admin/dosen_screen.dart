import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dosen_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/dosen.dart';
import '../../models/user.dart';
import 'admin_screen_template.dart';

class DosenScreen extends StatefulWidget {
  @override
  _DosenScreenState createState() => _DosenScreenState();
}

class _DosenScreenState extends State<DosenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nidnController = TextEditingController();
  final _emailController = TextEditingController();
  final _jabatanController = TextEditingController();

  void _showEditDialog(BuildContext context, Dosen dosen) {
    // Pre-fill form untuk edit
    _namaController.text = dosen.nama;
    _nidnController.text = dosen.nidn;
    _emailController.text = dosen.email ?? '';
    _jabatanController.text = dosen.jabatan ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Dosen'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nidnController,
                  decoration: InputDecoration(
                    labelText: 'NIDN',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIDN tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _jabatanController,
                  decoration: InputDecoration(
                    labelText: 'Jabatan',
                    border: OutlineInputBorder(),
                  ),
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
                final success = await Provider.of<DosenProvider>(
                  context, 
                  listen: false
                ).updateDosen(
                  dosen.id,
                  _namaController.text,
                  _nidnController.text,
                  _emailController.text,
                  _jabatanController.text,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil mengupdate dosen'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengupdate dosen'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Dosen dosen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus dosen ini?'),
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
              final success = await Provider.of<DosenProvider>(
                context, 
                listen: false
              ).deleteDosen(dosen.id);

              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil menghapus dosen'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus dosen'),
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

  void _showAddDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nidnController = TextEditingController();
    final _namaController = TextEditingController();
    final _emailController = TextEditingController();
    final _jabatanController = TextEditingController();
    int? _selectedUserId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return FutureBuilder<List<User>>(
            future: Provider.of<UserProvider>(context, listen: false).getUnassignedDosenUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  content: Center(child: CircularProgressIndicator()),
                );
              }

              final unassignedUsers = snapshot.data ?? [];
              if (unassignedUsers.isEmpty) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('Tidak ada user dosen yang tersedia'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Tutup'),
                    ),
                  ],
                );
              }

              return AlertDialog(
                title: Text('Tambah Dosen'),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedUserId,
                          decoration: InputDecoration(
                            labelText: 'Pilih User',
                            border: OutlineInputBorder(),
                          ),
                          items: unassignedUsers.map<DropdownMenuItem<int>>((user) {
                            return DropdownMenuItem<int>(
                              value: user.id,
                              child: Text(user.username),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              _selectedUserId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) return 'Pilih user terlebih dahulu';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _nidnController,
                          decoration: InputDecoration(
                            labelText: 'NIDN',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'NIDN tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: 'Nama',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _jabatanController,
                          decoration: InputDecoration(
                            labelText: 'Jabatan',
                            border: OutlineInputBorder(),
                          ),
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
                        final success = await Provider.of<DosenProvider>(
                          context,
                          listen: false,
                        ).addDosen(
                          _namaController.text,
                          _nidnController.text,
                          _emailController.text,
                          _jabatanController.text,
                          _selectedUserId!,
                        );

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Berhasil menambah dosen'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menambah dosen'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Tambah',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreenTemplate(
      title: 'Manajemen Dosen',
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
      body: Consumer<DosenProvider>(
        builder: (context, provider, child) {
          if (provider.dosenList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data dosen',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.dosenList.length,
            itemBuilder: (context, index) {
              final dosen = provider.dosenList[index];
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
                      dosen.nama[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    dosen.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('NIDN: ${dosen.nidn}'),
                      Text('Email: ${dosen.email}'),
                      if (dosen.jabatan != null)
                        Text('Jabatan: ${dosen.jabatan}'),
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
                        _showEditDialog(context, dosen);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, dosen);
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