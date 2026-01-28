import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../data/mock_data.dart';
import 'leave_detail_screen.dart';

class InboxScreen extends StatefulWidget {
  final Role role;
  final String userName; 
  const InboxScreen({super.key, required this.role, required this.userName}); // Update constructor

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  
  // INI HANYA YANG STATUSNYA MASIH PROSES (PENDING)
  List<LeaveRequest> get filteredList {
    return mockDatabase.where((e) {
      
      // Cek apakah statusnya masih pending (Belum final)
      bool isPending = (e.status == LeaveStatus.pendingKabid || e.status == LeaveStatus.pendingKadin);
      
      // Jika statusnya sudah Approved/Rejected, JANGAN tampilkan di sini (Pindah ke Riwayat)
      if (!isPending) return false;

      // --- FILTER KEPEMILIKAN ---
      
      // 1. Apakah ini milik saya sendiri?
      bool isMyOwnRequest = (e.requesterRole == widget.role);

      // 2. Apakah ini tugas verifikasi untuk saya?
      bool isTaskForMe = false;
      if (widget.role == Role.kabid && e.status == LeaveStatus.pendingKabid) isTaskForMe = true;
      if (widget.role == Role.kadin && e.status == LeaveStatus.pendingKadin) isTaskForMe = true;

      // Tampilkan jika ini milik saya ATAU tugas saya
      return isMyOwnRequest || isTaskForMe;

    }).toList();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox (Dalam Proses)"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: filteredList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Tidak ada pengajuan aktif", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("Semua pengajuan selesai ada di menu Riwayat", style: TextStyle(fontSize: 12, color: Colors.grey[400])),
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
    );
  }

  Widget _buildRequestCard(LeaveRequest item) {
    String prefixLabel = "";
    Color labelColor = Colors.black;
    
    switch (item.requesterRole) {
      case Role.user: prefixLabel = "[PEGAWAI]"; labelColor = Colors.blue[700]!; break;
      case Role.kabid: prefixLabel = "[KABID]"; labelColor = Colors.orange[800]!; break;
      case Role.kadin: prefixLabel = "[KADIN]"; labelColor = Colors.green[700]!; break;
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
              builder: (context) => LeaveDetailScreen(request: item, userRole: widget.role, userName: widget.userName),
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
                          TextSpan(text: "$prefixLabel ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: labelColor)),
                          TextSpan(text: item.jenisCuti, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  _buildStatusChip(item.status),
                ],
              ),
              const Divider(height: 24),
              _buildRowInfo(Icons.person, item.nama),
              _buildRowInfo(Icons.calendar_today, "${DateFormat('dd MMM').format(item.tanggalMulai)} - ${DateFormat('dd MMM yyyy').format(item.tanggalSelesai)}"),
              
              const SizedBox(height: 12),
              
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Ketuk untuk proses/detail >", 
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.blue[800], 
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowInfo(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
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
      default: color = Colors.grey; text = "Selesai"; 
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}