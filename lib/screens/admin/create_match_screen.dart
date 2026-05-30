import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/match_provider.dart';
import '../../utils/app_styles.dart';
import '../../models/match_model.dart';
import '../../utils/excel_helper.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _p1Controller = TextEditingController();
  final TextEditingController _p2Controller = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  String _selectedRegion = "";
  String _selectedCategory = 'PA';

  static const List<String> _jatimCities = [
    "KOTA SURABAYA",
    "KABUPATEN SIDOARJO",
    "KABUPATEN GRESIK",
    "KABUPATEN MOJOKERTO",
    "KOTA MOJOKERTO",
    "KABUPATEN LAMONGAN",
    "KABUPATEN TUBAN",
    "KABUPATEN BOJONEGORO",
    "KABUPATEN JOMBANG",
    "KABUPATEN NGANJUK",
    "KABUPATEN MADIUN",
    "KOTA MADIUN",
    "KABUPATEN MAGETAN",
    "KABUPATEN NGAWI",
    "KABUPATEN PONOROGO",
    "KABUPATEN PACITAN",
    "KABUPATEN KEDIRI",
    "KOTA KEDIRI",
    "KABUPATEN TRENGGALEK",
    "KABUPATEN TULUNGAGUNG",
    "KABUPATEN BLITAR",
    "KOTA BLITAR",
    "KABUPATEN MALANG",
    "KOTA MALANG",
    "KOTA BATU",
    "KABUPATEN PASURUAN",
    "KOTA PASURUAN",
    "KABUPATEN PROBOLINGGO",
    "KOTA PROBOLINGGO",
    "KABUPATEN LUMAJANG",
    "KABUPATEN JEMBER",
    "KABUPATEN BONDOWOSO",
    "KABUPATEN SITUBONDO",
    "KABUPATEN BANYUWANGI",
    "KABUPATEN BANGKALAN",
    "KABUPATEN SAMPANG",
    "KABUPATEN PAMEKASAN",
    "KABUPATEN SUMENEP",
  ];

  void _clearForm() {
    setState(() {
      _p1Controller.clear();
      _p2Controller.clear();
      _regionController.clear();
      _selectedRegion = "";
    });
    FocusScope.of(context).unfocus();
  }

  // --- LOGIKA IMPORT EXCEL ---
  Future<void> _pickAndImportExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Membaca file Excel... Mohon tunggu."),
            duration: Duration(seconds: 2)));

        final bytes = result.files.first.bytes;
        if (bytes != null) {
          List<MatchModel> importedMatches =
              await ExcelHelper.parseMatchExcel(bytes);

          if (importedMatches.isNotEmpty) {
            if (!mounted) return;
            _showConfirmationDialog(importedMatches);
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("File Excel kosong atau format salah!"),
                backgroundColor: Colors.red));
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Gagal mengambil file: $e"),
            backgroundColor: Colors.red));
      }
    }
  }

  void _showConfirmationDialog(List<MatchModel> matches) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Import ${matches.length} Pertandingan?"),
              content: SizedBox(
                height: 200,
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Preview 3 Data Pertama:"),
                    const SizedBox(height: 10),
                    ...matches.take(3).map((m) => Text(
                        "- ${m.participant1} & ${m.participant2} (${m.category})")),
                    if (matches.length > 3) const Text("... dan lainnya."),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Batal")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.black),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final provider =
                          Provider.of<MatchProvider>(context, listen: false);
                      int count = await provider.importMatches(matches);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Sukses mengimport $count pertandingan!"),
                            backgroundColor: AppColors.success));
                      }
                    },
                    child: const Text("Ya, Import Semua"))
              ],
            ));
  }

  void _showTemplateInfo() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Format Excel"),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Pastikan urutan kolom Excel Anda seperti ini (Tanpa Header):"),
                  SizedBox(height: 10),
                  Text("Kolom A: ID Match (Boleh Kosong/Auto)"),
                  Text("Kolom B: Nama Atlet 1 (Wajib)"),
                  Text("Kolom C: Nama Atlet 2 (Wajib)"),
                  Text("Kolom D: Kategori (PA / PI)"),
                  Text("Kolom E: Kontingen / Kota"),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Oke, Mengerti"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MatchProvider>(context);

    final dbRef = FirebaseDatabase.instance.refFromURL(
        'https://kurash-usul-scoring-default-rtdb.asia-southeast1.firebasedatabase.app');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Operator Pertandingan"),
        backgroundColor: AppColors.steelBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: "Format Excel",
            onPressed: _showTemplateInfo,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- BAGIAN ATAS: FORM INPUT ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TOMBOL IMPORT EXCEL ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        icon: const Icon(Icons.file_upload),
                        label: const Text("IMPORT DARI EXCEL (.xlsx)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed:
                            provider.isLoading ? null : _pickAndImportExcel,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const Center(
                        child: Text("ATAU INPUT MANUAL",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),

                    // Asal Daerah
                    const Text("Asal Daerah / Kontingen",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return _jatimCities.where((String option) {
                          return option
                              .contains(textEditingValue.text.toUpperCase());
                        });
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _selectedRegion = selection;
                          _regionController.text = selection;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        if (_regionController.text !=
                            textEditingController.text) {
                          textEditingController.text = _regionController.text;
                        }
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                              hintText: "Ketik nama kota...",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_city),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0)),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Wajib diisi";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            _selectedRegion = val.toUpperCase();
                            _regionController.text = val.toUpperCase();
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    // Kategori
                    const Text("Kategori",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.steelBlue.withValues(alpha: 0.2);
                            }
                            return null;
                          }),
                          iconColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.steelBlue;
                            }
                            return Colors.grey;
                          }),
                        ),
                        segments: const [
                          ButtonSegment<String>(
                              value: 'PA',
                              label: Text('Putra (PA)'),
                              icon: Icon(Icons.male)),
                          ButtonSegment<String>(
                              value: 'PI',
                              label: Text('Putri (PI)'),
                              icon: Icon(Icons.female)),
                        ],
                        selected: {_selectedCategory},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(
                              () => _selectedCategory = newSelection.first);
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Nama Atlet
                    const Text("Nama Atlet",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _p1Controller,
                            decoration: const InputDecoration(
                                labelText: "Peserta 1",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person)),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Wajib";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _p2Controller,
                            decoration: const InputDecoration(
                                labelText: "Peserta 2",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline)),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Wajib";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // TOMBOL SIMPAN MANUAL
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: AppColors.darkGrey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        icon: const Icon(Icons.save_as),
                        label: const Text("BUAT PERTANDINGAN & MATCH ID",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  String finalRegion = _selectedRegion.isEmpty
                                      ? _regionController.text
                                      : _selectedRegion;
                                  if (finalRegion.isEmpty) {
                                    finalRegion = "UMUM";
                                  }

                                  bool success = await provider.createNewMatch(
                                    p1: _p1Controller.text.toUpperCase(),
                                    p2: _p2Controller.text.toUpperCase(),
                                    category: _selectedCategory,
                                    region: finalRegion,
                                  );

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "DATA TERSIMPAN! Silakan input peserta berikutnya."),
                                        backgroundColor: AppColors.success,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    _clearForm();
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(thickness: 5, color: Colors.grey, height: 5),

          // --- LIST BAWAH ---
          SizedBox(
            height: 170,
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey.shade200,
                    child: const Text("RIWAYAT PEMBUATAN (Terbaru)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12)),
                  ),
                  Expanded(
                    child: StreamBuilder<DatabaseEvent>(
                      stream: dbRef.child('matches').limitToLast(20).onValue,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data!.snapshot.value == null) {
                          return const Center(
                              child: Text("Belum ada data baru"));
                        }

                        final rawData = snapshot.data!.snapshot.value
                            as Map<dynamic, dynamic>;
                        List<MatchModel> recentMatches = [];
                        rawData.forEach((key, value) {
                          final json = jsonDecode(jsonEncode(value));
                          recentMatches.add(MatchModel.fromJson(json));
                        });

                        recentMatches
                            .sort((a, b) => b.timestamp.compareTo(a.timestamp));

                        return ListView.separated(
                          padding: const EdgeInsets.all(0),
                          itemCount: recentMatches.length,
                          separatorBuilder: (ctx, i) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final m = recentMatches[index];
                            return Container(
                              color: Colors.white,
                              child: ListTile(
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -4),
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: AppColors.darkGrey,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(m.id,
                                      style: const TextStyle(
                                          color: AppColors.emerald,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                                title: Text(
                                    "${m.participant1} & ${m.participant2}",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text("${m.category} - ${m.region}",
                                    style: const TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.check_circle,
                                    color: Colors.green, size: 14),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
