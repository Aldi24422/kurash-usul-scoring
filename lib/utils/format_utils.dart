class FormatUtils {
  
  /// Fungsi untuk menyingkat nama panjang
  /// Contoh: "Anggoro Cahyo Budi Santoso" -> "Anggoro Cahyo B. S."
  static String abbreviateName(String fullName) {
    if (fullName.isEmpty) return "";

    // Hapus spasi berlebih di awal/akhir dan pisahkan per kata
    List<String> words = fullName.trim().split(RegExp(r'\s+'));

    // Jika hanya 1 atau 2 kata, kembalikan aslinya (tidak perlu disingkat)
    if (words.length <= 2) {
      return fullName;
    }

    // Ambil 2 kata pertama secara utuh
    String result = "${words[0]} ${words[1]}";

    // Sisanya (kata ke-3 dst) ambil huruf depannya saja + titik
    for (int i = 2; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        result += " ${words[i][0].toUpperCase()}.";
      }
    }

    return result;
  }
}