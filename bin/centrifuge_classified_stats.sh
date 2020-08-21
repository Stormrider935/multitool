#!/bin/env bash

# folder with fastq files
for i in /*.fastq; 
    do
        filename=$()
        readcount=$(echo $(cat $i|wc -l)/4|bc)
