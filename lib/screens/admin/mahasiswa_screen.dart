import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mahasiswa_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/mahasiswa.dart';
import '../../models/user.dart';
import 'admin_screen_template.dart';

class MahasiswaScreen extends StatefulWidget {
  @override
  _MahasiswaScreenState createState() => _MahasiswaScreenState();
}

class _MahasiswaScreenState extends State<MahasiswaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _npmController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();

  void _showEditDialog(BuildContext context, Mahasiswa mahasiswa) {
    // Pre-fill form for editing
    _npmController.text = mahasiswa.npm;
    _namaController.text = mahasiswa.nama;
    _emailController.text = mahasiswa.email ?? '';
    _alamatController.text = mahasiswa.alamat ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Mahasiswa'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _npmController,
                  decoration: InputDecoration(
                    labelText: 'NPM',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NPM tidak boleh kosong';
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
                  controller: _alamatController,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                final success = await Provider.of<MahasiswaProvider>(
                  context, 
                  listen: false
                ).updateMahasiswa(
                  mahasiswa.id,
                  _namaController.text,
                  _npmController.text,
                  _emailController.text,
                  _alamatController.text,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil mengupdate mahasiswa'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengupdate mahasiswa'),
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

  void _showDeleteDialog(BuildContext context, Mahasiswa mahasiswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus mahasiswa ini?'),
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
              final success = await Provider.of<MahasiswaProvider>(
                context, 
                listen: false
              ).deleteMahasiswa(mahasiswa.id);

              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil menghapus mahasiswa'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus mahasiswa'),
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
    final _npmController = TextEditingController();
    final _namaController = TextEditingController();
    final _emailController = TextEditingController();
    final _alamatController = TextEditingController();
    int? _selectedUserId;
    List<User> _unassignedUsers = [];

    // Buat StatefulBuilder untuk update state di dalam dialog
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Load unassigned users saat dialog dibuka
          if (_unassignedUsers.isEmpty) {
            Future.microtask(() async {
              final users = await Provider.of<UserProvider>(
                context,
                listen: false
              ).getUnassignedUsers();
              setState(() {
                _unassignedUsers = users;
              });
            });
          }

          return AlertDialog(
            title: Text('Tambah Mahasiswa'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown User
                    DropdownButtonFormField<int>(
                      value: _selectedUserId,
                      decoration: InputDecoration(
                        labelText: 'Pilih User',
                        border: OutlineInputBorder(),
                      ),
                      items: _unassignedUsers.map((user) {
                        return DropdownMenuItem<int>(
                          value: user.id,
                          child: Text(user.username),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
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
                      controller: _npmController,
                      decoration: InputDecoration(
                        labelText: 'NPM',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NPM tidak boleh kosong';
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
                      controller: _alamatController,
                      decoration: InputDecoration(
                        labelText: 'Alamat',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
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
                    final success = await Provider.of<MahasiswaProvider>(
                      context,
                      listen: false,
                    ).addMahasiswa(
                      _npmController.text,
                      _namaController.text,
                      _emailController.text,
                      _alamatController.text,
                      _selectedUserId.toString(), // Convert to String
                    );

                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Berhasil menambah mahasiswa'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menambah mahasiswa'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreenTemplate(
      title: 'Manajemen Mahasiswa',
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
        onPressed: () => _showAddDialog(context),
      ),
      body: Consumer<MahasiswaProvider>(
        builder: (context, provider, child) {
          if (provider.mahasiswaList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data mahasiswa',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.mahasiswaList.length,
            itemBuilder: (context, index) {
              final mahasiswa = provider.mahasiswaList[index];
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
                      mahasiswa.nama[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    mahasiswa.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('NPM: ${mahasiswa.npm}'),
                      Text('Email: ${mahasiswa.email}'),
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
                        _showEditDialog(context, mahasiswa);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, mahasiswa);
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