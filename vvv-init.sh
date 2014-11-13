# This script was taken and modified from {vvv-dir}/database/import-sql.sh


printf "Starting your site database import in VVV\n"

# Parse through each file in the directory and use the file name to
# import the SQL file into the database of the same name
sql_count=`ls -1 *.sql 2>/dev/null | wc -l`
if [ $sql_count != 0 ]
then
    for file in $( ls *.sql )
	do
	pre_dot=${file%%.*}
	mysql_cmd='SHOW TABLES FROM `'$pre_dot'`' # Required to support hypens in database names
	db_exist=`mysql -u root -proot --skip-column-names -e "$mysql_cmd"`
	if [ "$?" != "0" ]
	then
		printf "  * \n"
        printf "  * Error - $pre_dot database does not exist! - I will create one for you now!\n"
        printf "  * \n"
        mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS $pre_dot"
        mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON $pre_dot.* TO wp@localhost IDENTIFIED BY 'wp';"
        printf "  * Database created, ready for import. Please hold.\n"
        printf "mysql -u root -proot $pre_dot < $pre_dot.sql\n"
        printf "  * \n"
        mysql -u root -proot $pre_dot < $pre_dot.sql
        printf "  * Import of $pre_dot successful\n"
	else
		if [ "" == "$db_exist" ]
		then
			printf "mysql -u root -proot $pre_dot < $pre_dot.sql\n"
			mysql -u root -proot $pre_dot < $pre_dot.sql
			printf "  * Import of $pre_dot successful\n"
		else
			printf "  * Skipped import of $pre_dot - tables exist\n"
		fi
	fi
	done
else
	printf "  * No site database found to import!\n"
fi
