# Demo script

# 0. source the functions

url <- "https://raw.githubusercontent.com/bobmuscarella/EBC-Teaching-Hours-Calculator/master/Functions/"

source(paste0(url, "count_hours_multi.R"))
source(paste0(url, "count_hours_teachers.R"))
source(paste0(url, "get_course_codes.R"))
source(paste0(url, "compile_from_teacher_tables.R"))

# 1. get_course_codes

# Set the infile as the .xlsx file downloaded from TimeEdit.
infile="demo/TimeEdit_2024-02-13_13_10.xlsx"

# Run the function
get_course_codes(infile, test_course_leader=F)

# 2. Normally, you would open the file produced ("demo/Course_list_TimeEdit_2023-12-20_13_20.xlsx") and manually add course leaders (also check to make sure all desired courses are included).

# 3. course_list_multi

# Read in the file produced in the last step (after adding course leaders)
course_list <- readxl::read_xlsx(paste0(dirname(infile), "/Course_list_", basename(infile)))

count_hours_multi(infile=infile,
                  outpath="demo/",
                  course_leaders=course_list$course_leader,
                  course_codes=course_list$code,
                  exclude_no_teacher=TRUE,
                  admin_hours=40)

# 4. Count hours teachers

count_hours_teachers(inpath="demo/Courses_for_review/",
                     outpath="demo/",
                     original_TE_file="demo/OG_data/TimeEdit_2023-12-20_13_20.RDA")


# 5. Compile from teacher tables

### TEST THE FUNCTION
compile_teacher_tables(inpath="demo/Teachers_for_review",
                       outpath="demo/",
                       original_TE_file="demo/OG_data/TimeEdit_2023-12-20_13_20.RDA")


