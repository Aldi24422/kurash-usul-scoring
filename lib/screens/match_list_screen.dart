import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/match_model.dart';
import '../models/score_sheet_model.dart'; // Import Model Score
import '../utils/app_styles.dart';
import '../utils/format_utils.dart'; // Import FormatUtils
import '../services/pdf_service.dart'; // Import PDF Service

class MatchListScreen extends StatefulWidget {
  const MatchListScreen({super.key});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  final dbRef = FirebaseDatabase.instance.refFromURL(
      'https://kurash-usul-scoring-default-rtdb.asia-southeast1.firebasedatabase.app');

  final Set<String> _selectedMatchIds = {};

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  bool get _isSelectionMode => _selectedMatchIds.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteSelectedMatches() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Hapus Pertandingan?"),
              content: Text(
                  "Anda akan menghapus ${_selectedMatchIds.length} data pertandingan."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Batal")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      for (String id in _selectedMatchIds) {
                        await dbRef.child('matches/$id').remove();
                        await dbRef
                            .child('scores/$id')
                            .remove(); // Hapus juga skornya
                      }
                      setState(() {
                        _selectedMatchIds.clear();
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Data berhasil dihapus")));
                      }
                    },
                    child: const Text("Hapus")),
              ],
            ));
  }

  void _showEditDialog(MatchModel match) {
    final p1Controller = TextEditingController(text: match.participant1);
    final p2Controller = TextEditingController(text: match.participant2);
    final regionController = TextEditingController(text: match.region);
    String selectedCategory = match.category;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Match ${match.id}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: p1Controller,
                  decoration:
                      const InputDecoration(labelText: "Nama Peserta 1")),
              const SizedBox(height: 10),
              TextField(
                  controller: p2Controller,
                  decoration:
                      const InputDecoration(labelText: "Nama Peserta 2")),
              const SizedBox(height: 10),
              TextField(
                  controller: regionController,
                  decoration: const InputDecoration(labelText: "Kontingen")),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: const [
                  DropdownMenuItem(value: 'PA', child: Text("Putra (PA)")),
                  DropdownMenuItem(value: 'PI', child: Text("Putri (PI)")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    selectedCategory = val;
                  }
                },
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.black),
            onPressed: () async {
              await dbRef.child('matches/${match.id}').update({
                'participant_1': p1Controller.text.toUpperCase(),
                'participant_2': p2Controller.text.toUpperCase(),
                'region': regionController.text.toUpperCase(),
                'category': selectedCategory,
              });

              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  void _toggleSelection(String matchId) {
    setState(() {
      if (_selectedMatchIds.contains(matchId)) {
        _selectedMatchIds.remove(matchId);
      } else {
        _selectedMatchIds.add(matchId);
      }
    });
  }

  // --- LOGIKA TOMBOL PRINT (Download PDF) ---
  Future<void> _printMatchPDF(MatchModel match) async {
    // 1. Ambil Data Skor dari Firebase
    final snapshot = await dbRef.child('matches/${match.id}').get();

    if (snapshot.exists && snapshot.value != null) {
      final data = jsonDecode(jsonEncode(snapshot.value));

      ScoreSheet? j1, j2, j3;
      if (data['scores'] != null) {
        // PERBAIKAN: Menambahkan kurung kurawal {}
        if (data['scores']['judge_1'] != null) {
          j1 = ScoreSheet.fromJson(data['scores']['judge_1']);
        }
        if (data['scores']['judge_2'] != null) {
          j2 = ScoreSheet.fromJson(data['scores']['judge_2']);
        }
        if (data['scores']['judge_3'] != null) {
          j3 = ScoreSheet.fromJson(data['scores']['judge_3']);
        }
      }

      double grandTotal =
          (j1?.totalScore ?? 0) + (j2?.totalScore ?? 0) + (j3?.totalScore ?? 0);
      if (data['is_time_over'] == true) {
        grandTotal -= 1;
      }

      // 2. Generate PDF
      await PdfService().printMatchResult(match, j1, j2, j3, grandTotal);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data tidak ditemukan!")));
      }
    }
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _selectedMatchIds.clear()),
        ),
        title: Text("${_selectedMatchIds.length} Dipilih",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSelectedMatches,
          )
        ],
        bottom: _buildTabBar(),
      );
    }

    if (_isSearching) {
      return AppBar(
        backgroundColor: AppColors.darkGrey,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = "";
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: AppColors.emerald,
          decoration: const InputDecoration(
            hintText: "Cari nama atlet atau kota...",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.toUpperCase();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _searchQuery = "";
                  _searchController.clear();
                });
              },
            )
        ],
        bottom: _buildTabBar(),
      );
    }

    return AppBar(
      title: const Text("Daftar Pertandingan",
          style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.darkGrey,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = true),
        ),
      ],
      bottom: _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return const TabBar(
      indicatorColor: AppColors.emerald,
      labelColor: AppColors.emerald,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      tabs: [
        Tab(text: "PUTRA (PA)"),
        Tab(text: "PUTRI (PI)"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: Colors.grey.shade100,
        body: StreamBuilder<DatabaseEvent>(
          stream: dbRef.child('matches').onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error memuat data"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.emerald));
            }
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text("Belum ada pertandingan"));
            }

            final rawData =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<MatchModel> allMatches = [];

            rawData.forEach((key, value) {
              final json = jsonDecode(jsonEncode(value));
              allMatches.add(MatchModel.fromJson(json));
            });

            if (_searchQuery.isNotEmpty) {
              allMatches = allMatches.where((m) {
                return m.participant1.toUpperCase().contains(_searchQuery) ||
                    m.participant2.toUpperCase().contains(_searchQuery) ||
                    m.region.toUpperCase().contains(_searchQuery);
              }).toList();
            }

            allMatches.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            final listPutra =
                allMatches.where((m) => m.category == 'PA').toList();
            final listPutri =
                allMatches.where((m) => m.category == 'PI').toList();

            return TabBarView(
              children: [
                _buildList(listPutra),
                _buildList(listPutri),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<MatchModel> matches) {
    if (matches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text("Tidak ditemukan", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isSelected = _selectedMatchIds.contains(match.id);

        return InkWell(
          onLongPress: () => _toggleSelection(match.id),
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(match.id);
            } else {
              // Info singkat saat di tap
              // Clipboard.setData(ClipboardData(text: match.id));
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text("ID ${match.id} disalin!"), duration: const Duration(seconds: 1))
              // );
            }
          },
          child: Card(
            color: isSelected
                ? AppColors.emerald.withValues(alpha: 0.2)
                : Colors.white,
            elevation: isSelected ? 0 : 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? const BorderSide(color: AppColors.emerald, width: 2)
                    : BorderSide.none),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_isSelectionMode)
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppColors.emerald : Colors.grey,
                        size: 30,
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          const Text("ID",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10)),
                          Text(match.id,
                              style: const TextStyle(
                                  color: AppColors.emerald,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${FormatUtils.abbreviateName(match.participant1)} & ${FormatUtils.abbreviateName(match.participant2)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.shield,
                                size: 14, color: AppColors.steelBlue),
                            const SizedBox(width: 4),
                            Text(
                              match.region.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500),
                            ),
                            if (match.status == 'finished') ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 2),
                              const Text("Selesai",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_isSelectionMode)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- TOMBOL DOWNLOAD PDF (BARU) ---
                        IconButton(
                          icon: const Icon(Icons.print,
                              color: AppColors.steelBlue),
                          tooltip: "Download PDF",
                          onPressed: () => _printMatchPDF(match),
                        ),

                        // TOMBOL EDIT
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => _showEditDialog(match),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
