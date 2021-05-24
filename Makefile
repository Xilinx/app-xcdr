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

devel:
	rm -rf Debug; \
	mkdir Debug; \
	cd Debug; \
	cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(CURDIR)/Debug ..; \
	make install

DEB:
	rm -rf DEB_Release; \
	mkdir DEB_Release; \
	cd DEB_Release; \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xilinx/xcdr ..; \
	cpack -G DEB

RPM:
	rm -rf RPM_Release; \
	mkdir RPM_Release; \
	cd RPM_Release; \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xilinx/xcdr ..; \
	cpack -G RPM

clean:
	rm -rf Debug DEB_Release RPM_Release
