##############################################################################
# check_if_exist - check if the files / directories in the array given as a 
# parameter exist.
#
# Arguments
# - $1: Array of files / directories.
##############################################################################

SCRIPT_NAME=$0
FILES=$@

return_value=0;

# Check if user gave us the expected number of arguments.
if [ $# -eq 0 ]; then
	printf "ERROR: \"$SCRIPT_NAME\" expects a list of files / directories\n" 1>&2
	printf "\tUsage: $SCRIPT_NAME <file-0> ... <file-n>\n" 1>&2
	exit 1
fi

for file in $FILES 
do
	if [ ! -e "$file" ] ; then
		printf "ERROR: file [$file] not found\n" 1>&2
		return_value=1;
	fi
done

exit $return_value
