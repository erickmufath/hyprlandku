echo "--------------------------------------------------------"
read -p    "->] Install Chaotic-AUR [Y/n] : " chaur
echo -e "--------------------------------------------------------"
case $chaur in
""|[Yy]*)
# Teks yang ingin ditambahkan
block_to_add_chaotic=$(cat <<EOF
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
)
# File konfigurasi yang ditarget
config_file_chaotic="/etc/pacman.conf"
# Cek apakah blok sudah ada
if ! grep -Fxq "[chaotic-aur]" "$config_file_chaotic"; then
    echo "Menambahkan repository chaotic-aur ke $config_file_chaotic..."
    echo "$block_to_add_chaotic" | sudo tee -a "$config_file_chaotic" > /dev/null
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
else
    chaoech=$(echo -e "\e[32m--- Blok chaotic-aur sudah ada di $config_file_chaotic. Tidak ditambahkan lagi. ---\e[0m")
fi
;;
[Nn]*|NO|No|no)
;;
esac

##
# Fungsi untuk menampilkan pesan error dan keluar dengan kode non-nol
error_exit() {
    echo -e "\e[31mERROR: $1\e[0m" >&2
    exit 1
}

# Fungsi untuk menjalankan perintah pacman dengan sudo.
# Ini akan meminta password sudo jika kredensial belum di-cache.
run_pacman_with_sudo() {
    echo -e "\n\e[34m--- Menjalankan: sudo pacman $@ ---\e[0m\n"
    sudo pacman "$@" --needed --noconfirm
    return $? # Mengembalikan kode keluar dari perintah pacman
}

# --- Skrip Utama ---

echo -e "\n\e[32mMemulai proses pembaruan sistem Arch Linux.\e[0m"

# Argumen default untuk pacman adalah -Syu (Sinkronisasi, Pembaruan, dan Pembersihan)
PACMAN_DEFAULT_ARGS="-Syu"

# Eksekusi awal operasi pacman
run_pacman_with_sudo "$PACMAN_DEFAULT_ARGS"
INITIAL_EXECUTION_STATUS=$?

# Memeriksa status eksekusi awal
if [ $INITIAL_EXECUTION_STATUS -ne 0 ]; then
    echo -e "\n\e[33m--- Operasi pacman gagal. Menganalisis dan mencoba memperbaiki masalah keyring... ---\e[0m"

    # Langkah 1: Mencoba memperbarui paket archlinux-keyring secara langsung
    echo -e "\e[36mMencoba memperbarui paket archlinux-keyring...\e[0m"
    run_pacman_with_sudo -S archlinux-keyring
    KEYRING_PACKAGE_UPDATE_STATUS=$?

    if [ $KEYRING_PACKAGE_UPDATE_STATUS -ne 0 ]; then
        # Langkah 2: Jika pembaruan paket keyring gagal, lakukan reset dan populate keyring
        echo -e "\n\e[31m--- Pembaruan archlinux-keyring gagal. Melakukan reset dan populate keyring... ---\e[0m"
        echo -e "\e[36mMenginisialisasi ulang keyring...\e[0m"
        sudo pacman-key --init || error_exit "Gagal menginisialisasi keyring."

        echo -e "\e[36mMengisi keyring dengan kunci resmi Arch Linux...\e[0m"
        sudo pacman-key --populate archlinux || error_exit "Gagal mengisi keyring Arch Linux."

        echo -e "\e[36mMelakukan refresh kunci (proses ini mungkin membutuhkan waktu)... \e[0m"
        # Refresh kunci mungkin tidak selalu berhasil 100% karena isu koneksi/server,
        # namun kita tetap akan mencoba kembali operasi pacman utama.
        sudo pacman-key --refresh-keys --keyserver hkps://keyserver.ubuntu.com

        if [ $? -ne 0 ]; then
            echo -e "\e[33mPeringatan: Proses refresh kunci mungkin tidak sepenuhnya berhasil. Akan mencoba kembali operasi pembaruan sistem.\e[0m"
        fi
    else
        echo -e "\e[32mPaket archlinux-keyring berhasil diperbarui.\e[0m"
    fi

    echo -e "\n\e[34m--- Mencoba kembali operasi pembaruan sistem setelah penanganan keyring... ---\e[0m"
    run_pacman_with_sudo "$PACMAN_DEFAULT_ARGS"
    FINAL_EXECUTION_STATUS=$?

    if [ $FINAL_EXECUTION_STATUS -ne 0 ]; then
        error_exit "Operasi pembaruan sistem masih gagal setelah upaya penanganan keyring. Mungkin ada masalah lain yang memerlukan perhatian manual (misalnya, masalah koneksi internet atau mirror)."
    else
        echo -e "\n\e[32m--- Pembaruan sistem berhasil setelah penanganan keyring. ---\e[0m"
    fi
else
    echo -e "\n\e[32m--- Pembaruan sistem berhasil tanpa masalah keyring terdeteksi. ---\e[0m"
fi

##

if fastfetch | grep -q "CPU : Intel"; then

