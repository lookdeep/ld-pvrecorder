#!/bin/bash
#
# A script to get the platform and architecture the system is running.

kernel=$(uname -s)
arch=$(uname -m)

case $kernel in
  "Darwin")
    kernel="mac"
    case $arch in
      "x86_64") ;;
      "arm64") ;;
      *) exit 1;;
    esac;;
  "Linux")
    kernel="linux"
    case $arch in
      "x86_64") ;;
      "arm"* | "aarch64")
        bitwidth=$(getconf LONG_BIT)
        arch_info=''
        if [[ $bitwidth == "64" ]]; then
          arch_info=-$arch
        fi
        cpu_part_list="$(cat /proc/cpuinfo | grep 'CPU part')":
        found_cpu=0
        while IFS= read -r part; do
          cpu_part=$(awk -F' ' '{print $NF}' <<< $part)
          case $cpu_part in
            "0xb76") kernel="raspberry-pi" arch="arm11"$arch_info found_cpu=1;;
            "0xc07") kernel="raspberry-pi" arch="cortex-a7"$arch_info found_cpu=1;;
            "0xd03") kernel="raspberry-pi" arch="cortex-a53"$arch_info found_cpu=1;;
            "0xd07") kernel="jetson" arch="cortex-a57"$arch_info found_cpu=1;;
            "0xd08") kernel="raspberry-pi" arch="cortex-a72"$arch_info found_cpu=1;;
            "0xd0b") kernel="raspberry-pi" arch="cortex-a72"$arch_info found_cpu=1;;
            "0xc08") kernel="beaglebone" arch=$arch_info found_cpu=1;;
            *) ;;
          esac
        done < <(printf '%s\n' "$cpu_part_list")
        if [ $found_cpu -eq 0 ]; then
          exit 1;
        fi
    esac
    ;;
  *) exit 0;;
esac

echo -n "$kernel $arch"
exit 0
