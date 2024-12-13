// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/nilai_provider.dart';
// import '../../providers/mahasiswa_provider.dart';
// import '../../providers/matakuliah_provider.dart';
// import '../../models/nilai.dart';
// import '../../models/mahasiswa.dart';
// import '../../models/mata_kuliah.dart';

// class NilaiScreen extends StatefulWidget {
//   @override
//   _NilaiScreenState createState() => _NilaiScreenState();
// }

// class _NilaiScreenState extends State<NilaiScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nilaiController = TextEditingController();
//   int? _selectedMahasiswaId;
//   int? _selectedMatakuliahId;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       Provider.of<NilaiProvider>(context, listen: false).getAllNilai();
//       Provider.of<MahasiswaProvider>(context, listen: false).getAllMahasiswa();
//       Provider.of<MataKuliahProvider>(context, listen: false).getAllMataKuliah();
//     });
//   }

//   void _showFormDialog({Nilai? nilai}) {
//     if (nilai != null) {
//       _nilaiController.text = nilai.nilai.toString();
//       _selectedMahasiswaId = nilai.idMahasiswa;
//       _selectedMatakuliahId = nilai.idMatakuliah;
//     } else {
//       _nilaiController.clear();
//       _selectedMahasiswaId = null;
//       _selectedMatakuliahId = null;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(nilai == null ? 'Tambah Nilai' : 'Edit Nilai'),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (nilai == null) ...[
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
//                   Consumer<MataKuliahProvider>(
//                     builder: (context, matakuliahProvider, child) {
//                       return DropdownButtonFormField<int>(
//                         value: _selectedMatakuliahId,
//                         decoration: InputDecoration(labelText: 'Mata Kuliah'),
//                         items: matakuliahProvider.mataKuliahList.map((MataKuliah mk) {
//                           return DropdownMenuItem<int>(
//                             value: mk.id,
//                             child: Text('${mk.kodeMatkul} - ${mk.namaMatkul}'),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedMatakuliahId = value;
//                           });
//                         },
//                         validator: (value) =>
//                             value == null ? 'Pilih mata kuliah' : null,
//                       );
//                     },
//                   ),
//                 ],
//                 TextFormField(
//                   controller: _nilaiController,
//                   decoration: InputDecoration(labelText: 'Nilai'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value!.isEmpty) return 'Nilai tidak boleh kosong';
//                     final nilai = double.tryParse(value);
//                     if (nilai == null) return 'Nilai harus berupa angka';
//                     if (nilai < 0 || nilai > 100) return 'Nilai harus antara 0-100';
//                     return null;
//                   },
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
//                     Provider.of<NilaiProvider>(context, listen: false);
//                 bool success;

//                 if (nilai == null) {
//                   success = await provider.addNilai(
//                     _selectedMahasiswaId!,
//                     _selectedMatakuliahId!,
//                     double.parse(_nilaiController.text),
//                   );
//                 } else {
//                   success = await provider.updateNilai(
//                     nilai.id,
//                     double.parse(_nilaiController.text),
//                   );
//                 }

//                 if (success) {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(nilai == null
//                           ? 'Berhasil menambah nilai'
//                           : 'Berhasil mengupdate nilai'),
//                     ),
//                   );
//                 }
//               }
//             },
//             child: Text(nilai == null ? 'Tambah' : 'Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Kelola Nilai'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showFormDialog(),
//         child: Icon(Icons.add),
//       ),
//       body: Consumer<NilaiProvider>(
//         builder: (context, provider, child) {
//           if (provider.nilaiList.isEmpty) {
//             return Center(child: Text('Tidak ada data nilai'));
//           }

//           return ListView.builder(
//             itemCount: provider.nilaiList.length,
//             itemBuilder: (context, index) {
//               final nilai = provider.nilaiList[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 child: ListTile(
//                   title: Text('${nilai.namaMahasiswa} (${nilai.npm})'),
//                   subtitle: Text('${nilai.namaMatkul} (${nilai.kodeMatkul})'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           nilai.nilai.toString(),
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () => _showFormDialog(nilai: nilai),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () async {
//                           final confirm = await showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: Text('Konfirmasi'),
//                               content: Text(
//                                   'Apakah Anda yakin ingin menghapus nilai ini?'),
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
//                             final success = await provider.deleteNilai(nilai.id);
//                             if (success) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Berhasil menghapus nilai'),
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