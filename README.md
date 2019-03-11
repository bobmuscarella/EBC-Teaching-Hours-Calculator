# EBC teaching hours calculator

Tools to keep track of teaching hours for courses at EBC.

For now, there is one script: `Count_hours.R`

Given a course schedule (output from TimeEdit as an Excel file), that script can provide a table of course hours per teacher.  For now, the user needs to manually add a column (named "Code") to the TimeEdit schedule (*before* starting the script) to assign activities to four classes: Lectures, Labs, Excursions, and Presentations/Supervision.  The scheduled hours for each of these activities get multiplied differently when computing the total number of hours.


| Activity | Acitivity Code | Hour Multiplier | 
|:----------|:-------------:|:------------:|
| Lecture |  1 | 4 |
| Lab | 2 | 2 |
| Excursion | 3 | 1.5 |
| Presentation, Supervision | 4 | 1 |
