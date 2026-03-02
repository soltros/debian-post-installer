#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

echo "--- Starting Debian Post-Install Configuration ---"

# 1. Add current user to sudo group
usermod -aG sudo "$SUDO_USER"
echo "Added $SUDO_USER to the sudo group."

# 2. Update sources.list to Debian Testing
# Ensuring main, contrib, non-free, and non-free-firmware are enabled.
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware

deb http://deb.debian.org/debian-security/ testing-security main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian-security/ testing-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ testing-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ testing-updates main contrib non-free non-free-firmware
EOF

echo "Sources updated to Testing. Performing system upgrade..."
apt update && apt dist-upgrade -y

# 3. Install Core Dependencies & Tailscale
echo "Installing system dependencies and Tailscale..."
apt install -y flatpak wget curl papirus-icon-theme
curl -fsSL https://tailscale.com/install.sh | sh

# 4. Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 5. Download and Install Steam .deb
echo "Installing Steam via .deb..."
wget -O /tmp/steam.deb https://cdn.fastly.steamstatic.com/client/installer/steam.deb
apt install -y /tmp/steam.deb
rm /tmp/steam.deb

# 6. Install Materia KDE Theme
echo "Installing Materia KDE..."
wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/materia-kde/master/install.sh | sh

# 7. Install Flatpaks
echo "Installing Flatpak applications..."
FLATPAKS=(
    net.waterfox.waterfox com.discordapp.Discord com.github.tchx84.Flatseal
    com.bitwarden.desktop com.valvesoftware.Steam org.telegram.desktop
    it.mijorus.gearlever org.gnome.World.PikaBackup org.videolan.VLC
    com.github.wwmm.easyeffects io.github.dweymouth.supersonic
    io.github.dvlv.boxbuddyrs de.leopoldluley.Clapgrep im.nheko.Nheko
    io.github.flattool.Ignition io.github.flattool.Warehouse
    io.missioncenter.MissionCenter com.vysp3r.ProtonPlus org.libretro.RetroArch
    net.lutris.Lutris org.libreoffice.LibreOffice com.github.iwalton3.jellyfin-media-player
    io.podman_desktop.PodmanDesktop org.filezillaproject.Filezilla dev.zed.Zed
    io.github.shiftey.Desktop org.gtk.Gtk3theme.Breeze org.gtk.Gtk3theme.adw-gtk3
    org.gtk.Gtk3theme.adw-gtk3-dark org.gustavoperedo.FontDownloader
    sh.loft.devpod com.heroicgameslauncher.hgl org.prismlauncher.PrismLauncher
    org.blender.Blender org.audacityteam.Audacity org.inkscape.Inkscape
    org.kde.kdenlive com.github.hugolabe.Wike
