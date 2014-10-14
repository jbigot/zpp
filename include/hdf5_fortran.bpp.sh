source fortran.bpp.sh

# Returns the HDF5 type constant associated to the one letter type descriptor $1
hdf5_constant()
{
	eval "echo -n \${HDF5CST_$1}"
}

HDF5TYPES=''
for T in ${FORTTYPES}
do
	if [ -n "$(hdf5_constant $T)" ]
	then
		HDF5TYPES="${HDF5TYPES}${T} "
	fi
done
