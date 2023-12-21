# Demo script

# 0. source the functions

url <- "https://raw.githubusercontent.com/bobmuscarella/EBC-Teaching-Hours-Calculator/master/"

source(paste0(url, "count_hours_multi.R"))
source(paste0(url, "count_hours_teachers.R"))
source(paste0(url, "get_course_codes.R"))
source(paste0(url, "compile_from_teacher_tables.R"))








# 1. get_course_codes

# Set the infile as the .xlsx file downloaded from TimeEdit.
infile="/demo/TimeEdit_2023-12-20_13_20.xlsx"

# Run the function
get_course_codes(infile, test_course_leader=T)


# 2. course_list_multi



### PARAMETERS FOR TESTING
infile="/demo/TimeEdit_2023-12-20_13_20.xlsx"
outpath="/demo/"

course_list <- readxl::read_xlsx(paste0(dirname(infile), "/Course_list_", basename(infile)))

course_leaders=course_list$course_leader
course_codes=course_list$code

exclude_no_teacher=TRUE
admin_hours=40


### TEST THE FUNCTION
count_hours_multi(infile=infile,
                  outpath=outpath,
                  course_leaders=course_leaders,
                  course_codes=course_codes,
                  exclude_no_teacher=exclude_no_teacher,
                  admin_hours=admin_hours)



### PARAMETERS FOR TESTING
inpath="/Users/au529793/Desktop/test-My_Multi-Output/Courses_for_review/"
outpath="/Users/au529793/Desktop/test-My_Multi-Output/"
original_TE_file="/Users/au529793/Desktop/test-My_Multi-Output/OG_data/TimeEdit_2023-12-20_13_20.RDA"


### TEST THE FUNCTION
count_hours_teachers(inpath=inpath,
                     outpath=outpath,
                     original_TE_file=original_TE_file)






### PARAMETERS FOR TESTING
inpath="/Users/au529793/Desktop/test-My_Multi-Output/Teachers_for_review/"
outpath="/Users/au529793/Desktop/test-My_Multi-Output/"
original_TE_file="/Users/au529793/Desktop/test-My_Multi-Output/OG_data/TimeEdit_2023-12-20_13_20.RDA"


### TEST THE FUNCTION
compile_teacher_tables(inpath=inpath,
                       outpath=outpath,
                       original_TE_file=original_TE_file)


### FUNCTION CODE



