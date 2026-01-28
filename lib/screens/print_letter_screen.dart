import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
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
      appBar: AppBar(title: const Text("Pratinjau Cetak Formulir")),
      body: PdfPreview(
        build: (format) => _generatePdf(format, request),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, LeaveRequest request) async {
    final pdf = pw.Document();
    
    // Kita gunakan font standar birokrasi (Times New Roman atau OpenSans)
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    // Data Penyetuju (Dinamis dari sistem login sebelumnya)
    String namaKabid = request.kabidName ?? "........................."; 
    String namaKadin = request.kadinName ?? ".........................";
    
    // NIP Otomatis (Simulasi)
    String nipKabid = namaKabid.contains("Chandra") ? "19860528 201101 1 009" : ".........................";
    String nipKadin = namaKadin.contains("Noor") ? "19760907 200312 1 007" : ".........................";

    // Style umum untuk teks tabel
    final styleText = pw.TextStyle(font: fontRegular, fontSize: 8);
    final styleBold = pw.TextStyle(font: fontBold, fontSize: 8, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.legal, // Ukuran Legal/F4 biasanya untuk surat dinas
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER KANAN ---
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Madiun, ${DateFormat('d MMMM yyyy').format(DateTime.now())}", style: styleText),
                    pw.SizedBox(height: 4),
                    pw.Text("Kepada", style: styleText),
                    pw.Text("Yth. Bp. Kepala Dinas Komunikasi", style: styleText),
                    pw.Text("dan Informatika Kota Madiun", style: styleText),
                    pw.Text("di Madiun", style: styleText),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 10),

              // --- JUDUL TENGAH ---
              pw.Center(
                child: pw.Text(
                  "FORMULIR PERMINTAAN DAN PEMBERIAN CUTI",
                  style: pw.TextStyle(font: fontBold, fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),

              pw.SizedBox(height: 10),

              // ============================================================
              // I. DATA PEGAWAI (TABEL)
              // ============================================================
              _buildSectionTitle("I. DATA PEGAWAI", styleBold),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2), // Label Nama
                  1: const pw.FlexColumnWidth(4), // Isi Nama
                  2: const pw.FlexColumnWidth(2), // Label NIP
                  3: const pw.FlexColumnWidth(3), // Isi NIP
                },
                children: [
                  pw.TableRow(children: [
                    _cell("Nama", styleText), _cell(request.nama.toUpperCase(), styleText),
                    _cell("NIP", styleText), _cell(request.nip, styleText),
                  ]),
                  pw.TableRow(children: [
                    _cell("Jabatan", styleText), _cell(request.jabatan, styleText),
                    _cell("Masa Kerja", styleText), _cell(request.masaKerja, styleText),
                  ]),
                  pw.TableRow(children: [
                    _cell("Unit Kerja", styleText), 
                    // Unit kerja di-merge kolomnya (colspan) agar panjang
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(request.unitKerja, style: styleText)
                    ),
                    pw.Container(), // Placeholder karena colspan manual
                    pw.Container(), // Placeholder
                  ]),
                ],
              ),

              pw.SizedBox(height: 5),

              // ============================================================
              // II. JENIS CUTI YANG DIAMBIL (TABEL CHECKLIST)
              // ============================================================
              _buildSectionTitle("II. JENIS CUTI YANG DIAMBIL", styleBold),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(children: [
                    _checkCell("1. Cuti Tahunan", request.jenisCuti == "Cuti Tahunan", styleText),
                    _checkCell("2. Cuti Besar", request.jenisCuti == "Cuti Besar", styleText),
                    _checkCell("3. Cuti Sakit", request.jenisCuti == "Cuti Sakit", styleText),
                  ]),
                   pw.TableRow(children: [
                    _checkCell("4. Cuti Melahirkan", request.jenisCuti == "Cuti Melahirkan", styleText),
                    _checkCell("5. Cuti Alasan Penting", request.jenisCuti == "Cuti Alasan Penting", styleText),
                    _checkCell("6. Cuti di Luar Tanggungan", false, styleText),
                  ]),
                ]
              ),

              pw.SizedBox(height: 5),

              // ============================================================
              // III. ALASAN CUTI
              // ============================================================
              _buildSectionTitle("III. ALASAN CUTI", styleBold),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(request.alasan, style: styleText)
                    )
                  ])
                ]
              ),

              pw.SizedBox(height: 5),

              // ============================================================
              // IV. LAMANYA CUTI
              // ============================================================
              _buildSectionTitle("IV. LAMANYA CUTI", styleBold),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(60), // Selama
                  1: const pw.FixedColumnWidth(100), // Value Selama
                  2: const pw.FixedColumnWidth(80), // Mulai
                  3: const pw.FlexColumnWidth(1), // Value Mulai
                  4: const pw.FixedColumnWidth(30), // s/d
                  5: const pw.FlexColumnWidth(1), // Value s/d
                },
                children: [
                  pw.TableRow(children: [
                    _cell("Selama", styleText),
                    _cell("${request.tanggalSelesai.difference(request.tanggalMulai).inDays + 1} hari", styleText),
                    _cell("Mulai tanggal", styleText),
                    _cell(DateFormat('dd MMM yyyy').format(request.tanggalMulai), styleText),
                    _cell("s/d", styleText),
                    _cell(DateFormat('dd MMM yyyy').format(request.tanggalSelesai), styleText),
                  ])
                ]
              ),

              pw.SizedBox(height: 5),

              // ============================================================
              // VI. ALAMAT & TANDA TANGAN PEMOHON
              // ============================================================
              _buildSectionTitle("VI. ALAMAT SELAMA MENJALANI CUTI", styleBold),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Kiri: Alamat
                    pw.Expanded(
                      flex: 6,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 0.5))),
                        height: 60,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(request.alamatSelamaCuti, style: styleText),
                            pw.SizedBox(height: 4),
                            pw.Text("TELP: ${request.noTelp}", style: styleText),
                          ]
                        )
                      ),
                    ),
                    // Kanan: TTD Pemohon
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        height: 60,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text("Hormat Saya,", style: styleText),
                            pw.Spacer(),
                            pw.Text("(${request.nama.toUpperCase()})", style: styleBold),
                            pw.Text("NIP. ${request.nip}", style: styleText),
                          ]
                        )
                      ),
                    ),
                  ]
                )
              ),

              pw.SizedBox(height: 5),

              // ============================================================
              // VII. PERTIMBANGAN ATASAN (KABID)
              // ============================================================
              _buildSectionTitle("VII. PERTIMBANGAN ATASAN LANGSUNG", styleBold),
              _buildApprovalTable(
                fontRegular, fontBold, styleText, styleBold,
                signerTitle: "SUBKOORDINATOR PENGELOLAAN\nINFRASTRUKTUR DAN APLIKASI",
                signerName: namaKabid,
                signerNip: nipKabid,
                isApproved: true, // Asumsi jika diprint berarti sudah disetujui
              ),

              pw.SizedBox(height: 5),

              // ============================================================
              // VIII. KEPUTUSAN PEJABAT (KADIN)
              // ============================================================
              _buildSectionTitle("VIII. KEPUTUSAN PEJABAT BERWENANG", styleBold),
              _buildApprovalTable(
                fontRegular, fontBold, styleText, styleBold,
                signerTitle: "KEPALA DINAS KOMUNIKASI DAN\nINFORMATIKA",
                signerName: namaKadin,
                signerNip: nipKadin,
                isApproved: true,
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  // --- WIDGET BANTUAN (HELPER) AGAR KODE RAPI ---

  pw.Widget _buildSectionTitle(String title, pw.TextStyle style) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: pw.Text(title, style: style),
    );
  }

  pw.Widget _cell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: style),
    );
  }

  // Kotak Checkbox (V)
  pw.Widget _checkCell(String label, bool checked, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Row(
        children: [
          pw.Container(
            width: 10, height: 10,
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
            child: checked ? pw.Center(child: pw.Text("V", style: pw.TextStyle(fontSize: 8))) : null,
          ),
          pw.SizedBox(width: 4),
          pw.Text(label, style: style),
        ]
      ),
    );
  }

  // Tabel Approval (Persetujuan) yang kompleks
  pw.Widget _buildApprovalTable(
    pw.Font fontReg, pw.Font fontBold, pw.TextStyle styleNormal, pw.TextStyle styleBold,
    {required String signerTitle, required String signerName, required String signerNip, required bool isApproved}
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // Disetujui
        1: const pw.FlexColumnWidth(1), // Perubahan
        2: const pw.FlexColumnWidth(1), // Ditangguhkan
        3: const pw.FlexColumnWidth(2), // TTD
      },
      children: [
        // Header Row
        pw.TableRow(
          children: [
            _centerText("DISETUJUI", styleNormal),
            _centerText("PERUBAHAN", styleNormal),
            _centerText("DITANGGUHKAN", styleNormal),
            _centerText("TIDAK DISETUJUI", styleNormal),
          ]
        ),
        // Content Row
        pw.TableRow(
          children: [
            // Kolom Disetujui (Ada Centang)
            pw.Container(height: 60, child: isApproved ? pw.Center(child: pw.Text("V", style: styleBold)) : null),
            // Kolom Lain Kosong
            pw.Container(height: 60), 
            pw.Container(height: 60),
            // Kolom Tanda Tangan (Span vertikal visual)
            pw.Container(
              height: 60,
              padding: const pw.EdgeInsets.all(4),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(signerTitle, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, fontSize: 7)),
                  pw.Spacer(),
                  pw.Text("($signerName)", style: pw.TextStyle(font: fontBold, fontSize: 8, decoration: pw.TextDecoration.underline)),
                  pw.Text("NIP. $signerNip", style: pw.TextStyle(font: fontReg, fontSize: 8)),
                ]
              )
            ),
          ]
        )
      ]
    );
  }

  pw.Widget _centerText(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Center(child: pw.Text(text, style: style, textAlign: pw.TextAlign.center)),
    );
  }
}