# Filter Assignments by Students

Moodle allows downloading of all submissions by students for any given
assignment as a zip file. When the number of students is large, these
are often divided among multiple people for checking and subsequent
grading. However, it is tedious to find and segregate the files for
a specific set of students among all the submissions. This script is
intended to help in such scenarios.

To use this filtering script, you need to provide the names of the
concerned students as well as name of the course as displayed in Moodle.
For further details, look at the documentation in the `filter.sh` file.


## How to use it?

1. Download the submissions (`.zip` files) from Moodle and store them
inside a directory where the `filter.sh` script is located.
2. Unzip the files to extract the submissions.
3. Execute `bash filter.sh` in a terminal.

The `submissions/` directory would be created containing all the
filtered assignment files.

Note: All the submissions are assumed to be C programs. Change the
compiler or comment out the compilation step altogether if you require
so.
