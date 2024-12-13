// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../providers/absensi_provider.dart';
// import '../../providers/mahasiswa_provider.dart';
// import '../../providers/jadwal_provider.dart';
// import '../../models/absensi.dart';
// import '../../models/mahasiswa.dart';
// import '../../models/jadwal.dart';

// class AbsensiScreen extends StatefulWidget {
//   @override
//   _AbsensiScreenState createState() => _AbsensiScreenState();
// }

// class _AbsensiScreenState extends State<AbsensiScreen> {
//   final _formKey = GlobalKey<FormState>();
//   DateTime _selectedDate = DateTime.now();
//   int? _selectedMahasiswaId;
//   int? _selectedJadwalId;
//   String? _selectedStatus;

//   final List<String> _statusList = ['Hadir', 'Izin', 'Sakit', 'Alpa'];

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       Provider.of<AbsensiProvider>(context, listen: false).getAllAbsensi();
//       Provider.of<MahasiswaProvider>(context, listen: false).getAllMahasiswa();
//       Provider.of<JadwalProvider>(context, listen: false).getAllJadwal();
//     });
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   void _showFormDialog({Absensi? absensi}) {
//     if (absensi != null) {
//       _selectedDate = DateTime.parse(absensi.tanggal);
//       _selectedMahasiswaId = absensi.idMahasiswa;
//       _selectedJadwalId = absensi.idJadwal;
//       _selectedStatus = absensi.status;
//     } else {
//       _selectedDate = DateTime.now();
//       _selectedMahasiswaId = null;
//       _selectedJadwalId = null;
//       _selectedStatus = null;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(absensi == null ? 'Tambah Absensi' : 'Edit Absensi'),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (absensi == null) ...[
//                   Consumer<MahasiswaProvider>(
//                     builder: (context, mahasiswaProvider, child) {
//                       return DropdownButtonFormField<int>(
//                         value: _selectedMahasiswaId,
//                         decoration: InputDecoration(labelText: 'Mahasiswa'),
//                         items: mahasiswaProvider.mahasiswaList.map((Mahasiswa mhs) {
//                           return DropdownMenuItem<int>(
//                             value: mhs.id,
//                             child: Text('${mhs.npm} - ${mhs.nama}'),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedMahasiswaId = value;
//                           });
//                         },
//                         validator: (value) =>
//                             value == null ? 'Pilih mahasiswa' : null,
//                       );
//                     },
//                   ),
//                   Consumer<JadwalProvider>(
//                     builder: (context, jadwalProvider, child) {
//                       return DropdownButtonFormField<int>(
//                         value: _selectedJadwalId,
//                         decoration: InputDecoration(labelText: 'Jadwal'),
//                         items: jadwalProvider.jadwalList.map((Jadwal jadwal) {
//                           return DropdownMenuItem<int>(
//                             value: jadwal.id,
//                             child: Text(
//                                 '${jadwal.namaMatkul} - ${jadwal.hari} ${jadwal.jam}'),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedJadwalId = value;
//                           });
//                         },
//                         validator: (value) =>
//                             value == null ? 'Pilih jadwal' : null,
//                       );
//                     },
//                   ),
//                 ],
//                 ListTile(
//                   title: Text('Tanggal'),
//                   subtitle: Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
//                   trailing: Icon(Icons.calendar_today),
//                   onTap: () => _selectDate(context),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _selectedStatus,
//                   decoration: InputDecoration(labelText: 'Status'),
//                   items: _statusList.map((String status) {
//                     return DropdownMenuItem<String>(
//                       value: status,
//                       child: Text(status),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedStatus = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Pilih status' : null,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final provider =
//                     Provider.of<AbsensiProvider>(context, listen: false);
//                 bool success;

//                 if (absensi == null) {
//                   success = await provider.addAbsensi(
//                     _selectedMahasiswaId!,
//                     _selectedJadwalId!,
//                     DateFormat('yyyy-MM-dd').format(_selectedDate),
//                     _selectedStatus!,
//                   );
//                 } else {
//                   success = await provider.updateAbsensi(
//                     absensi.id,
//                     _selectedStatus!,
//                   );
//                 }

//                 if (success) {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(absensi == null
//                           ? 'Berhasil menambah absensi'
//                           : 'Berhasil mengupdate absensi'),
//                     ),
//                   );
//                 }
//               }
//             },
//             child: Text(absensi == null ? 'Tambah' : 'Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Kelola Absensi'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showFormDialog(),
//         child: Icon(Icons.add),
//       ),
//       body: Consumer<AbsensiProvider>(
//         builder: (context, provider, child) {
//           if (provider.absensiList.isEmpty) {
//             return Center(child: Text('Tidak ada data absensi'));
//           }

//           return ListView.builder(
//             itemCount: provider.absensiList.length,
//             itemBuilder: (context, index) {
//               final absensi = provider.absensiList[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 child: ListTile(
//                   title: Text('${absensi.namaMahasiswa} (${absensi.npm})'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('${absensi.namaMatkul} (${absensi.kodeMatkul})'),
//                       Text('Tanggal: ${absensi.tanggal}'),
//                       Text('Status: ${absensi.status}'),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () => _showFormDialog(absensi: absensi),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () async {
//                           final confirm = await showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: Text('Konfirmasi'),
//                               content: Text(
//                                   'Apakah Anda yakin ingin menghapus absensi ini?'),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, false),
//                                   child: Text('Tidak'),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   child: Text('Ya'),
//                                 ),
//                               ],
//                             ),
//                           );

//                           if (confirm) {
//                             final success = await provider.deleteAbsensi(absensi.id);
//                             if (success) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Berhasil menghapus absensi'),
//                                 ),
//                               );
//                             }
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// } 