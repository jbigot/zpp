source fortran.bpp.sh

HDF5TYPES='INTEGER REAL REAL8 CHARACTER'

# Returns the HDF5 type constant associated to the one letter type descriptor $1
hdf5_constant()
{
	case "$1" in
	'REAL8')
		echo -n 'H5T_NATIVE_DOUBLE'
		;;
	'REAL'|'CHARACTER'|'INTEGER')
		echo -n "H5T_NATIVE_${1}"
		;;
	esac
}
