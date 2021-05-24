
 Copyright (C) 2021, Xilinx Inc - All rights reserved
 Xilinx Transcoder (xcdr)

 Licensed under the Apache License, Version 2.0 (the "License"). You may
 not use this file except in compliance with the License. A copy of the
 License is located at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations
 under the License.

 xcdr (Xilinx Transcoder)


CMake project to build the xcdr development, DEB, and RPM packages

This project simplifies the building of the xcdr by offering a simple
CMake project and a Makefile with 2 targets.

To build a local development version of xcdr, enter the following command:

    make devel

The result of the above command can be found in the Debug directory.  NOTE: The setup.sh script will need to be adjusted to point to the proper LD_LIBRARY_PATH and PATH


To build a DEB package for release, enter the following command:

    make DEB

The result of the above command will create a .deb package file in the DEB_Release directory

To build an RPM package for release, enter the following command:

    make RPM

The result of the above command will create a .rpm package file in the RPM_Release directory
