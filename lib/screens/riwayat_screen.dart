import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../data/mock_data.dart';
import 'leave_detail_screen.dart';

class RiwayatScreen extends StatefulWidget {
  final Role role;
  final String userName;

  const RiwayatScreen({super.key, required this.role, required this.userName});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  
  List<LeaveRequest> get filteredList {
    
    // --- PEGAWAI ---
    // Pegawai melihat SEMUA pengajuannya (yang Pending maupun Selesai)
    if (widget.role == Role.user) {
      return mockDatabase.where((e) => e.requesterRole == Role.user).toList();
    } 
    
    // --- KABID & KADIN ---
    // Hanya melihat yang sudah FINAL (Selesai). 
    // Yang masih pending/proses ada di menu Inbox.
    else {
      return mockDatabase.where((e) {
        // Cek status Final
        bool isFinal = (e.status == LeaveStatus.approved || e.status == LeaveStatus.rejected);
        if (!isFinal) return false;

        // Filter Kepemilikan (Milik sendiri ATAU Arsip verifikasi)
        bool isMyOwnRequest = (e.requesterRole == widget.role);
        bool isProcessedByMe = true; // Kabid/Kadin bisa lihat semua arsip kantor

        return isMyOwnRequest || isProcessedByMe;
      }).toList();
    }
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == Role.user ? "Riwayat & Status" : "Arsip Selesai"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: filteredList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Belum ada data", style: TextStyle(color: Colors.grey)),
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
                  "Ketuk untuk detail >", 
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.green[800], 
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
      case LeaveStatus.approved: color = Colors.green; text = "Disetujui"; break;
      case LeaveStatus.rejected: color = Colors.red; text = "Ditolak"; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}