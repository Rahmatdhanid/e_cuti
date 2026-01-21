import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../data/mock_data.dart';

class CreateLeaveForm extends StatefulWidget {
  final Role userRole; 
  const CreateLeaveForm({super.key, required this.userRole});

  @override
  State<CreateLeaveForm> createState() => _CreateLeaveFormState();
}

class _CreateLeaveFormState extends State<CreateLeaveForm> {
  final _formKey = GlobalKey<FormState>();
  
 
  final _namaCtrl = TextEditingController(); 
  final _nipCtrl = TextEditingController(); 
  final _jabatanCtrl = TextEditingController(); 
  final _masaKerjaCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController(); 
  final _alamatCtrl = TextEditingController(); 
  final _telpCtrl = TextEditingController();

  String _selectedLeaveType = "Cuti Tahunan"; 
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulir Pengajuan"), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle("Data Pegawai"),
            _buildTextField("Nama", _namaCtrl),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: _buildTextField("NIP", _nipCtrl)), const SizedBox(width: 10), Expanded(child: _buildTextField("Jabatan", _jabatanCtrl))]),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: _buildTextField("Masa Kerja", _masaKerjaCtrl)), const SizedBox(width: 10), Expanded(child: _buildTextField("Unit Kerja", _unitCtrl))]),
            const SizedBox(height: 24),
            _sectionTitle("Detail Cuti"),
            DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              decoration: const InputDecoration(labelText: "Jenis Cuti"),
              items: ["Cuti Tahunan", "Cuti Besar", "Cuti Sakit", "Cuti Melahirkan", "Cuti Alasan Penting"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedLeaveType = v!),
            ),
            const SizedBox(height: 10),
            _buildTextField("Alasan Cuti", _alasanCtrl),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: _datePickerBtn("Mulai", _startDate, (d) => setState(() => _startDate = d))), const SizedBox(width: 10), Expanded(child: _datePickerBtn("Selesai", _endDate, (d) => setState(() => _endDate = d)))]),
            const SizedBox(height: 24),
            _sectionTitle("Kontak"),
            _buildTextField("Alamat", _alamatCtrl),
            const SizedBox(height: 10),
            _buildTextField("No. Telp", _telpCtrl),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                child: const Text("Kirim Permintaan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1))));
  Widget _buildTextField(String label, TextEditingController ctrl) => TextFormField(controller: ctrl, decoration: InputDecoration(labelText: label), validator: (v) => v!.isEmpty ? "Wajib diisi" : null);
  Widget _datePickerBtn(String label, DateTime date, Function(DateTime) onPicked) => InkWell(onTap: () async { final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2024), lastDate: DateTime(2030)); if (d != null) onPicked(d); }, child: InputDecorator(decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 16)), child: Text(DateFormat('dd MMM').format(date))));

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      
      // LOGIKA STATUS:
      // Pegawai -> PendingKabid
      // Kabid -> PendingKadin
      // Kadin -> PendingKadin
      LeaveStatus status = widget.userRole == Role.user ? LeaveStatus.pendingKabid : LeaveStatus.pendingKadin;

      mockDatabase.insert(0, LeaveRequest(
        id: DateTime.now().toString(),
        requesterRole: widget.userRole, // <-- SIMPAN ROLE PEMBUATNYA
        nama: _namaCtrl.text,
        nip: _nipCtrl.text,
        jabatan: _jabatanCtrl.text,
        masaKerja: _masaKerjaCtrl.text,
        unitKerja: _unitCtrl.text,
        jenisCuti: _selectedLeaveType,
        alasan: _alasanCtrl.text,
        tanggalMulai: _startDate,
        tanggalSelesai: _endDate,
        alamatSelamaCuti: _alamatCtrl.text,
        noTelp: _telpCtrl.text,
        status: status,
      ));
      
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permintaan cuti berhasil dikirim!")));
    }
  }
}