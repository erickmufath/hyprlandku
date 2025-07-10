echo    "--------------------------------------------------------"
read -p    "->] Install Chaotic-AUR [Y/n] : " chaur
echo    "--------------------------------------------------------"
case $chaur in
*)
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
N|n|NO|No|no)
;;
esac


echo    "--------------------------------------------------------"
read -p    "->] Update Keyring [Y/n] : " keyring
echo    "--------------------------------------------------------"
case $keyring in
*)
sudo pacman-key --refresh-keys --keyserver hkps://keyserver.ubuntu.com
;;
N|n|NO|No|no)
;;
esac

sudo pacman -Syu
echo    "--------------------------------------------------------"
read -p    "->] Install Intel Package [Y/n] : " intelpkg
echo    "--------------------------------------------------------"
case $intelpkg in
*)
sudo pacman -S vulkan-intel intel-ucode intel-media-driver intel-media-sdk intel-gpu-tools libva-intel-driver intel-hybrid-codec-driver-git libvpl libva-utils --needed
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
;;
N|n|NO|No|no)
;;
esac

sudo pacman -S chaotic-aur/hyprland --needed
sudo pacman -S ttf-jetbrains-mono-nerd kitty hyprutils hyprlock hypridle wofi brightnessctl pamixer dunst libnotify jq fastfetch kitty mpv easyeffects ladspa pipewire lsp-plugins pulsemixer gst-plugin-pipewire pipewire-alsa pipewire-jack wireplumber pipewire-pulse swww waybar wlsunset udiskie blueman wlr-randr xdg-desktop-portal-hyprland xdg-desktop-portal-gtk sof-firmware --needed
sudo systemctl enable --global pipewire pipewire-pulse

# Teks yang ingin ditambahkan
block_to_add_hypr=$(cat <<EOF
if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
    exec Hyprland
fi
EOF
)
# File konfigurasi yang ditarget
config_file_hypr="~/.bash_profile"
# Cek apakah blok sudah ada
if ! grep -Fxq "exec Hyprland" "$config_file_hypr"; then
    echo "Menambahkan Autorun Hyprland ke $config_file_hypr"
    echo "$block_to_add_hypr" | sudo tee -a "$config_file_hypr" > /dev/null
    sudo mkinitcpio -p linux
else
    echo "Autorun sudah ada di $config_file_hypr. Tidak ditambahkan lagi."
fi
;;
N|n|NO|No|no)
;;
esac
