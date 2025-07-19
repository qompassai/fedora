#!/usr/bin/env bash
# /qompassai/fedora/scripts/quickstart.sh
# Qompass AI Fedora Quickstart
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
set -euo pipefail
FALLBACK_ISO_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-40-1.2.iso"
detect_os() {
	unameOut="$(uname -s)"
	case "${unameOut}" in
	Linux*) OS="linux" ;;
	Darwin*) OS="macos" ;;
	CYGWIN* | MINGW* | MSYS*) OS="windows" ;;
	*) OS="unknown" ;;
	esac
	echo "==> Detected OS: $OS"
}
download_iso() {
	echo "==> Downloading Fedora ISO..."
	mkdir -p "$HOME/Downloads"
	ISO_PATH="$HOME/Downloads/fedora.iso"
	if command -v curl >/dev/null 2>&1; then
		curl -L "$FALLBACK_ISO_URL" -o "$ISO_PATH"
	elif command -v wget >/dev/null 2>&1; then
		wget "$FALLBACK_ISO_URL" -O "$ISO_PATH"
	else
		echo "No curl or wget installed. Download the ISO manually from:"
		echo "$FALLBACK_ISO_URL"
		exit 1
	fi
	echo "Downloaded Fedora ISO to $ISO_PATH"
}
create_bootable_usb() {
	echo "==> Creating bootable Fedora USB..."
	case "$OS" in
	macos)
		echo "Install Fedora Media Writer from: https://getfedora.org/"
		echo "Or use Balena Etcher (https://balena.io/etcher) or command line:"
		echo "  sudo dd if=$ISO_PATH of=/dev/rdiskN bs=4m status=progress"
		echo "Replace /dev/rdiskN with your USB device (run diskutil list)."
		;;
	linux)
		if command -v fedora-media-writer >/dev/null 2>&1; then
			fedora-media-writer --iso "$ISO_PATH"
		else
			echo "Install Fedora Media Writer (flatpak install flathub org.fedoraproject.MediaWriter) or use dd:"
			echo "  sudo dd if=$ISO_PATH of=/dev/sdX bs=4M status=progress oflag=sync"
			echo "Replace /dev/sdX with your USB device (check with lsblk or fdisk -l)."
		fi
		;;
	windows)
		echo "Download Fedora Media Writer from: https://getfedora.org/"
		echo "Or use Rufus (https://rufus.ie/) to write the ISO to a USB drive."
		;;
	*)
		echo "Unknown or unsupported OS. Create install media manually."
		exit 1
		;;
	esac
}
show_dualboot_instructions() {
	echo
	echo "==> Dual-Boot Partition Instructions"
	case "$OS" in
	windows)
		echo "1. In Windows, open Disk Management and shrink your main Windows partition to make free space for Fedora.[5]"
		echo "2. Reboot and boot from your Fedora USB."
		echo "3. In Fedora installer, select the free space for Fedora and let it auto-create partitions."
		echo "4. Fedora installer will add GRUB which lets you boot both Fedora and Windows."
		;;
	macos)
		echo "1. Open Disk Utility and resize your Mac partition to create free space."
		echo "2. Leave the new partition as 'Untitled', format as Mac OS Extended or FAT."
		echo "3. Boot Mac holding Option key; select Fedora USB to start the installer."
		echo "4. In installer, select 'Install alongside MacOS' (use the unallocated space)."
		echo "5. After install, set startup disk from macOS or use Option key at boot to pick OS."
		echo "Tip: For Apple Silicon Macs, follow Fedora Asahi Remix instructions."
		;;
	linux)
		echo "You already have Linux. Shrink any partition as needed, then use unallocated space for Fedora."
		echo "Back up your data before repartitioning."
		;;
	esac
	echo
	echo "!! Always back up important data before repartitioning disks and installing OSes !!"
}
main() {
	detect_os
	download_iso
	create_bootable_usb
	show_dualboot_instructions
	echo "==> Boot from the Fedora USB and follow the on-screen installer instructions to install Fedora alongside your existing OS."
}
main "$@"
