#!/bin/bash

# Format tanggal dan waktu sesuai keinginan Anda.
# %H: Jam (24-jam), %M: Menit, %A: Nama hari penuh, %d: Tanggal, %B: Nama bulan penuh, %Y: Tahun
CURRENT_DATETIME=$(date +"Jam: %H:%M | Hari: %A, %d %B %Y")

# Kirim notifikasi menggunakan dunstify (perintah untuk dunst)
# -a: Aplikasi pengirim (opsional)
# -t: Durasi notifikasi dalam milidetik (misal: 3000ms = 3 detik)
dunstify "Waktu Saat Ini" "$CURRENT_DATETIME" -a "Hyprland" -t 3000
