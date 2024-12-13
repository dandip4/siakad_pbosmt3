import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/krs_provider.dart';
import '../../models/krs.dart';
import 'admin_screen_template.dart';

class AdminKRSScreen extends StatefulWidget {
  @override
  _AdminKRSScreenState createState() => _AdminKRSScreenState();
}

class _AdminKRSScreenState extends State<AdminKRSScreen> {
  @override
  void initState() {
    super.initState();
    // Load KRS data when screen is opened
    Future.microtask(() {
      Provider.of<KRSProvider>(context, listen: false).getAllKRS();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Persetujuan KRS'),
          backgroundColor: Colors.blue[900],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: [
              Tab(
                height: 60,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pending_actions, size: 20),
                    SizedBox(width: 4),
                    Text('Pending'),
                  ],
                ),
              ),
              Tab(
                height: 60,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 4),
                    Text('Disetujui'),
                  ],
                ),
              ),
              Tab(
                height: 60,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, size: 20),
                    SizedBox(width: 4),
                    Text('Ditolak'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Consumer<KRSProvider>(
          builder: (context, provider, child) {
            if (provider.krsList.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada pengajuan KRS',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            // Group KRS by status
            Map<String, List<KRS>> groupedKRS = {
              'pending': [],
              'approved': [],
              'rejected': [],
            };

            for (var krs in provider.krsList) {
              groupedKRS[krs.status]?.add(krs);
            }

            return TabBarView(
              children: [
                _buildKRSList(context, groupedKRS['pending']!),
                _buildKRSList(context, groupedKRS['approved']!),
                _buildKRSList(context, groupedKRS['rejected']!),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKRSList(BuildContext context, List<KRS> krsList) {
    if (krsList.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: krsList.length,
      itemBuilder: (context, index) {
        final krs = krsList[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(krs.status),
              child: Text(
                '${krs.sks}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${krs.namaMahasiswa} (${krs.npm})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('${krs.namaMatkul} (${krs.kodeMatkul})'),
                Text('Semester: ${krs.semester}'),
                Text('Tahun Ajaran: ${krs.tahunAjaran}'),
              ],
            ),
            trailing: krs.status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _showApproveDialog(context, krs),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _showRejectDialog(context, krs),
                      ),
                    ],
                  )
                : null,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Mata Kuliah:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Dosen: ${krs.namaDosen}'),
                    Text('SKS: ${krs.sks}'),
                    SizedBox(height: 8),
                    Text(
                      'Status: ${krs.status.toUpperCase()}',
                      style: TextStyle(
                        color: _getStatusColor(krs.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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

  void _showApproveDialog(BuildContext context, KRS krs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Persetujuan'),
        content: Text('Apakah Anda yakin ingin menyetujui KRS ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () async {
              final success = await Provider.of<KRSProvider>(
                context,
                listen: false,
              ).updateStatusKRS(krs.id, 'approved');

              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('KRS berhasil disetujui'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menyetujui KRS'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Setuju',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, KRS krs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Penolakan'),
        content: Text('Apakah Anda yakin ingin menolak KRS ini?'),
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
              final success = await Provider.of<KRSProvider>(
                context,
                listen: false,
              ).updateStatusKRS(krs.id, 'rejected');

              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('KRS berhasil ditolak'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menolak KRS'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Tolak',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 