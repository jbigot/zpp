################################################################################
# Copyright (c) 2013-2014, CEA
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################

# default definition for FORTTYPES if unable to find config
FORTTYPES="CHARACTER1 COMPLEX4 COMPLEX8 COMPLEX16 INTEGER1 INTEGER2 INTEGER4 INTEGER8 LOGICAL1 LOGICAL2 LOGICAL4 LOGICAL8 REAL4 REAL8 REAL16"

source base.bpp.sh
CONFIG_FILE="${BPP_CONFIG:-config}.bpp.sh"
if [ -r "${CONFIG_FILE}" ]
then
	source "${CONFIG_FILE}"
fi

# Returns the Fortran kind associated to the type descriptor $1
function fort_kind {
	echo -n "$1" | sed 's/[^0-9]*//g'
}

# Returns the Fortran type associated to the type descriptor $1
function fort_ptype {
	echo -n "$1" | sed 's/[^a-zA-Z_]*//g'
}

# Returns the Fortran type associated to the type descriptor $1
function fort_type {
	echo -n "$(fort_ptype $1)"
	if [ -n "$(fort_kind $1)$2" ]
	then
		echo -n "("
	fi
	if [ -n "$(fort_kind $1)" ]
	then
		echo -n "KIND=$(fort_kind $1)"
	fi
	if [ -n "$(fort_kind $1)" -a -n "$2" ]
	then
		echo -n ","
	fi
	echo -n "$2"
	if [ -n "$(fort_kind $1)$2" ]
	then
		echo -n ")"
	fi
}

# Returns the size in bits of the Fortran type associated to the type descriptor $1
function fort_sizeof {
	KIND="$(fort_kind $1)"
	case "$1" in
	CHARACTER*|INTEGER*|LOGICAL*|REAL*)
		echo -n "$((KIND*8))"
		;;
	COMPLEX*)
		echo -n "$((2*KIND*8))"
		;;
	esac
}

# Returns an array descriptor for an assumed shape array of dimension $1
function array_desc() {
	str_repeat ':' 1 "$1" ',' '(' ')'
}

# Returns a format descriptor for I/O associated to the one letter type descriptor $1
function io_format {
	case "$1" in
	CHARACTER*)
		echo -n "A30"
		;;
	REAL*)
		echo -n "E30.5"
		;;
	INTEGER*)
		echo -n "I30"
		;;
	LOGICAL*)
		echo -n "L30"
		;;
	COMPLEX*)
		echo -n "(E15.5,E15.5)"
		;;
	esac
}
