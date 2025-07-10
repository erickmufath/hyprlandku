echo    "--------------------------------------------------------"
read -p    "->] Install Chaotic-AUR [Y/n] : " chaur
echo    "--------------------------------------------------------"
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
    echo "Blok chaotic-aur sudah ada di $config_file_chaotic. Tidak ditambahkan lagi."
fi
;;
[Nn]*|NO|No|no)
;;
esac


echo    "--------------------------------------------------------"
read -p    "->] Update Keyring [Y/n] : " keyring
echo    "--------------------------------------------------------"
case $keyring in
""|[Yy]*)
sudo pacman-key --refresh-keys --keyserver hkps://keyserver.ubuntu.com
;;
[Nn]*|NO|No|no)
;;
esac

sudo pacman -Syu --needed

if fastfetch | grep -q "CPU : Intel"; then
echo    "--------------------------------------------------------"
echo    "->] Installing Intel Package..."
echo    "--------------------------------------------------------"
sudo pacman -S vulkan-intel intel-ucode intel-media-driver intel-media-sdk intel-gpu-tools libva-intel-driver intel-hybrid-codec-driver-git libvpl libva-utils --noconfirm --needed
echo 'export LIBVA_DRIVER_NAME=iHD' >> ~/.bashrc
source ~/.bashrc
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
    sudo mkinitcpio -p linux
else
    echo "Blok GUC Intel i915 sudah ada di $config_file_intel. Tidak ditambahkan lagi."
fi
fi

sudo pacman -S chaotic-aur/hyprland --needed
sudo pacman -S ttf-jetbrains-mono-nerd kitty hyprutils hyprlock hypridle wofi brightnessctl pamixer dunst libnotify jq fastfetch kitty mpv easyeffects ladspa pipewire lsp-plugins pulsemixer gst-plugin-pipewire pipewire-alsa pipewire-jack wireplumber pipewire-pulse swww waybar wlsunset udiskie blueman wlr-randr xdg-desktop-portal-hyprland xdg-desktop-portal-gtk sof-firmware --needed
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
    echo "Autorun sudah ada di $config_file_hypr. Tidak ditambahkan lagi."
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
    echo "DNS sudah diatur di $config_file_dns. Tidak ditambahkan lagi."
fi
