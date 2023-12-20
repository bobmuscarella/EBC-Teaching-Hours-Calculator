# IEG Teaching Hours Calculator

### Description 
A tool to keep track of GU teaching hours for IEG courses.  Given a course schedule (downloaded from TimeEdit as a .xlsx file), the functions provide ways to generate tables of hours in different activity categories, as well as the total GU hours, per teacher, per course.  

The original `count_hours.R` function was developed to count hours for a single course, instructions are below.

Newer functions enable counting of hours for multiple courses.  The general workflow for this is:

- Download one .xlsx table for all IEG staff in a given period
- Run `get_course_codes.R` to produce a table of courses included
- Edit the output course table by adding course leader 
- Run `count_hours_multi.R` to produce hour tables for each course
- Course leaders review the hour tables, edit and comment as needed
- Run `count_hours_teachers.R` to produce individual teacher hour tables
- Teachers review their table, edit and comment as needed
- Run `compile_teacher_tables.R` to produce compiled table with all annotations and checks for consistency with original TE schedule

**Detailed instructions for the `get_course_codes`, `count_hours_multi`, `count_hours_teachers`, and `compile_teacher_tables` functions will be coming soon...**


### To use the basic `count_hours.R` function
1. Download the a course schedule from the TimeEdit site as a .xls file.  This code should work with either *English* or *Swedish* versions of the schedule as long as the "Reason / Moment" column includes a word from the table above.  If needed, you can edit the text in the "Reason" column after downloading the file so that it includes one of the Activity types from the table below.

2. Open R and load the funciton by running the following code:
```{r}
source("https://raw.githubusercontent.com/bobmuscarella/EBC-Teaching-Hours-Calculator/master/Count_hours.R")
```

3. Run the function in R by typing (edit the file names and course leader name for your case):
```{r}
count_hours(infile="My_TimeEdit_File.xls", 
            outfile="My_Output_File.xlsx", 
            course_leader="Course leader", 
            exclude_no_teacher=TRUE, 
            admin_hours=40)
```

*Note: Either your input file needs to be located in the current working directory or you need to specify the full file path.

### Arguments
  - `infile`: A course schedule (downloaded from TimeEdit as a .xls or .xlsx file).  If the path is not included, this needs to be located in the working directory.
  - `outfile`: The desired name of the output file (ending in .csv or .xlsx).  If the path is not included, it will be saved in the working directory.
  - `course_leader`: The name of the course leader for assigning administration hours.
  - `exclude_no_teacher`: Disregard information from class sessions with no teacher named.
  - `admin_hours`: Assign administrative hours to the course leader (default is 40 hrs).

### Required packages
A few packages are required for this function to work:

- [readxl](https://readxl.tidyverse.org/): Allows you to read into R the excel spreadsheet.
- [plyr](https://github.com/hadley/plyr): Needed for rounding hours.
- [dplyr](https://github.com/hadley/plyr): Needed for text operations.
- [writexl](https://docs.ropensci.org/writexl/): Only needed if you want to write an .xlsx file but not if you want to write a .csv file as output.

You can install these packages with this code:
```{r}
install.packages("readxl")
install.packages("plyr")
install.packages("dplyr")
install.packages("writexl")
```

### Details
Correctly assigning hours to a certain activity (and thus getting the correct GU multiplier for hours) depends on the "Reason / Moment" column from the TimeEdit schedule.  To ensure the correct GU multiplier for each activity, please include one of the activities from the table below in the 'Reason' column for all rows.  The scheduled hours for each of these activities get multiplied differently when computing the total number of GU hours.  We use the following table:

| Activity | Activity Code | Hour Multiplier | 
|:----------|:-------------:|:------------:|
| Lecture *or* Föreläsning |  1 | 4 |
| Lab | 2 | 2 |
| Exercise *or* Övning | 2 | 2 |
| Field course *or* Fältkurs | 3 | 1.5 |
| Excursion *or* Exkursion | 3 | 1.5 |
| Seminar *or* Seminarium | 3 | 1.5 |
| Exam *or* Tentamen | 4 | 1 |
| Presentation | 4 | 1 |
| Supervision *or* Övervakning | 4 | 1 | 

*Note: Development hours are **not** assigned by this program. If desired, you need to add these manually and remember to update the total GU hours in the output file.

Any questions / issues?  Just tell Bob <robert.muscarella@ebc.uu.se>.

