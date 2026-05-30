import 'package:flutter/material.dart';
import '../../utils/app_styles.dart';

// --- IMPORT HALAMAN ---
import 'admin/create_match_screen.dart';
import 'judge/judge_login_screen.dart';
import 'display/tv_scoreboard.dart';
import 'match_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KURASH UZUL DIGITAL SCORING",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGrey,
      ),
      backgroundColor: AppColors.lightMint,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ic_kurash.png',
                width: 120,
                height: 120,
              ),

              const SizedBox(height: 15),

              const Text(
                "SISTEM PENILAIAN DIGITAL",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 40),

              // --- MENU 1: DAFTAR PERTANDINGAN (DIPROTEKSI PIN) ---
              _buildMenuButton(context, "Daftar Pertandingan", Icons.list_alt,
                  Colors.white, AppColors.darkGrey, () {
                // Sekarang butuh PIN juga
                _showPinDialog(context, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MatchListScreen()));
                });
              }),

              const SizedBox(height: 20),

              // --- MENU 2: ADMIN (DIPROTEKSI PIN) ---
              _buildMenuButton(context, "Operator / Admin", Icons.add_to_queue,
                  AppColors.steelBlue, Colors.white, () {
                _showPinDialog(context, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateMatchScreen()));
                });
              }),

              const SizedBox(height: 20),

              // --- MENU 3: JURI ---
              _buildMenuButton(
                  context,
                  "Juri (Smartphone)",
                  Icons.phone_android,
                  AppColors.emerald,
                  AppColors.darkGrey, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const JudgeLoginScreen()));
              }),

              const SizedBox(height: 20),

              // --- MENU 4: TV ---
              _buildMenuButton(context, "Layar TV & Kontrol", Icons.tv,
                  AppColors.darkGrey, Colors.white, () {
                _showIdInputDialog(context, "Tonton Skor & Timer", (id) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TvScoreboardScreen(matchId: id)));
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- POP UP PIN AKSES (DENGAN CALLBACK) ---
  // Parameter onSuccess dipanggil jika PIN benar
  void _showPinDialog(BuildContext context, VoidCallback onSuccess) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        void submitPin() {
          if (pinController.text == "2404") {
            Navigator.pop(ctx);
            onSuccess();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("PIN SALAH!"),
                backgroundColor: Colors.red));
            pinController.clear();
          }
        }

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock, color: AppColors.steelBlue),
              SizedBox(width: 10),
              Text("Akses Terbatas", style: TextStyle(color: AppColors.darkGrey)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Masukkan Kode Akses untuk melanjutkan."),
              const SizedBox(height: 15),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24, letterSpacing: 8, color: AppColors.darkGrey),
                decoration: InputDecoration(
                    hintText: "PIN",
                    hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.normal),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10)),
                onSubmitted: (_) => submitPin(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.steelBlue,
                    foregroundColor: Colors.white),
                onPressed: submitPin,
                child: const Text("Masuk"))
          ],
        );
      },
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon,
      Color bgColor, Color textColor, VoidCallback onTap) {
    return SizedBox(
      width: 300,
      height: 75,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          shadowColor: bgColor.withValues(alpha: 0.4),
        ),
        icon: Icon(icon, size: 32),
        label: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        onPressed: onTap,
      ),
    );
  }

  void _showIdInputDialog(
      BuildContext context, String title, Function(String) onConfirm) {
    showDialog(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();

          void submitId() {
            if (controller.text.isNotEmpty) {
              String matchId = controller.text.trim();
              Navigator.pop(ctx);
              onConfirm(matchId);
            }
          }

          return AlertDialog(
            title:
                Text(title, style: const TextStyle(color: AppColors.darkGrey)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Masukkan ID Match (3 Digit)"),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.darkGrey),
                  decoration: InputDecoration(
                      hintText: "Contoh: 105",
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.normal,
                          fontSize: 20),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.emerald, width: 2))),
                  onSubmitted: (_) => submitId(),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal",
                      style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.steelBlue,
                      foregroundColor: Colors.white),
                  onPressed: submitId,
                  child: const Text("Masuk")),
            ],
          );
        });
  }
}
