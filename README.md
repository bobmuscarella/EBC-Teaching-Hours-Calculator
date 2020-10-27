# IEG Teaching Hours Calculator

### Description 
A tool to keep track of GU teaching hours for IEG courses.  Given a course schedule (downloaded from TimeEdit as a .xlsx file), the function provides a table of hours in different activity categories, as well as the total GU hours, per teacher.  For now, this requires an English version of the schedule to be downloaded from TimeEdit but we can make a Swedish version easily if that is of interest.  The tool uses one R function: `count_hours.R`

### Arguments
`infile`: A course schedule (downloaded from TimeEdit as a .xlsx file - currently must be in English).  If the path is not included, this needs to be located in the working directory.

`outfile`: The desired name of the output file (ending in .xlsx).  If the path is not included, it will be saved in the working directory.

`course_leader`: The name of the course leader for assigning administration hours.

### Details
Correctly assigning hours to a certain activity (and thus getting the correct GU multiplier for hours) depends on the "Reason" column from the TimeEdit schedule.  To ensure the correct GU multiplier for each activity, please include one of the activities from the table below in the 'Reason' column for all rows.  The scheduled hours for each of these activities get multiplied differently when computing the total number of GU hours.  We use the following table:

| Activity | Activity Code | Hour Multiplier | 
|:----------|:-------------:|:------------:|
| Lecture |  1 | 4 |
| Lab | 2 | 2 |
| Exercise | 2 | 2 |
| Field course | 3 | 1.5 |
| Excursion | 3 | 1.5 |
| Seminar | 3 | 1.5 |
| Exam | 4 | 1 |
| Presentation | 4 | 1 |
| Supervision | 4 | 1 |

*Note: Development hours are **not** assigned by this program. If desired, you need to add these manually and remember to update the total GU hours in the output file.

### To use
1. Download the course schedule to be analyzed from TimeEdit site as a .xlsx file.

2. Open R and load the funciton by running the following code:
```{R}
source("https://raw.githubusercontent.com/bobmuscarella/EBC-Teaching-Hours-Calculator/master/Count_hours.R")
```
3. Run the function in R by typing:
```{R}
count_hours("My_TimeEdit_File.xls", "My_Output_File.xlsx", "Course leader")
```
*Note: You need to edit the arguments to reflect your input file, desired output file name, and the name of the course leader.

*Note: Either your input file needs to be located in your working directory or you should specify the full path to the file.
