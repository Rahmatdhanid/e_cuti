import 'package:flutter/material.dart';
import '../models/leave_model.dart';
import 'create_leave_form.dart';
import 'riwayat_screen.dart';
import 'inbox_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Role role;
  final String userName;

  const DashboardScreen({super.key, required this.role, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Selamat Datang,", style: TextStyle(fontSize: 14)),
            Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: _getRoleColor(),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Menu Utama", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getRoleColor())
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  
                  // 1. TOMBOL CUTI BUAT SEMUA 
                  _buildMenuCard(
                    context,
                    title: "Buat Cuti",
                    icon: Icons.edit_document,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateLeaveForm(userRole: role)),
                      );
                    },
                  ),

                  // 2. TOMBOL INBOX (HANYA KABID & KADIN)
                  // Pegawai tidak perlu ini karena semua infonya masuk Riwayat
                  if (role != Role.user)
                    _buildMenuCard(
                      context,
                      title: "Inbox (Proses)",
                      icon: Icons.inbox,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InboxScreen(role: role)),
                        );
                      },
                    ),

                  // 3. TOMBOL RIWAYAT
                  _buildMenuCard(
                    context,
                    // Judul disesuaikan agar tidak bingung
                    title: role == Role.user ? "Riwayat & Status" : "Riwayat (Selesai)",
                    icon: Icons.history_edu,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RiwayatScreen(role: role, userName: userName)),
                      );
                    },
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor() {
    if (role == Role.user) return const Color(0xFF0D47A1);
    if (role == Role.kabid) return Colors.orange[800]!;
    return Colors.green[800]!;
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withOpacity(0.1)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}