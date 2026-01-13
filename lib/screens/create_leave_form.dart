import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../data/mock_data.dart';

class CreateLeaveForm extends StatefulWidget {
  const CreateLeaveForm({super.key});

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
  void dispose() {
    
    _namaCtrl.dispose();
    _nipCtrl.dispose();
    _jabatanCtrl.dispose();
    _masaKerjaCtrl.dispose();
    _unitCtrl.dispose();
    _alasanCtrl.dispose();
    _alamatCtrl.dispose();
    _telpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulir Pengajuan"), 
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle("Data Pegawai"),
            _buildTextField("Nama Lengkap", _namaCtrl),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("NIP", _nipCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("Jabatan", _jabatanCtrl)),
              ],
            ),
             const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Masa Kerja", _masaKerjaCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("Unit Kerja", _unitCtrl)),
              ],
            ),

            const SizedBox(height: 24),
            _sectionTitle("Detail Cuti"),
            DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              decoration: const InputDecoration(
                labelText: "Jenis Cuti",
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: ["Cuti Tahunan", "Cuti Besar", "Cuti Sakit", "Cuti Melahirkan", "Cuti Alasan Penting"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedLeaveType = v!),
            ),
            const SizedBox(height: 12),
            _buildTextField("Alasan Cuti", _alasanCtrl, maxLines: 3),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _datePickerBtn("Mulai", _startDate, (d) => setState(() => _startDate = d))),
                const SizedBox(width: 12),
                Expanded(child: _datePickerBtn("Selesai", _endDate, (d) => setState(() => _endDate = d))),
              ],
            ),

            const SizedBox(height: 24),
            _sectionTitle("Alamat Selama Cuti"),
            _buildTextField("Alamat Lengkap", _alamatCtrl, maxLines: 2),
            const SizedBox(height: 12),
            _buildTextField("No. Telepon", _telpCtrl, keyboardType: TextInputType.phone),

            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text("Kirim Permintaan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title, 
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 18, 
          color: Color(0xFF0D47A1)
        )
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (v) => v!.trim().isEmpty ? "$label wajib diisi" : null,
    );
  }

  Widget _datePickerBtn(String label, DateTime date, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );
        if (d != null) onPicked(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label, 
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(date)),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      
      mockDatabase.insert(0, LeaveRequest(
        id: DateTime.now().toString(),
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
      ));

      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permintaan cuti berhasil dikirim!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}