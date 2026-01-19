import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data'; // <--- TAMBAHAN PENTING (Agar Uint8List tidak error)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; 
import 'package:printing/printing.dart'; 
import '../models/leave_model.dart';

class PrintLetterScreen extends StatelessWidget {
  final LeaveRequest request;
  const PrintLetterScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pratinjau & Unduh PDF")),
      body: PdfPreview(
        build: (format) => _generatePdf(format, request),
      ),
    );
  }

  // FUNGSI PEMBUAT DOKUMEN PDF
  Future<Uint8List> _generatePdf(PdfPageFormat format, LeaveRequest request) async {
    final pdf = pw.Document();

    // Mengambil font standar
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // --- HEADER TANGGAL ---
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Madiun, ${DateFormat('d MMMM yyyy').format(DateTime.now())}",
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Kepada Yth.\nBp. Kepala Dinas Komunikasi\ndan Informatika Kota Madiun\ndi Madiun",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // --- JUDUL ---
                pw.Center(
                  child: pw.Text(
                    "FORMULIR PERMINTAAN DAN PEMBERIAN CUTI",
                    style: pw.TextStyle(
                      font: fontBold, 
                      fontSize: 12, 
                      decoration: pw.TextDecoration.underline
                    ),
                  ),
                ),
                
                pw.SizedBox(height: 20),

                // --- I. DATA PEGAWAI ---
                _sectionHeader("I. DATA PEGAWAI", fontBold),
                _tableRow("Nama", request.nama.toUpperCase(), fontRegular),
                _tableRow("NIP", request.nip, fontRegular),
                _tableRow("Jabatan", request.jabatan, fontRegular),
                _tableRow("Masa Kerja", request.masaKerja, fontRegular),
                _tableRow("Unit Kerja", request.unitKerja, fontRegular),

                pw.SizedBox(height: 15),

                // --- II. JENIS CUTI ---
                _sectionHeader("II. JENIS CUTI", fontBold),
                 pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 150),
                  child: pw.Text("- ${request.jenisCuti}", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                ),

                pw.SizedBox(height: 15),

                // --- III. ALASAN CUTI ---
                _sectionHeader("III. ALASAN CUTI", fontBold),
                 pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 150),
                  child: pw.Text(request.alasan, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                ),

                pw.SizedBox(height: 15),

                // --- IV. LAMANYA CUTI ---
                _sectionHeader("IV. LAMANYA CUTI", fontBold),
                _tableRow("Mulai Tanggal", DateFormat('d MMMM yyyy').format(request.tanggalMulai), fontRegular),
                _tableRow("S/d Tanggal", DateFormat('d MMMM yyyy').format(request.tanggalSelesai), fontRegular),

                pw.SizedBox(height: 15),

                // --- V. ALAMAT SELAMA CUTI ---
                _sectionHeader("V. ALAMAT SELAMA CUTI", fontBold),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 150),
                  child: pw.Text(
                    "${request.alamatSelamaCuti}\nTelp: ${request.noTelp}", 
                    style: pw.TextStyle(font: fontRegular, fontSize: 10)
                  ),
                ),

                pw.SizedBox(height: 30),

                // --- TANDA TANGAN PEMOHON ---
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Hormat Saya,", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                        pw.SizedBox(height: 40),
                        pw.Text("(${request.nama.toUpperCase()})", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                        pw.Text("NIP. ${request.nip}", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // --- VI. KABID ---
                _sectionHeader("VI. PERTIMBANGAN ATASAN LANGSUNG", fontBold),
                pw.Text("DISETUJUI", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("SUB KOORDINATOR,", style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                        pw.SizedBox(height: 30),
                        pw.Text("(CHANDRA ROHMAN NUGRAHA, A.Md)", style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        pw.Text("NIP. 19860528 201101 1 009", style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // --- VII. KADIN ---
                _sectionHeader("VII. KEPUTUSAN PEJABAT BERWENANG", fontBold),
                pw.Text("DISETUJUI", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("KEPALA DINAS KOMUNIKASI DAN INFORMATIKA,", style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                        pw.SizedBox(height: 30),
                        pw.Text("(NOOR AFLAH, S.Kom)", style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        pw.Text("NIP. 19760907 200312 1 007", style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _sectionHeader(String title, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(title, style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _tableRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
          pw.Text(": ", style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10))),
        ],
      ),
    );
  }
}