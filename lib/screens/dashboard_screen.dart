import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../data/mock_data.dart';
import 'create_leave_form.dart';
import 'leave_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Role role;
  final String userName;
  const DashboardScreen({super.key, required this.role, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  // LOGIKA FILTER
  List<LeaveRequest> get filteredList {
    if (widget.role == Role.user) {
      return mockDatabase.where((e) => e.requesterRole == Role.user).toList();
    } 
    else if (widget.role == Role.kabid) {
      return mockDatabase.where((e) {
        bool isTaskForMe = (e.status == LeaveStatus.pendingKabid);
        bool isMyOwnRequest = (e.requesterRole == Role.kabid);
        return isTaskForMe || isMyOwnRequest;
      }).toList();
    } 
    else {
      return mockDatabase.where((e) {
        bool isTaskForMe = (e.status == LeaveStatus.pendingKadin);
        bool isMyOwnRequest = (e.requesterRole == Role.kadin);
        return isTaskForMe || isMyOwnRequest;
      }).toList();
    }
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.role == Role.user ? "Pegawai" : (widget.role == Role.kabid ? "Kabid" : "Kadin"), style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: _getRoleColor(),
        foregroundColor: Colors.white,
      ),
      body: filteredList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Tidak ada data", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildRequestCard(item);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => CreateLeaveForm(userRole: widget.role))
          );
          _refresh();
        },
        label: const Text("Ajukan Cuti"),
        icon: const Icon(Icons.add),
        backgroundColor: _getRoleColor(),
        foregroundColor: Colors.white,
      ),
    );
  }

  // Warna Tema Aplikasi (Header & Tombol) tetap sesuai Login
  Color _getRoleColor() {
    if (widget.role == Role.user) return const Color(0xFF0D47A1);
    if (widget.role == Role.kabid) return Colors.green[800]!;
    // Hapus 'if' terakhir, langsung return saja agar komputer yakin pasti ada nilainya
    return Colors.orange[800]!; 
  }

  Widget _buildRequestCard(LeaveRequest item) {
    // --- LOGIKA WARNA LABEL (KONSTAN SESUAI ROLE PEMBUAT) ---
    String prefixLabel = "";
    Color labelColor = Colors.black; // Default
    
    switch (item.requesterRole) {
      case Role.user:
        prefixLabel = "[PEGAWAI]";
        labelColor = Colors.blue[700]!; // Biru
        break;
      case Role.kabid:
        prefixLabel = "[KABID]";
        labelColor = Colors.green[700]!; // Hijau (Sesuai Request)
        break;
      case Role.kadin:
        prefixLabel = "[KADIN]";
        labelColor = Colors.orange[800]!; // Orange (Sesuai Request)
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeaveDetailScreen(request: item, userRole: widget.role),
            ),
          );
          _refresh(); 
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$prefixLabel ", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 14, 
                              // Gunakan warna fix yang sudah ditentukan di atas
                              color: labelColor 
                            )
                          ),
                          TextSpan(
                            text: item.jenisCuti, 
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16, 
                              color: Colors.black87
                            )
                          ),
                        ]
                      ),
                    ),
                  ),
                  _buildStatusChip(item.status),
                ],
              ),
              const Divider(height: 24),
              _buildRowInfo(Icons.person, "Nama", item.nama),
              _buildRowInfo(Icons.calendar_today, "Tanggal", "${DateFormat('dd MMM').format(item.tanggalMulai)} - ${DateFormat('dd MMM yyyy').format(item.tanggalSelesai)}"),
              
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text("Ketuk untuk detail >", style: TextStyle(fontSize: 12, color: _getRoleColor(), fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(LeaveStatus status) {
    Color color;
    String text;
    switch (status) {
      case LeaveStatus.pendingKabid: color = Colors.orange; text = "Menunggu Kabid"; break;
      case LeaveStatus.pendingKadin: color = Colors.blue; text = "Menunggu Kadin"; break;
      case LeaveStatus.approved: color = Colors.green; text = "Disetujui"; break;
      case LeaveStatus.rejected: color = Colors.red; text = "Ditolak"; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}