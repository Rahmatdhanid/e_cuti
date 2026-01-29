enum LeaveStatus { pendingKabid, pendingKadin, approved, rejected }
enum Role { user, kabid, kadin }

class LeaveRequest {
  String id;
  Role requesterRole; 

  // DATA PEGAWAI
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

  // --- DATA PENYETUJU ---
  String? kabidName; // Nama Kabid yang ACC
  String? kadinName; // Nama Kadin yang ACC

  LeaveRequest({
    required this.id,
    required this.requesterRole,
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
    this.kabidName, 
    this.kadinName, 
  });
}