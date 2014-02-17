##############################################################################
# init_database.sh - create a MySQL database and a user with privileges on
# it.
#
# Arguments
#	- $1 : path to mysql command.
#	- $2 : mysql administrative password.
#	- $3 : name for both database and user.
# 	- $4 : user password.
#	- $5 : sql file the database will be imported from.
##############################################################################

# Constants
N_EXPECTED_ARGUMENTS=5;
SCRIPT_NAME=$0
DB_USER_PRIVILEGES="DELETE, INSERT, SELECT, UPDATE"

# Arguments
MYSQL_COMMAND=$1
MYSQL_PASSWORD=$2
DB_NAME=$3
DB_USER_NAME=$3
DB_USER_PASSWORD=$4
SQL_FILE=$5

# Check if user gave us the expected number of arguments.
if [ $# -ne $N_EXPECTED_ARGUMENTS ]; then
	printf "ERROR: \"$SCRIPT_NAME\" expects $N_EXPECTED_ARGUMENTS arguments ($# given)\n" 1>&2
	printf "\tUsage: $SCRIPT_NAME <mysql_command> <mysql_password> <db_name> <db_password> <sql_file>\n" 1>&2
	exit 1
fi

# Check if user gave us a sql file that exists.
if [ ! -f SQL_FILE ]; then
	printf "ERROR: file [%s] not found\n" $SQL_FILE 1>&2
fi

# Create the database
printf "Creating database [%s] ...\n" "${DB_NAME}"
"$MYSQL_COMMAND" -u root --password="${MYSQL_PASSWORD}" -e "create database ${DB_NAME}"
if [ $? -ne 0 ] ; then
	exit 1
fi
printf "Creating database [%s] ...OK\n" "${DB_NAME}"

# Import the database's structure and data from given file.
printf "Importing database structure and data from file [%s] ...\n" "$SQL_FILE"
"$MYSQL_COMMAND" -u root --password="${MYSQL_PASSWORD}" "${DB_NAME}" < "$SQL_FILE"
if [ $? -ne 0 ] ; then
	exit 1
fi
printf "Importing database structure and data from file [%s] ...OK\n" "$SQL_FILE"

# Create the database user.
printf "Creating mysql user [%s] ...\n" "${DB_USER_NAME}"
"$MYSQL_COMMAND" -u root --password="${MYSQL_PASSWORD}" -e "CREATE USER '${DB_USER_NAME}'@'localhost' IDENTIFIED BY '${DB_USER_PASSWORD}';"
if [ $? -ne 0 ] ; then
	exit 1
fi
printf "Creating mysql user [%s] ...OK\n" "${DB_USER_NAME}"

# Allow the created user to perfom certain operations on the database.
printf "Giving [%s] privileges to user [%s] ...\n" "${DB_USER_PRIVILEGES}" "${DB_USER_NAME}"
"$MYSQL_COMMAND" -u root --password="${MYSQL_PASSWORD}" -e "GRANT ${DB_USER_PRIVILEGES} ON ${DB_NAME}.* TO '${DB_USER_NAME}'@'localhost';"
if [ $? -ne 0 ] ; then
	exit 1
fi
"$MYSQL_COMMAND" -u root --password="${MYSQL_PASSWORD}" -e "FLUSH PRIVILEGES;"
if [ $? -ne 0 ] ; then
	exit 1
fi
printf "Giving [%s] privileges to user [%s] ...OK\n" "${DB_USER_PRIVILEGES}" "${DB_USER_NAME}"

exit 0

