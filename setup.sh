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

echo ---------------------------------------
echo -----Source Xilinx U30 setup files-----
source /opt/xilinx/xrt/setup.sh
source /opt/xilinx/xrm/setup.sh
export LD_LIBRARY_PATH=/opt/xilinx/ffmpeg/lib:$LD_LIBRARY_PATH
export PATH=/opt/xilinx/ffmpeg/bin:/opt/xilinx/xcdr/bin:/opt/xilinx/launcher/bin:/opt/xilinx/jobSlotReservation/bin:$PATH

systemctl start xrmd
sleep 1

numdevice=$(xbutil examine | grep -A 32 "Devices present" | grep -o 'xilinx_u30_gen3x4_base_1' | wc -l)
mindevice=0
maxdevice=16



if [[ "$numdevice" -le "$mindevice" ]]; then
	echo "No U30 devices found"
	numdevice=$mindevice;
elif [[ "$numdevice" -gt "$maxdevice" ]]; then
	echo "Number of U30 devices $numdevice exceeds maximum supported device count of $maxdevice ";
	numdevice=$maxdevice;
else
	echo "Number of U30 devices found : $numdevice ";
fi

xrmadm /opt/xilinx/xcdr/scripts/xrm_commands/load_multiple_devices/load_all_devices_cmd.json

echo -----Load xrm plugins-----
xrmadm /opt/xilinx/xcdr/scripts/xrm_commands/load_multi_u30_xrm_plugins_cmd.json
echo ---------------------------------------
