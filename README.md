# IEG Teaching Hours Calculator

### Description 
A tool to keep track of GU teaching hours for IEG courses.  Given a course schedule (downloaded from TimeEdit as a .xlsx file), the function provides a table of hours in different activity categories, as well as the total GU hours, per teacher.  For now, there is one function: `count_hours.R`

### Arguments
`infile`: A course schedule (downloaded from TimeEdit as a .xlsx file).

`outfile`: The name of the output file (ending in .xlsx).

`course_leader`: The name of the course leader for assigning administration hours.

### Details
Correctly assigning hours to a certain activity (and thus getting the correct GU multiplier for hours) depends on the "Reason" column from the TimeEdit schedule.  To ensure the correct GU multiplier for each activity, please include one of the activities from the table below in the 'Reason' column for all rows.  The scheduled hours for each of these activities get multiplied differently when computing the total number of GU hours.  We use the following table:

| Activity | Acitivity Code | Hour Multiplier | 
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

Note: No development hours are assigned by this program. If desired, you need to add these manually and remember to update the total GU hours in the output file.

### To use
1. Download the course schedule to be analyzed from TimeEdit site as a .xlsx file.
2. Download the file `count_hours.R`.
3. Open R type: 

```{R}
source(count_hours.R)
```
