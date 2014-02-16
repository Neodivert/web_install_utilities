###############################################################################
# Get mysql user password - Keep asking user for his/her administrative MySQL 
# password until a right one is writen.
#
# Arguments:
# 	$1 - Path to mysql command.
###############################################################################

SCRIPT_NAME=$0
MYSQL_COMMAND=$1
mysql_password=""


# Auxiliar function - Read MySQL password from user
###############################################################################

function read_mysql_password(){
	local mysql_password

	# Message displayed to user.
	user_msg="Write your database administrative password (Used for login in phpmyadmin): "

	# Read mysql password from user and return it.
	read -e -s -r -p "$user_msg" mysql_password

	echo $mysql_password
}


# Auxiliar function - Check MySQL password given by user
###############################################################################

function check_mysql_password(){
	local mysql_password=$1
	local mysql_command=$2
	
	# Check the previous password by trying to connect to MySQL server and checking
	# the return value.
	"$mysql_command" --user="root" --password="$mysql_password" -e "exit" >/dev/null 2>&1

	echo $?
}


# Main
###############################################################################

# Check if user gave us the expected number of arguments.
if [ $# -ne 1 ]; then
	printf "ERROR: \"$SCRIPT_NAME\" expects a path string\n" 1>&2
	printf "\tUsage: $SCRIPT_NAME <MySQL path>\n" 1>&2
	exit 1
fi

# Read the MySQL password from user.
mysql_password=`read_mysql_password`

# Keep asking the user for his/her password until a right one is writen.
while [[ $( check_mysql_password "$mysql_password" "$MYSQL_COMMAND" ) -ne 0 ]] ;
do
	printf "\nWrong password!\n" 1>&2

	mysql_password=`read_mysql_password`
done

echo "$mysql_password"
