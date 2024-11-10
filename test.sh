#!/bin/bash

rm -f score.res
rm -f Checkpoint2-dbase.sqlite
touch Checkpoint2-dbase.sqlite

sqlite3 Checkpoint2-dbase.sqlite < Checkpoint2-script.sql
