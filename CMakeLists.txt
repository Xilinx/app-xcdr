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
set(XCDR_PROJ "xilinx-u30-xcdr")
set(XCDR_VER  "3.0.0")

find_program(UNAME_EXEC uname)
find_program(LSB_RELEASE_EXEC lsb_release)

execute_process(COMMAND ${LSB_RELEASE_EXEC} -is
    OUTPUT_VARIABLE LINUX_FLAVOR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if (${LINUX_FLAVOR} MATCHES "^(Ubuntu|Debian)")
        # amd64
        execute_process(
        COMMAND dpkg --print-architecture
        OUTPUT_VARIABLE CPACK_ARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
elseif (${LINUX_FLAVOR} MATCHES "^(RedHat|CentOS|Amazon|Fedora|SUSE)")
        # x86_64
        execute_process(
        COMMAND uname -m
        OUTPUT_VARIABLE CPACK_ARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
else()
        message( SEND_ERROR "Trying to build on incompatible system \"${LINUX_FLAVOR}\"." )
endif()

# Grab OS release short name
execute_process(COMMAND ${LSB_RELEASE_EXEC} -rs
        OUTPUT_VARIABLE LSB_RELEASE_REL_SHORT
        OUTPUT_STRIP_TRAILING_WHITESPACE)

if (${LINUX_FLAVOR} MATCHES "^Amazon")
        set(LSB_RELEASE_REL_SHORT "amzn${LSB_RELEASE_REL_SHORT}")
endif()

set(XCDR_PROJ_FULL_NAME "${XCDR_PROJ}_${XCDR_VER}_${LSB_RELEASE_REL_SHORT}-${CPACK_ARCH}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_FILE_LICENSE_PATH "/usr/share/doc/xilinx/u30")

project(${XCDR_PROJ})

install(FILES ${CMAKE_SOURCE_DIR}/setup.sh
        DESTINATION ${CMAKE_INSTALL_PREFIX})
install(FILES ${CMAKE_SOURCE_DIR}/xrmd_start.bash 
        DESTINATION ${CMAKE_INSTALL_PREFIX})

install(DIRECTORY ${CMAKE_SOURCE_DIR}/scripts/
        USE_SOURCE_PERMISSIONS
        DESTINATION ${CMAKE_INSTALL_PREFIX}/scripts)

install(DIRECTORY ${CMAKE_SOURCE_DIR}/xclbins/
        DESTINATION ${CMAKE_INSTALL_PREFIX}/xclbins)

install(FILES ${CPACK_RESOURCE_FILE_LICENSE} CONFIGURATIONS Release RUNTIME DESTINATION ${CPACK_FILE_LICENSE_PATH}/${XCDR_PROJ})

# Packaging section
set(CPACK_PACKAGE_NAME ${XCDR_PROJ})
set(CPACK_PACKAGE_VERSION ${XCDR_VER})
set(CPACK_PACKAGE_FILE_NAME ${XCDR_PROJ_FULL_NAME})
set(CPACK_PACKAGE_CONTACT "John Nichols <jnichol@xilinx.com>")
set(CPACK_PACKAGE_VENDOR "Xilinx")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Xilinx Transcoder Application for MPSoC Device")
set(CPACK_PACKAGE_DESCRIPTION "The Xilinx Media Accelerator Transcoder Application
                               provides utilities and download images to accelerate
                               Decoding, Scaling and  Encoding for H.264 and HEVC streams on a Xilinx FPGA")
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_SOURCE_DIR}/postinst;${CMAKE_SOURCE_DIR}/prerm")
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/postinst")
set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/prerm")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "xrt (>= 2.11), xrm (>= 1.5), xilinx-xvbm (= 1.0.3), xilinx-u30-xmpsoccodecs (= 1.2.0), xilinx-u30-xma-multiscaler (= 1.1.1), xilinx-u30-xlookahead (= 1.2.0), xilinx-u30-xrm-decoder (= 1.1.1), xilinx-u30-xrm-multiscaler (= 1.1.1), xilinx-u30-xrm-encoder (= 1.1.1)")
set(CPACK_RPM_PACKAGE_REQUIRES   "xrt  >= 2.11,  xrm  >= 1.5,  xilinx-xvbm  = 1.0.3,  xilinx-u30-xmpsoccodecs  = 1.2.0,  xilinx-u30-xma-multiscaler  = 1.1.1,  xilinx-u30-xlookahead  = 1.2.0,  xilinx-u30-xrm-decoder  = 1.1.1,  xilinx-u30-xrm-multiscaler  = 1.1.1,  xilinx-u30-xrm-encoder  = 1.1.1")
set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/opt" "/opt/xilinx" "/usr/lib" "/usr/lib/pkgconfig" "/usr/share/doc/xilinx" "/usr/share/doc/xilinx/u30")
include(CPack)
