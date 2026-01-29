import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import 'print_letter_screen.dart';

class LeaveDetailScreen extends StatefulWidget {
  final LeaveRequest request;
  final Role userRole;
  final String userName; 

  const LeaveDetailScreen({
    super.key, 
    required this.request, 
    required this.userRole,
    required this.userName,
  });

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
          widget.request.kabidName = widget.userName; 
        } else if (widget.userRole == Role.kadin) {
          widget.request.status = LeaveStatus.approved;
          widget.request.kadinName = widget.userName; 
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

  bool get _isApproved => widget.request.status == LeaveStatus.approved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Permintaan Cuti")),
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
            
           
            if (_canAction) 
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _processRequest(false),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("TOLAK"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _processRequest(true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text("SETUJUI"),
                    ),
                  ),
                ],
              ),

            
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                ),
              ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    String text = "Status: ${widget.request.status.name}";
    Color color = Colors.grey;
    IconData icon = Icons.info;

    switch (widget.request.status) {
      case LeaveStatus.pendingKabid:
        text = "Menunggu Verifikasi Kabid"; color = Colors.orange; icon = Icons.hourglass_empty; break;
      case LeaveStatus.pendingKadin:
        text = "Menunggu Persetujuan Kadin"; color = Colors.blue; icon = Icons.hourglass_top; break;
      case LeaveStatus.approved:
        text = "Permohonan Disetujui"; color = Colors.green; icon = Icons.check_circle; break;
      case LeaveStatus.rejected:
        text = "Permohonan Ditolak"; color = Colors.red; icon = Icons.cancel; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)), const Divider()]));
  Widget _detailRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 130, child: Text(label, style: TextStyle(color: Colors.grey[700]))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)))]));
}