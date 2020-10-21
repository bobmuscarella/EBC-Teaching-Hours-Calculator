# IEG Teaching Hours Calculator

Tools to keep track of GU teaching hours for courses at IEG (and elsehwere?).

For now, there is one function: `Count_hours.R`

Given a course schedule (downloaded from TimeEdit as a .xlsx file), the function provides a table of hours in different activity categories, as well as the total GU hours, per teacher.  

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
