FORTTYPES="CHARACTER1 COMPLEX4 COMPLEX8 COMPLEX16 INTEGER1 INTEGER2 INTEGER4 INTEGER8 LOGICAL1 LOGICAL2 LOGICAL4 LOGICAL8 REAL4 REAL8 REAL16"

"${CONFIG_FILE:=config.bpp.sh}"

source base.bpp.sh
if [ -r "${CONFIG_FILE}" ]
then
	source "${CONFIG_FILE}"
fi

# Returns the Fortran type associated to the type descriptor $1
function fort_type {
	TNAME="$(echo -n "$1"|sed 's/[^a-zA-Z_]*//g')"
	TID="$(echo -n "$1"|sed 's/[^0-9]*//g')"
	echo "${TNAME}(${TID})" | tr 'A-Z' 'a-z'
}

# Returns the size of the Fortran type associated to the type descriptor $1
function fort_sizeof {
	eval "echo \${S_${1}}"

	TID="$(echo -n "$1"|sed 's/[^0-9]*//g')"
	case "$1" in
	CHARACTER*|INTEGER*|LOGICAL*|REAL*)
		echo "$TID"
		;;
	COMPLEX*)
		echo "$((2*TID))"
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
		echo "A30"
		;;
	REAL*)
		echo "E30.5"
		;;
	INTEGER*)
		echo "I30"
		;;
	LOGICAL*)
		echo "L30"
		;;
	COMPLEX*)
		echo "(E15.5,E15.5)"
		;;
	esac
}
