import 'package:flutter/material.dart';

class AppColors {
  // --- PALET DARI GAMBAR ANDA ---
  static const Color lightMint = Color(0xFFEFFFFB); // Teks / Highlight
  static const Color emerald   = Color(0xFF50D890); // UTAMA: Tombol / Slider / Aksen
  static const Color steelBlue = Color(0xFF1976D2); // KEDUA: Variasi Juri / Tombol Reset
  static const Color darkGrey  = Color(0xFF272727); // BACKGROUND: Latar TV / Kartu

  // --- SEMANTIK (PENGGUNAAN) ---
  
  // Background
  static const Color bgTv       = darkGrey;
  static const Color bgCanvas   = Color(0xFFF5F5F5); // Untuk HP Juri (biar terang di outdoor)
  static const Color cardTv     = Color(0xFF333333); // Sedikit lebih terang dari bgTv

  // Teks
  static const Color textLight  = lightMint;
  static const Color textDark   = darkGrey;
  static const Color textScore  = emerald; // Skor menyala hijau

  // Status
  static const Color success    = emerald;
  static const Color danger     = Color(0xFFD32F2F); // Merah tetap merah (universal)
  
  // Juri Colors (Variasi biar beda)
  static const Color judge1       = steelBlue;
  static const Color judge1Light  = Color(0xFFE3F2FD); // Blue 50
  static const Color judge2       = emerald;
  static const Color judge2Light  = Color(0xFFE8F5E9); // Green 50
  static const Color judge3       = Color(0xFFFF8F00); // Amber 800
  static const Color judge3Light  = Color(0xFFFFF8E1); // Amber 50
}