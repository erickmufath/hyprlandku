echo    "--------------------------------------------------------"
read -p    "->] Install Intel Package [Y/n] : " intelpkg
echo    "--------------------------------------------------------"
case $intelpkg in
Y|y|Yes|YES|yes|*)
vulkan-intel intel-ucode intel-media-driver intel-media-sdk
# Teks yang ingin ditambahkan
block_to_add=$(cat <<EOF
options i915 enable_guc=3
EOF
)
# File konfigurasi yang ditarget
config_file="/etc/modprobe.d/i915.conf"
# Cek apakah blok sudah ada
if ! grep -Fxq "options i915 enable_guc=3" "$config_file"; then
    echo "Menambahkan GUC intel i915 ke $config_file agar aktif..."
    echo "$block_to_add" | sudo tee -a "$config_file" > /dev/null
    mkinitcpio -p linux
else
    echo "Blok GUC Intel i915 sudah ada di $config_file. Tidak ditambahkan lagi."
fi
;;
N|n|No|NO|no)
;;
esac

sudo pacman -S ttf-jetbrains-mono-nerd kitty hyprlock hypridle wofi brightnessctl pamixer dunst libnotify jq fastfetch kitty mpv easyeffects ladspa pipewire lsp-plugins pulsemixer gst-plugin-pipewire pipewire-alsa pipewire-jack wireplumber pipewire-pulse libvdpau-va-gl swww waybar wlsunset udiskie blueman wlr-randr xdg-desktop-portal-hyprland xdg-desktop-portal-gtk 
echo    "--------------------------------------------------------"
read -p    "->] Install Chaotic-AUR [Y/n] : " chaur
echo    "--------------------------------------------------------"
case $chaur in
Y|y|Yes|YES|yes|*)
# Teks yang ingin ditambahkan
block_to_add=$(cat <<EOF
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
)
# File konfigurasi yang ditarget
config_file="/etc/pacman.conf"
# Cek apakah blok sudah ada
if ! grep -Fxq "[chaotic-aur]" "$config_file"; then
    echo "Menambahkan repository chaotic-aur ke $config_file..."
    echo "$block_to_add" | sudo tee -a "$config_file" > /dev/null
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
else
    echo "Blok chaotic-aur sudah ada di $config_file. Tidak ditambahkan lagi."
fi
;;
N|n|No|NO|no)
;;
esac

sudo pacman -Syu
sudo pacman -S chaotic-aur/hyprland
