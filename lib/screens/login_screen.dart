import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../models/leave_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;

 
  String _formatNameFromEmail(String email) {
    try {
      
      String rawName = email.split('@')[0];
      
      
      rawName = rawName.replaceAll('kabid.', '').replaceAll('kadin.', '');

      
      String cleanName = rawName.replaceAll('.', ' ').replaceAll('_', ' ');
      
      
      List<String> words = cleanName.split(' ');
      String formattedName = words.map((word) {
        if (word.isEmpty) return "";
        return "${word[0].toUpperCase()}${word.substring(1)}";
      }).join(' ');

      return formattedName;
    } catch (e) {
      return "Pengguna";
    }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1));

    String email = _emailCtrl.text.toLowerCase().trim();
    Role role;
    String displayTitle;

   
    String realName = _formatNameFromEmail(email);

    
    if (email.contains('kabid')) {
      role = Role.kabid;
      displayTitle = "Bpk/Ibu $realName (Kabid)";
    } else if (email.contains('kadin') || email.contains('kepala')) {
      role = Role.kadin;
      displayTitle = "Bpk/Ibu $realName (Kadin)";
    } else {
      
      role = Role.user;
      displayTitle = "Sdr. $realName";
    }

   
    if (_passCtrl.text.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password wajib diisi")),
        );
        return;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            role: role, 
            userName: displayTitle
          )
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.assignment_turned_in, size: 80, color: Color(0xFF0D47A1)),
                const SizedBox(height: 20),
                const Text(
                  "E-CUTI",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                const Text(
                  "Dinas Komunikasi & Informatika\nKota Madiun", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.grey)
                ),
                const SizedBox(height: 50),
                
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email Kedinasan", 
                    prefixIcon: Icon(Icons.email_outlined), 
                    hintText: "nama@madiun.go.id"
                  ),
                  validator: (v) => v!.isEmpty || !v.contains('@') ? "Email tidak valid" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Kata Sandi",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("MASUK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 20),
               
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50], 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100)
                  ),
                  child: const Column(
                    children: [
                      Text("Contoh Login :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("• Pegawai: nama_anda@madiun.go.id", style: TextStyle(fontSize: 12)),
                      Text("• Kabid: kabid@madiun.go.id", style: TextStyle(fontSize: 12)),
                      Text("• Kadin: kadin@madiun.go.id", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}