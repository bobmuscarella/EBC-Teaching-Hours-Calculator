# IEG Teaching Hours Calculator

### Description 
A tool to keep track of GU teaching hours for IEG courses.  Given a course schedule (downloaded from TimeEdit as a .xlsx file), the function provides a table of hours in different activity categories, as well as the total GU hours, per teacher.  For now, this requires an English version of the schedule to be downloaded from TimeEdit but we can make a Swedish version easily if that is of interest.  The tool uses one R function: `count_hours.R`

### Arguments
  - `infile`: A course schedule (downloaded from TimeEdit as a .xls file - **currently must be in English, including column headings!**).  If the path is not included, this needs to be located in the working directory.
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

### To use
1. Download the a course schedule from the TimeEdit site as a .xls file.  This code should work with either *English* or *Swedish* versions of the schedule as long as the "Reason / Moment" column includes a word from the table above.

* Note: If needed, you can edit the text in the "Reason" column after downloading so that it includes one of the Activity types from the table above.

2. Open R and load the funciton by running the following code:
```{R}
source("https://raw.githubusercontent.com/bobmuscarella/EBC-Teaching-Hours-Calculator/master/Count_hours.R")
```

3. Run the function in R by typing:
```{R}
count_hours("My_TimeEdit_File.xls", "My_Output_File.xlsx", "Course leader")
```

*Notes: 
  - The program will assign 40 hours for administration to the person you designate as Course Leader.
  - Either your input file needs to be located in your working directory or you should specify the full path to the file.
  - You need to edit the arguments to reflect your input file, desired output file name, and the name of the course leader.

Any questions / issues?  Just tell Bob <robert.muscarella@ebc.uu.se>.

