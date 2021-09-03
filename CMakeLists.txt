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

cmake_minimum_required(VERSION 2.8.11)

project(xcdr)

install(FILES ${CMAKE_SOURCE_DIR}/setup.sh
        DESTINATION ${CMAKE_INSTALL_PREFIX})

install(DIRECTORY ${CMAKE_SOURCE_DIR}/scripts/
        USE_SOURCE_PERMISSIONS
        DESTINATION ${CMAKE_INSTALL_PREFIX}/scripts)

install(DIRECTORY ${CMAKE_SOURCE_DIR}/xclbins/
        DESTINATION ${CMAKE_INSTALL_PREFIX}/xclbins)

# Packaging section
set(CPACK_PACKAGE_NAME "xcdr")
set(CPACK_PACKAGE_VERSION "0.2.15")
set(CPACK_PACKAGE_CONTACT "John Nichols <jnichol@xilinx.com>")
set(CPACK_PACKAGE_VENDOR "Xilinx")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Xilinx Transcoder Application for MPSoC Device")
set(CPACK_PACKAGE_DESCRIPTION "The Xilinx Media Accelerator Transcoder Application
                               provides utilities and download images to accelerate
                               Decoding, Scaling and  Encoding for H.264 and HEVC streams on a Xilinx FPGA")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "xffmpeg (>= 4.1.10), xmpsoccodecs (>= 1.0.1), xmultiscaler (>= 1.0.1), xlookahead (>= 1.0.1), xmapropstojson (>= 1.0.0), xrm (>= 1.2.1165), xrmu30decoder (>= 1.0.0), xrmu30scaler (>= 1.0.0), xrmu30encoder (>= 1.0.0), launcher (>= 1.0.0), jobslotreservation (>= 1.0.0) " )
set(CPACK_RPM_PACKAGE_REQUIRES  "xffmpeg >= 4.1.10, xmpsoccodecs >= 1.0.1, xmultiscaler >= 1.0.1, xlookahead >= 1.0.1, xmapropstojson >= 1.0.0, xrm >= 1.2.1165, xrmu30decoder >= 1.0.0, xrmu30scaler >= 1.0.0, xrmu30encoder >= 1.0.0, launcher >= 1.0.0, jobslotreservation >= 1.0.0 ")
set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/opt" "/opt/xilinx" "/usr/lib" "/usr/lib/pkgconfig")
include(CPack)
