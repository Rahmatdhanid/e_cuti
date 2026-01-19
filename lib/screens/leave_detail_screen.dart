import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import 'print_letter_screen.dart'; // Jangan lupa import file print tadi

class LeaveDetailScreen extends StatefulWidget {
  final LeaveRequest request;
  final Role userRole;

  const LeaveDetailScreen({super.key, required this.request, required this.userRole});

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  
  void _processRequest(bool approved) {
    setState(() {
      if (!approved) {
        widget.request.status = LeaveStatus.rejected;
      } else {
        if (widget.userRole == Role.kabid) {
          widget.request.status = LeaveStatus.pendingKadin;
        } else if (widget.userRole == Role.kadin) {
          widget.request.status = LeaveStatus.approved;
        }
      }
    });
    Navigator.pop(context); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(approved ? "Pengajuan disetujui" : "Pengajuan ditolak")),
    );
  }

  bool get _canAction {
    if (widget.userRole == Role.kabid && widget.request.status == LeaveStatus.pendingKabid) return true;
    if (widget.userRole == Role.kadin && widget.request.status == LeaveStatus.pendingKadin) return true;
    return false;
  }

  // Cek apakah sudah disetujui sepenuhnya
  bool get _isApproved {
    return widget.request.status == LeaveStatus.approved;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Permintaan Cuti"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildStatusBanner()),
            const SizedBox(height: 24),

            _sectionHeader("Data Pegawai"),
            _detailRow("Nama Lengkap", widget.request.nama),
            _detailRow("NIP", widget.request.nip),
            _detailRow("Jabatan", widget.request.jabatan),
            _detailRow("Unit Kerja", widget.request.unitKerja),
            _detailRow("Masa Kerja", widget.request.masaKerja),

            const SizedBox(height: 24),
            _sectionHeader("Detail Cuti"),
            _detailRow("Jenis Cuti", widget.request.jenisCuti),
            _detailRow("Alasan", widget.request.alasan),
            _detailRow("Tanggal Mulai", DateFormat('dd MMMM yyyy').format(widget.request.tanggalMulai)),
            _detailRow("Tanggal Selesai", DateFormat('dd MMMM yyyy').format(widget.request.tanggalSelesai)),
            
            const SizedBox(height: 24),
            _sectionHeader("Kontak Selama Cuti"),
            _detailRow("Alamat", widget.request.alamatSelamaCuti),
            _detailRow("No. Telepon", widget.request.noTelp),

            const SizedBox(height: 40),
            
            // --- TOMBOL AKSI VERIFIKASI (Untuk Atasan) ---
            if (_canAction) 
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _processRequest(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("TOLAK"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _processRequest(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("SETUJUI"),
                    ),
                  ),
                ],
              ),

            // --- TOMBOL CETAK SURAT (Muncul Jika Sudah Disetujui) ---
            if (_isApproved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrintLetterScreen(request: widget.request),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text("CETAK SURAT IZIN (PDF)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                  ),
                ),
              ),
              
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color color;
    String text;
    IconData icon;
    
    switch (widget.request.status) {
      case LeaveStatus.pendingKabid:
        color = Colors.orange; text = "Menunggu Verifikasi Kabid"; icon = Icons.hourglass_empty; break;
      case LeaveStatus.pendingKadin:
        color = Colors.blue; text = "Menunggu Persetujuan Kadin"; icon = Icons.hourglass_top; break;
      case LeaveStatus.approved:
        color = Colors.green; text = "Permohonan Disetujui"; icon = Icons.check_circle; break;
      case LeaveStatus.rejected:
        color = Colors.red; text = "Permohonan Ditolak"; icon = Icons.cancel; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87))),
        ],
      ),
    );
  }
}