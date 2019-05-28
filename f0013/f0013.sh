#!/usr/bin/env bash

# get folder and start_name
input_folder=$1
start_name=$2
output_file=$3

# concat all csv files
# only keep the header of the first file if all files have the same header
awk 'FNR==1 && NR!=1{next;}{print}' $input_folder/$start_name*.csv >> $output_file
