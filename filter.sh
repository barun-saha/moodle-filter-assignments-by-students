#!/bin/bash

#
# This script is intended to filter out assignements of selected students
# identified by name from a bunch of files belonging to all the students in
# a given course.
#
# This script is originally created for the PDS Lab, Section 9, IIT Kharagpur,
# but can be used for other purposes as well. Since roll # or any unique
# identifier is not available with the files submitted, we need to filter them
# by names of students. Again since one can change display of name in Moodle, we
# need to verify that this script filters out the desired number of files.
#
# This script should be placed in a directory where the unzipped directories
# containing the assignment files are located. The script should be executed
# from the same directory. Filtered out codes would be moved to the submissions/
# directory that would be created by this script.
#
# Sample directory structure before executing the script:
# filter.sh
# PDS Lab Section 9-Assignment 3a [Weekday]-2508/
# PDS Lab Section 9-Assignment 3b [Elements in an Interval]-2510/
#
# Sample directory structure *after* executing the script:
# filter.sh
# PDS Lab Section 9-Assignment 3a [Weekday]-2508/
# PDS Lab Section 9-Assignment 3b [Elements in an Interval]-2510/
# submissions/PDS Lab Section 9-Assignment 3a [Weekday]-2508/
# submissions/PDS Lab Section 9-Assignment 3b [Elements in an Interval]-2510/
# 
#
# @author barun
# @date 2016-08-19
#
# Copyright 2016, Barun Saha, http://barunsaha.me
# Distributed under GNU GPLv3 license. See the LICENSE file for details.
#


### Configuration variables ###

# Set it to true if the submitted files are C programs and you want to compile
# them. On successful compilation, an executable file with same name as the 
# source file together with a .out extension will be generated. 
# Set this variable to false if the submissions are not C programs or you
# do not want to compile them.
SHOULD_COMPILE=true
# Set it to true if you want to display all warnings and errors generated
# while compiling the programs. Useful to set it to false if you expect large
# number of compilation errors.
SHOULD_SHOW_COMPILATION_ERRORS=false


# Names of students whose assignements are to be filtered out. These must match
# with the names as set in Moodle.
NAMES=('Prateek Manikpuri' 'Thitthi Roja' 'Ayush Jaiswal' \
'Pawan Kumar Kashyap' 'Amrita Biswas' 'Naman Agarwal' 'Viraj Patel' 
'Amit Kumar' 'Debmalya Roy' 'Kailash Hudda' 'Mohit Kosuri' 'Shreyank Shukla' \
'Akshay Telmasare' 'Hemanth P S')
# Number of names, i.e., # of files to be segregated
NENTRIES=${#NAMES[@]}

# Name of the course as displayed in Moodle. Names of directories containing
# assignments begin with this pattern.
COURSE_LABEL='PDS Lab Section'
# Directory where filtered out submissions would be created
SUBMISSIONS_DIR=submissions

# Color codes for display
RED='\033[0;31m'
BROWN='\033[0;33m'
NC='\033[0m'

# Get a list of all working directories ans store them in an array
ASSIGNMENT_DIRS=("$COURSE_LABEL"*)

if [ ! -d "$SUBMISSIONS_DIR" ]
then
    mkdir "$SUBMISSIONS_DIR"
fi

# Remove the executables created earlier, if any. In a later step, gcc
# would compile *all* files present in a directory and therefore, only source
# code should be present there. The cleaning should be done before hand to
# verify files count.
echo 'Cleaning up pre-existing executables, if any ...'
find "$SUBMISSIONS_DIR" -type f -name "*.out" -delete


echo ''
echo 'Beginning filtering operation ...'

for adir in "${ASSIGNMENT_DIRS[@]}"
do
    # Zip files of the submissions may be present in the concerned directory.
    # Ignore them and only process the directories.
    if [ ! -d "$adir" ]
    then
        continue
    fi
    
    # This is where filtered code files would be copied
    target_dir="$SUBMISSIONS_DIR/$adir"
    copy_dir="../$target_dir/"
    echo 'Processing directory '"$target_dir"
    
    if [ ! -d "$target_dir" ]
    then
        mkdir "$target_dir"
    fi

    for sname in "${NAMES[@]}"
    do
        cd "$adir"

        # Loop over all files whose name matches with names of students
        # without matching case
        # http://stackoverflow.com/a/2596474/147021
        # http://stackoverflow.com/a/9612560/147021
        find * -iname "$sname*" -print0 | while read -d $'\0' fname
        do
            cp "$fname" "$copy_dir"
        done
        
        cd ..
    done
    
    # Count the # of files copied -- should be equal to the # of students
    # http://unix.stackexchange.com/a/90152/3879
    count=$(ls -afq "$target_dir" | wc -l)
    count=$(expr $count - 2)
    
    if [[ $count -lt $NENTRIES ]]
    then
        echo -e "${BROWN}* ALERT: Found only $count (out of required $NENTRIES) files in $target_dir${NC}"
    fi
done


if [ "$SHOULD_COMPILE" = true ]
then
    echo ''
    echo 'Beginning source code compilation ...'

    # Now visit each directory, compile code, and generate the executables
    for adir in "${ASSIGNMENT_DIRS[@]}"
    do
        if [ ! -d "$adir" ]
        then
            continue
        fi
        
        cd "$SUBMISSIONS_DIR/$adir"
        echo 'Processing '"$SUBMISSIONS_DIR/$adir"
        
        find * -print0 | while read -d $'\0' fname
        do
            # gcc expects a .c extension. If someone has missed it, use "-x c" to
            # signal gcc to treat the file as source code.
            # Also, executables generated typically do not have any extension.
            # However, since one might forget to add a .c extension to the
            # source code, a .out extension is added to executables to safely 
            # identify them.
            if [ "$SHOULD_SHOW_COMPILATION_ERRORS" = true ]
            then
                gcc -Wall -lm -x c "$fname" -o "$fname".out
            else
                gcc -Wall -lm -x c "$fname" -o "$fname".out 2>/dev/null
            fi
            
            if [[ $? -ne 0 ]]
            then
                echo -e ${RED}'*** ERROR in compiling file: '"$SUBMISSIONS_DIR/$adir/$fname"${NC}
            fi
        done
        
        cd ../..
    done
fi

echo 'Done!'
