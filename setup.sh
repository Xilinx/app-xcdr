#
# Copyright (C) 2021, Xilinx Inc - All rights reserved
# Xilinx Transcoder (xcdr)
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

parse_parameters()
{
  while [ $# -gt 0 ]
  do
    arg=$1
    case $arg in
      -f)
      force=1
      shift
      ;;
      *)
      echo -e "\nWARNING: $arg not a recognized option"
      shift
      ;;
    esac
  done
}

validate_supported_os()
{
    declare -A supported_os_arr
    supported_os_arr=(
        ["Ubuntu"]="18.04 20.04 22.04"
        ["Amazon Linux"]="2"
        ["Red Hat"]="7.8"
    )
    # Detect OS Distribution
    if [ -n "$(command -v lsb_release)" ]; then
        distro_name=$(lsb_release -s -d)
    elif [ -f "/etc/os-release" ]; then
        distro_name=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
    elif [ -f "/etc/debian_version" ]; then
        distro_name="Debian $(cat /etc/debian_version)"
    elif [ -f "/etc/redhat-release" ]; then
        distro_name=$(cat /etc/redhat-release)
    else
        distro_name="$(uname -s) $(uname -r)"
    fi
    supported_distros_as_str=""
    is_os_supported=0
    for supported_os_name in "${!supported_os_arr[@]}"; do
        supported_os_versions=${supported_os_arr[$supported_os_name]}
        for version in $supported_os_versions; do
            if [[ "$distro_name" = *"$supported_os_name"* ]] && [[ "$distro_name" = *"$version"* ]]; then
            current_os="$supported_os_name $version"
            is_os_supported=1
        fi
        supported_distros_as_str="$supported_os_name $version, $supported_distros_as_str"
        done
    done
    if [ $is_os_supported -eq 0 ]; then
        if [ $force -eq 1 ]; then
            echo -e "\nWARNING: This install script is for ${supported_distros_as_str}but the detected OS is $distro_name!\nForce provided, continuing install...\n"
        else
            echo -e "\nERROR: This install script is for ${supported_distros_as_str}but the detected OS is $distro_name!\nUse -f to force."
            return 255
        fi
    fi
}

validate_supported_kernel()
{
    local current_os="$1"
    supported_kernel_arr=(
        "Ubuntu 18.04 kernel 5.4"
        "Ubuntu 20.04 kernel 5.11" "Ubuntu 20.04 kernel 5.4" "Ubuntu 20.04 kernel 5.13"
        "Ubuntu 22.04 kernel 5.15"
        "Red Hat 7.8 kernel 4.9.184"
        "Amazon Linux 2 kernel 4.14" "Amazon Linux 2 kernel 5.10"
    )
    supported_distros_as_str=""
    system_kernel="$(uname -r)"
    is_kernel_supported=0
    for os_kernel in "${supported_kernel_arr[@]}"; do
        if [[ "$current_os kernel $system_kernel" == "$os_kernel"* ]]; then
            is_kernel_supported=1
        fi
        if [[ "$supported_distros_as_str" == "" ]]; then
            supported_distros_as_str="$os_kernel"
        else
            supported_distros_as_str="$os_kernel, $supported_distros_as_str"
        fi
    done
    if [ $is_kernel_supported -eq 0 ]; then
        if [ $force -eq 1 ]; then
            echo -e "\nWARNING: This $current_os system has kernel $system_kernel. U30 supports kernel ${supported_distros_as_str}!\nForce provided, continuing install...\n"
        else
            echo -e "\nERROR: This $current_os system has kernel $system_kernel. U30 supports ${supported_distros_as_str}!\nUse -f to force."
            return 255
        fi
    fi
}

force=0
parse_parameters $@ # Set force if provided
current_os=""
validate_supported_os # Also sets current_os
if [[ $? -ne 0 ]]; then
    return 255
fi
validate_supported_kernel "$current_os"
if [[ $? -ne 0 ]]; then
    return 255
fi

echo ---------------------------------------
echo -----Source Xilinx U30 setup files-----
source /opt/xilinx/xrt/setup.sh
source /opt/xilinx/xrm/setup.sh
export LD_LIBRARY_PATH=/opt/xilinx/ffmpeg/lib:$LD_LIBRARY_PATH
export PATH=/opt/xilinx/ffmpeg/bin:/opt/xilinx/xcdr/bin:/opt/xilinx/launcher/bin:/opt/xilinx/jobSlotReservation/bin:$PATH
source /opt/xilinx/xcdr/xrmd_start.bash

VVAS_DIR=/opt/xilinx/vvas
if [ -d "$VVAS_DIR" ]; then
    export LD_LIBRARY_PATH=/opt/xilinx/vvas/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=/opt/xilinx/vvas/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=/opt/xilinx/vvas/bin:$PATH
    export GST_PLUGIN_PATH=/opt/xilinx/vvas/lib/gstreamer-1.0:$GST_PLUGIN_PATH
fi

OLD_SHELLS="xilinx_u30_gen3x4_base_1 "

old_shell_count=0
devicestring="device"
maxlinesoutput=256
u30string="u30"
EXAMINE_FILE=/tmp/xbutil_examine.json

detect_older_shells()
{
    for shell in $OLD_SHELLS
    do
        old=$(grep -A $maxlinesoutput $devicestring $EXAMINE_FILE | grep -c -o $shell)
        if [ "$old" -gt ${mindevice} ] ;
        then
            old_shell_count=$((old_shell_count + "$old"))
        fi
    done
}

mindevice=0
maxdevice=16

remove_tmp=$(rm -f $EXAMINE_FILE)
xe=$(xbutil examine -o $EXAMINE_FILE)
ret=$?
if [ $ret -eq 0 ] ;
then
    detect_older_shells
    numdevice=$(grep -A $maxlinesoutput $devicestring $EXAMINE_FILE | grep -o $u30string | wc -l)

    if [[ "$numdevice" -gt "$maxdevice" ]] ;
    then
        echo "Number of U30 devices $numdevice exceeds maximum supported device count of $maxdevice ";
    else
        echo "Number of U30 devices found : $numdevice ";
    fi

    if [ "$old_shell_count" -gt "$mindevice" ] ;
    then
        echo "$old_shell_count device(s) with an older shell were detected"
        echo "This is not a supported configuration"
        return 1 2>/dev/null
        exit 1
    fi
else
  echo "ERROR: Failed to obtain device status. Aborting."
  return 1 2>/dev/null
  exit 1
fi
remove_tmp=$(rm -f $EXAMINE_FILE)

xrmadm /opt/xilinx/xcdr/scripts/xrm_commands/load_multiple_devices/load_all_devices_cmd.json

echo -----Load xrm plugins-----
xrmadm /opt/xilinx/xcdr/scripts/xrm_commands/load_multi_u30_xrm_plugins_cmd.json
echo ---------------------------------------
