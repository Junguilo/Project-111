#!/bin/bash
# If we need to load or delete the database ./test.sh here
rm -f Checkpoint2-dbase.sqlite
touch Checkpoint2-dbase.sqlite
db="Checkpoint2-dbase.sqlite"
sqlite3 Checkpoint2-dbase.sqlite < Checkpoint2-script.sql
sqlite3 $db < empty-tables.sql
sqlite3 $db < load-tpch.sql
