#!/usr/bin/env bash
set -euo pipefail

# OpenWrt normalizes device names in Kconfig symbols: hyphens become underscores.
TARGET_PROFILE_SYMBOL='CONFIG_TARGET_DEVICE_airoha_an7581_DEVICE_nokia_xg_040g_md_ubi'

# Expand the short config.seed first so Kconfig can resolve the selected device.
make defconfig
grep -qx "${TARGET_PROFILE_SYMBOL}=y" .config || {
  echo "::error::Nokia XG-040G-MD UBI target profile is not selected after make defconfig."
  echo "::error::Expected: ${TARGET_PROFILE_SYMBOL}=y"
  grep -E '^CONFIG_TARGET_(airoha|DEVICE_airoha_an7581)' .config || true
  exit 1
}

# Optional packages are attempted and reported rather than making the whole
# firmware fail if a feed package was renamed/removed on the current branch.
OPTIONAL_PACKAGES=(
  luci-app-openclash
  luci-app-passwall2
  luci-app-nlbwmon
  luci-app-statistics
  luci-app-ttyd
  luci-app-filebrowser
  luci-app-wol
  luci-app-ddns
  ddns-scripts
  htop
  qmodem
  luci-app-qmodem-next
  kmod-usb-net
  kmod-usb-net-cdc-ether
  kmod-usb-net-cdc-ncm
  kmod-usb-net-qmi-wwan
  kmod-usb-net-cdc-mbim
  kmod-usb-net-rndis
  kmod-usb-serial
  kmod-usb-serial-option
  kmod-usb-serial-wwan
  usb-modeswitch
  uqmi
  umbim
  comgt
  comgt-ncm
  luci-proto-qmi
  luci-proto-mbim
  luci-proto-ncm
  kmod-mac80211
  kmod-cfg80211
  kmod-mt76x0u
  kmod-mt76x2u
  kmod-mt7601u
  kmod-ath9k-htc
  kmod-carl9170
  kmod-rtl8xxxu
  kmod-rtl8192cu
  kmod-rtl8188eu
  kmod-rtl8812au-ct
  iw
  iwinfo
  hostapd-common
  wpad-mbedtls
)

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  printf 'CONFIG_PACKAGE_%s=y\n' "$pkg" >> .config
done
make defconfig

# Re-check after Kconfig normalization to ensure the intended UBI device remains selected.
grep -qx "${TARGET_PROFILE_SYMBOL}=y" .config || {
  echo "::error::Nokia XG-040G-MD UBI target profile was dropped by make defconfig."
  grep -E '^CONFIG_TARGET_(airoha|DEVICE_airoha_an7581)' .config || true
  exit 1
}

mkdir -p "$GITHUB_WORKSPACE/output"
report="$GITHUB_WORKSPACE/output/package-availability.txt"
: > "$report"
for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  if grep -qx "CONFIG_PACKAGE_${pkg}=y" .config; then
    echo "ENABLED $pkg" | tee -a "$report"
  else
    echo "NOT-AVAILABLE-OR-DEPENDENCY $pkg" | tee -a "$report"
  fi
done
cp .config "$GITHUB_WORKSPACE/output/build.config.resolved"
echo "Package selection report written to $report"
