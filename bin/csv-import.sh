#!/usr/bin/env bash

# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" \]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- 
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# Performance Tip(1) :- More over you can define table definition into Mysql after first import
# select * from tableName procedure analyse()
# 
# Performance Tip(2) :- open CSV with excel and do column wise = max(len(RANGE:RANGE)) 
# and assign value to data type in mysql
# 
# I personaly like (2) approach to complete this kind of job with +5 increment of data length for feature.


#!/bin/bash

# show commands being executed, per debug
# set -x

# define database connectivity
_db="csv"
_db_user="root"
_db_password="toor"
_db_host="localhost"
_db_port="3306"

# mysql_config_editor set --login-path=local --host=localhost --user=username --password

# To avoide :- [Warning] Using a password on the command line interface can be insecure.
# Usage for mysqldump --defaults-extra-file=$credentialsFile .....
# Usage for mysql --defaults-extra-file=$credentialsFile .....
credentialsFile="/tmp/mysql-credentials.cnf"
echo "[client]" > $credentialsFile
echo "user=$_db_user" >> $credentialsFile
echo "password=$_db_password" >> $credentialsFile
echo "host=$_db_host" >> $credentialsFile

# define directory containing CSV files
_csv_directory="/var/lib/mysql-files/csv"

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

  # Ensure table exists
  mysql --defaults-extra-file=$credentialsFile  $_db << eof
	-- DROP TABLE IF EXISTS \`$_table_name\`;
	-- TRUNCATE TABLE \`$_table_name\`;
	CREATE TABLE IF NOT EXISTS \`$_table_name\` (
	  id int(11) NOT NULL auto_increment,
	  PRIMARY KEY  (id)
	) ENGINE=MyISAM DEFAULT CHARSET=latin1;
eof

  # loop through header columns
  for _header in ${_header_columns[@]}
  do
	  # add column
	  mysql --defaults-extra-file=$credentialsFile $_db --execute="alter table \`$_table_name\` add column $_header text"
  done

  # import csv into mysql and change parameter as per CSV format.
  # --fields-enclosed-by='"' \
  mysqlimport \
	  --ignore-lines=1 \
	  --fields-terminated-by=',' \
	  --lines-terminated-by="\n" \
	  --columns=$_header_columns_string \
	  -u $_db_user \
	  -p$_db_password \
	  $_db $_csv_directory/$_csv_file

  done

  rm $credentialsFile
  echo "CSV import [ DONE ] ."
  exit
