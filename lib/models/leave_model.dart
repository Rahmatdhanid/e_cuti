enum LeaveStatus { pendingKabid, pendingKadin, approved, rejected }
enum Role { user, kabid, kadin }

class LeaveRequest {
  String id;
  
  // Menyimpan role si pembuat pengajuan
  final Role requesterRole; 

  String nama;
  String nip;
  String jabatan;
  String masaKerja;
  String unitKerja;
  String jenisCuti;
  String alasan;
  DateTime tanggalMulai;
  DateTime tanggalSelesai;
  String alamatSelamaCuti;
  String noTelp;
  LeaveStatus status;

  LeaveRequest({
    required this.id,
    required this.requesterRole, // Wajib diisi
    required this.nama,
    required this.nip,
    required this.jabatan,
    required this.masaKerja,
    required this.unitKerja,
    required this.jenisCuti,
    required this.alasan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alamatSelamaCuti,
    required this.noTelp,
    this.status = LeaveStatus.pendingKabid,
  });
}