# Nokia XG-040G-MD firmware build

This repository contains the build recipe for the Nokia Bell XG-040G-MD (Airoha AN7581).

## Build base

The CI currently builds from the device-adapted source branch:

- Source: https://github.com/xiangtailiang/openwrt
- Branch: `xg040gmd-fixes`
- Device profile: `airoha/an7581`, `bell_xg-040g-md`

This is deliberate: the source branch includes the XG-040G-MD device tree/image definition and the NPU firmware-loading fix. It is not the generic `coolsnowwolf/lede` tree.

## NPU support

The adapted source changes the Airoha Ethernet/NPU drivers to loadable kernel modules and adds the NPU firmware package to the AN7581 target defaults. This avoids probing the NPU before the root filesystem firmware path is ready.

The build workflow checks that the device profile and NPU firmware package are selected, then compiles and uploads the resulting build artifacts. A successful compile proves that the firmware was built; runtime NPU acceleration still requires validation on the physical router.

## Current CI scope

The first CI run is a platform/NPU baseline build with LuCI, Chinese base language, and common USB modem/network drivers. It is intentionally staged: QModem, OpenClash, SSR Plus, QWRT theme and the NPU management UI will be added after their exact package/feed sources and compatibility with this OpenWrt branch are confirmed. This avoids silently selecting nonexistent packages and producing an invalid configuration.

## Start a build

Open **Actions → XG-040G-MD LEDE-compatible OpenWrt build → Run workflow**. A push to the workflow or README also starts the baseline build.

**Do not flash a build solely because compilation succeeded.** Confirm the NAND/U-Boot layout and test boot/recovery first. Keep a serial recovery path available.
