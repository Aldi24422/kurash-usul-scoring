import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scoring_provider.dart';
import '../../utils/app_styles.dart';
import 'scoring_form_screen.dart';

class JudgeLoginScreen extends StatefulWidget {
  const JudgeLoginScreen({super.key});

  @override
  State<JudgeLoginScreen> createState() => _JudgeLoginScreenState();
}

class _JudgeLoginScreenState extends State<JudgeLoginScreen> {
  final _matchIdController = TextEditingController();
  String _selectedJudge = 'judge_1';

  void _showConfirmationDialog(
      BuildContext context, dynamic match, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        // PERBAIKAN: const
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.steelBlue),
            SizedBox(width: 10),
            Text("Konfirmasi Penilaian"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Apakah Anda yakin akan menilai pertandingan ini?"),
            const Divider(height: 20, thickness: 1.5),
            _infoRow("Peserta 1:", match.participant1),
            _infoRow("Peserta 2:", match.participant2),
            const SizedBox(height: 10),
            _infoRow("Kontingen:", match.region),
            const SizedBox(height: 10),
            _infoRow("Kategori:", match.category),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: AppColors.darkGrey),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("YA, MULAI MENILAI",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    );
  }

  Future<void> _submitLogin(BuildContext context) async {
    final provider = Provider.of<ScoringProvider>(context, listen: false);
    if (provider.isLoading) return;

    String id = _matchIdController.text.trim();
    if (id.isEmpty) return;

    bool success = await provider.joinMatch(id, _selectedJudge);

    if (success && context.mounted) {
      _showConfirmationDialog(
          context, provider.currentMatch, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const ScoringFormScreen()),
        );
      });
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage.isEmpty
              ? "ID Tidak Ditemukan"
              : provider.errorMessage),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScoringProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Juri"),
        backgroundColor: AppColors.steelBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon Kurash Kustom
            Image.asset(
              'assets/images/ic_kurash.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _matchIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Masukkan ID Pertandingan (3 Digit)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              onSubmitted: (_) => _submitLogin(context),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              // PERBAIKAN: Gunakan initialValue
              initialValue: _selectedJudge,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Posisi Juri"),
              items: const [
                DropdownMenuItem(
                    value: 'judge_1',
                    child: Text("Juri 1 (Kerapihan & Ekspresi)")),
                DropdownMenuItem(
                    value: 'judge_2', child: Text("Juri 2 (Teknik)")),
                DropdownMenuItem(
                    value: 'judge_3', child: Text("Juri 3 (Jatuhan)")),
              ],
              onChanged: (val) => setState(() => _selectedJudge = val!),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.darkGrey),
                onPressed: provider.isLoading
                    ? null
                    : () => _submitLogin(context),
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("MASUK PENILAIAN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
