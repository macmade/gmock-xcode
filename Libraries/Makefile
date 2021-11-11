#-------------------------------------------------------------------------------
# The MIT License (MIT)
# 
# Copyright (c) 2014 Jean-David Gadina - www.xs-labs.com / www.digidna.net
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# @file         Makefile
# @copyright    (c) 2015 - Jean-David Gadina - www.xs-labs.com
# @abstract     GMock makefile for POSIX platforms
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Path to directories
#-------------------------------------------------------------------------------

DIR_BUILD                       = ./build/
DIR_TMP                         = ./tmp/
DIR_TMP_BUILD                   = $(DIR_TMP)build/

ifeq ($(findstring Darwin, $(shell uname)),)
DIR_BUILD_LIB                   = $(DIR_BUILD)lib/linux/
CMAKE_FLAGS                     =
else
DIR_BUILD_LIB                   = $(DIR_BUILD)lib/osx/
CMAKE_FLAGS                     = -DCMAKE_OSX_SYSROOT=$(xcrun --sdk macosx --show-sdk-path) -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 -DCMAKE_CXX_FLAGS="-stdlib=libc++"
endif

#-------------------------------------------------------------------------------
# Software versions
#-------------------------------------------------------------------------------

VERSION_GMOCK                   = 1.8.0

#-------------------------------------------------------------------------------
# Source paths
#-------------------------------------------------------------------------------

SRC_GMOCK                       = $(DIR_TMP)release-$(VERSION_GMOCK).zip
SRC_GMOCK_DIR                   = $(DIR_TMP)googletest-release-$(VERSION_GMOCK)/

#-------------------------------------------------------------------------------
# Targets
#-------------------------------------------------------------------------------

# Phony targets
.PHONY: clean all gmock_unpack gmock_build

# Complete build
all: $(SRC_GMOCK) gmock_unpack gmock_build

# Clean-up
clean:
	@echo "    *** Cleaning all build files"

# GMock source download
$(SRC_GMOCK):
	@echo "    *** Downloading GMock ($(VERSION_GMOCK))"
	@cd $(DIR_TMP) && curl -O -L https://github.com/google/googletest/archive/release-$(VERSION_GMOCK).zip

# GMock source un-archiving
gmock_unpack:
	@echo "    *** Unpacking GMock ($(VERSION_GMOCK))"
	@if [ ! -d $(SRC_GMOCK_DIR) ]; then unzip $(SRC_GMOCK) -d $(DIR_TMP); fi

# GMock libraries build
gmock_build:
	@echo "    *** Building GMock ($(VERSION_GMOCK))"
	@cd $(DIR_TMP_BUILD) && cmake $(CMAKE_FLAGS) ../../$(SRC_GMOCK_DIR) && make
	@cp $(DIR_TMP_BUILD)googlemock/libgmock.a $(DIR_BUILD_LIB)
	@cp $(DIR_TMP_BUILD)googlemock/libgmock_main.a $(DIR_BUILD_LIB)
	@cp $(DIR_TMP_BUILD)googlemock/gtest/libgtest_main.a $(DIR_BUILD_LIB)
	@cp $(DIR_TMP_BUILD)googlemock/gtest/libgtest.a $(DIR_BUILD_LIB)
	@cp -rf $(SRC_GMOCK_DIR)googlemock/include/gmock $(DIR_BUILD)include/
	@cp -rf $(SRC_GMOCK_DIR)googletest/include/gtest $(DIR_BUILD)include/
