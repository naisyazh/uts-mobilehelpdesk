import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool isLoading = false;
  bool step2 = false; // false = input email, true = input password baru
  String? errorMsg;
  bool obscureNew = true;
  bool obscureConfirm = true;

  void checkEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => errorMsg = 'Email tidak boleh kosong');
      return;
    }
    if (!email.contains('@')) {
      setState(() => errorMsg = 'Format email tidak valid');
      return;
    }
    setState(() { isLoading = true; errorMsg = null; });

    // Cek apakah email terdaftar
    final db = await DBHelper.database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);

    setState(() => isLoading = false);

    if (result.isEmpty) {
      setState(() => errorMsg = 'Email tidak ditemukan di sistem');
      return;
    }

    setState(() => step2 = true);
  }

  void resetPassword() async {
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => errorMsg = 'Password tidak boleh kosong');
      return;
    }
    if (newPass.length < 6) {
      setState(() => errorMsg = 'Password minimal 6 karakter');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => errorMsg = 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() { isLoading = true; errorMsg = null; });

    final success = await DBHelper.resetPassword(emailController.text.trim(), newPass);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil direset!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      setState(() => errorMsg = 'Gagal mereset password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'),
          backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              children: [
                _stepCircle(1, step2),
                Expanded(child: Divider(color: step2 ? Colors.blue : Colors.grey)),
                _stepCircle(2, false, active: step2),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Verifikasi Email', style: TextStyle(
                    fontSize: 12, color: step2 ? Colors.blue : Colors.grey)),
                Text('Password Baru', style: TextStyle(
                    fontSize: 12, color: step2 ? Colors.blue : Colors.grey)),
              ],
            ),
            const SizedBox(height: 24),

            if (errorMsg != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              ),

            if (!step2) ...[
              const Text('Masukkan email yang terdaftar:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : checkEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verifikasi Email'),
                ),
              ),
            ] else ...[
              const Text('Buat password baru:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Password Baru', prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru', prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Reset Password'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stepCircle(int step, bool done, {bool active = false}) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: done || active ? Colors.blue : Colors.grey.shade300,
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : Text('$step', style: TextStyle(color: done || active ? Colors.white : Colors.grey)),
    );
  }
}