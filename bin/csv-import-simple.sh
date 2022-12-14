#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# define database connectivity
_db="tmp"
_db_user="root"
_db_password="toor"

# define directory containing CSV files
# _csv_directory="/var/lib/mysql-files/"
_csv_directory="/tmp/csv-import/"

# go into directory
cd $_csv_directory

# get a list of CSV files in directory
_csv_files=`ls -1 *.csv`

# loop through csv files
for _csv_file in ${_csv_files[@]}
do

  # remove file extension
  _csv_file_extensionless=`echo $_csv_file | sed 's/\(.*\)\..*/\1/'`

  # define table name
  _table_name="${_csv_file_extensionless}"

  # get header columns from CSV file
  _header_columns=`head -1 $_csv_directory/$_csv_file | tr ',' '\n' | sed 's/^"//' | sed 's/"$//' | sed 's/ /_/g'`
  _header_columns_string=`head -1 $_csv_directory/$_csv_file | sed 's/ /_/g' | sed 's/"//g'`

  # ensure table exists
  mysql -u $_db_user -p$_db_password $_db << eof
  	 DROP TABLE IF EXISTS \`$_table_name\`;
	-- TRUNCATE TABLE \`$_table_name\`;
    CREATE TABLE IF NOT EXISTS \`$_table_name\` (
      id int(11) NOT NULL auto_increment,
      PRIMARY KEY  (id)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1
eof

  # loop through header columns
  for _header in ${_header_columns[@]}
  do

    # add column
    mysql -u $_db_user -p$_db_password $_db --execute="alter table \`$_table_name\` add column \`$_header\` text"

  done

  # import csv into mysql
  mysqlimport --ignore-lines=1 --fields-enclosed-by='"' --fields-terminated-by=',' --lines-terminated-by="\n" --columns=$_header_columns_string -u $_db_user -p$_db_password $_db $_csv_directory/$_csv_file

done
exit