#Fresh Reinstall Intel Package
if pacman -Q intel-media-sdk &>/dev/null; then
pacman -Qs intel | grep "local/" | awk '{print $1}' | sed 's/local\///' > intel_packages.txt
sudo pacman -Rdd $(cat intel_packages.txt) --noconfirm
sudo pacman -Sy $(cat intel_packages.txt) --noconfirm
rm intel_packages.txt
fi

echo -e "\e[34m->] Installing Intel Package..."
sudo pacman -S vulkan-intel intel-ucode intel-media-driver intel-media-sdk intel-gpu-tools libva-intel-driver intel-hybrid-codec-driver-git libvpl libva-utils --noconfirm --needed
# Teks yang ingin ditambahkan
block_to_add_intel=$(cat <<EOF
options i915 enable_guc=3
EOF
)
# File konfigurasi yang ditarget
config_file_intel="/etc/modprobe.d/i915.conf"
# Cek apakah blok sudah ada
if ! grep -Fxq "options i915 enable_guc=3" "$config_file_intel"; then
    echo "Menambahkan GUC intel i915 ke $config_file_intel agar aktif..."
    echo "$block_to_add_intel" | sudo tee -a "$config_file_intel" > /dev/null
    echo -e 'LIBVA_DRIVER_NAME=iHD\nANV_DEBUG=video-decode,video-encode\nLIBVA_DRIVERS_PATH=/usr/lib/dri/' >> /etc/environment
    
    mic_from_combojack=$(cat <<EOF
    options snd-hda-intel model=aspire-headset-mic dmic_detect=0 probe_mask=1
    EOF
    )
    add_jackmic="/etc/modprobe.d/alsa-base.conf"
    sudo touch 
    echo "$mic_from_combojack" | sudo tee -a "$add_jackmic" > /dev/null
    source ~/.bashrc
    sudo mkinitcpio -p linux
else
    intelech=$(echo -e "\e[32m--- Blok GUC Intel i915 sudah ada di $config_file_intel. Tidak ditambahkan lagi. ---\n--- Mic Combojack sudah diatur di $add_jackmic. Tidak ditambahkan lagi. ---\e[0m")
fi
fi

sudo pacman -S hyprland ttf-jetbrains-mono-nerd kitty hyprutils hyprlock hypridle wofi brightnessctl pamixer dunst libnotify jq fastfetch kitty mpv easyeffects ladspa pipewire lsp-plugins pulsemixer gst-plugin-pipewire pipewire-alsa pipewire-jack wireplumber pipewire-pulse swww waybar wlsunset udiskie blueman wlr-randr xdg-desktop-portal-hyprland xdg-desktop-portal-gtk sof-firmware --noconfirm --needed
sudo systemctl enable --global pipewire pipewire-pulse

# Teks yang ingin ditambahkan
block_to_add_hypr=$(cat <<EOF
if [[ -z \$DISPLAY && \$(tty) = /dev/tty1 ]]; then
    exec Hyprland
fi
EOF
)
# File konfigurasi yang ditarget
config_file_hypr=".bash_profile"
# Cek apakah blok sudah ada
if ! grep -qF "exec Hyprland" "$config_file_hypr"; then
    echo "Menambahkan Autorun Hyprland ke $config_file_hypr"
    echo "$block_to_add_hypr" | sudo tee -a "$config_file_hypr" > /dev/null
else
    echo    "--------------------------------------------------------"
    autohyprech=$(echo -e "\e[32m--- Autorun sudah ada di $config_file_hypr. Tidak ditambahkan lagi. ---\e[0m")
fi

# Teks yang ingin ditambahkan
block_to_add_dns=$(cat <<EOF
[Resolve]
 DNS=94.140.14.14#dns.adguard.com 1.1.1.1#1dot1do1dot1.cloudflare-dns.com
 FallbackDNS=8.8.8.8#dns.google 1.0.0.1#cloudflare-dns.com
 DNSOverTLS=yes
 DNSSEC=yes
EOF
)
# File konfigurasi yang ditarget
config_file_dns="/etc/systemd/resolved.conf"
# Cek apakah blok sudah ada
if ! grep -qF "1dot1do1dot1" "$config_file_dns"; then
    echo "Menambahkan Pengaturan DNS ke $config_file_dns"
    echo "$block_to_add_dns" | sudo tee -a "$config_file_dns" > /dev/null
else
    dnsech=$(echo -e "\e[32m--- DNS sudah diatur di $config_file_dns. Tidak ditambahkan lagi. ---\e[0m")
fi

#Fix Unstable Wifi
block_to_add_macw=$(cat <<EOF
[device]
wifi.scan-rand-mac-address=no
EOF
)
# File konfigurasi yang ditarget
config_file_macw="/etc/NetworkManager/NetworkManager.conf"
# Cek apakah blok sudah ada
if ! grep -qF "wifi.scan-rand" "$config_file_macw"; then
    echo "Menonaktifkan Alamat MAC Wifi Acak\ndengan Menambahkan Pengaturan di $config_file_macw"
    echo "$block_to_add_macw" | sudo tee -a "$config_file_macw" > /dev/null
else
    wifimacech=$(echo -e "\e[32m--- MAC Wifi sudah diatur di $config_file_macw. Tidak ditambahkan lagi. ---\e[0m")
fi

echo $chaoech
echo $intelech
echo $autohyprech
echo $dnsech
echo $wifimacech
