count_hours <- function(infile, outfile, course_leader=NULL, exclude_no_teacher=TRUE, admin_hours=40){
  
  # Read the input file (exclude first 5 rows header)
  te <- as.data.frame(readxl::read_excel(infile, skip=5))
  
  # Exclude last extra rows
  te <- te[!is.na(te[,3]),]
  
  # Identify the column with teacher names  
  name_col <- names(te)[which(tolower(names(te)) %in% c("teacher", "staff", "personal"))]
  
  if(exclude_no_teacher){
    # Remove lines with no teacher assigned
    te <- te[!is.na(te[,name_col]),]
  }else{
    # Assign "No teacher" to moments with no teacher assigned ()
    te[,name_col][is.na(te[,name_col])] <- "No teacher"
  }
  
  # Round activity hours to nearest 0.5 (e.g., 45 min sessions get 1 hour)
  te$hours <- plyr::round_any(te$Length, 1, ceiling)
  
  ### Activity code
  # The hours assigned to each activity get multiplied to arrive at GU hours.
  # This is based on the follow multipliers: 
  # Lecture = 4 x
  # Lab, exercise = 2 x
  # Excursion, field trip, seminar = 1.5 x
  # Presentation, supervision = 1 x
  
  te$activity <- tolower(te[,grep("Reason|Moment", colnames(te))])
  
  te$multiplier <- as.numeric(dplyr::case_when(
    grepl('lecture|lab|föreläsning', te$activity) ~ "4",
    grepl('exercise|övning', te$activity) ~ "2", 
    grepl('excursion|field|seminar|exkursion|fältkurs|seminarium', te$activity) ~ "1.5",
    grepl('exam|presentation|supervision|tentamen|övervakning', te$activity) ~ "1"))
  
  te$activity_code <- as.numeric(dplyr::case_when(
    grepl('lecture|lab|föreläsning', te$activity) ~ "1",
    grepl('exercise|övning', te$activity) ~ "2", 
    grepl('excursion|field|seminar|exkursion|fältkurs|seminarium', te$activity) ~ "3",
    grepl('exam|presentation|supervision|tentamen|övervakning', te$activity) ~ "4"))
  
  if(any(is.na(te$multiplier))){
    message(paste("Warning: Activity type is not recognized in the 'Reason/Moment' column. 
You should check the following row(s) in the input spreadsheet:"))
    
    mat <- data.frame(Date=te$`Begin date`[which(is.na(te$multiplier))],
                      Time=te$`Begin time`[which(is.na(te$multiplier))],
                      Activity=te$Reason[which(is.na(te$multiplier))],
                      Teacher=te$Staff[which(is.na(te$multiplier))])
    print(mat)
    
    message("If assigned to a teacher, these hours will be multiplied by 1 and counted as 'Supervision'. 
To ensure the correct multiplier, use one of these labels in the 'Reason/Moment' column:
- lecture / lab / föreläsning (x 4)
- exercise / övning (x 2)
- excursion / seminar / exkursion / fältkurs / seminarium (x 1.5)
- exam / presentation / supervision / tentamen / övervakning (x 1)\n")
  }
  
  te$multiplier[is.na(te$multiplier)] <- 1
  
  levels(te$activity_code) <- 1:4
  te$activity_code[is.na(te$activity_code)] <- 4
  
  hrmat <- te[,c('activity','activity_code','hours','multiplier')]
  
  hrmat$GU_hours <- hrmat$multiplier * hrmat$hours
  
  # Make a list of all teachers
  teachers <- sort(unique(c(course_leader, unlist(strsplit(te[,name_col], ', ')))))
  
  # Count hours per teacher per activity
  hrsDF <- data.frame(Teacher=teachers, 
                      Administration=NA, 
                      Development=NA, 
                      Lecture=NA, 
                      Exercise=NA, 
                      Seminar_Excursion=NA, 
                      Supervision=NA, 
                      Total_GU=NA)
  
  for(i in seq_along(teachers)){
    fochrdf <- hrmat[grepl(teachers[i], te[,name_col]),]
    fochrdf$activity_code <- factor(fochrdf$activity_code, levels=1:4)
    hrsDF[i,4:7] <- tapply(fochrdf$hours, fochrdf$activity_code, sum)
    hrsDF[i,8] <- sum(fochrdf$GU_hours) + admin_hours * teachers[i] %in% course_leader
  }
  
  hrsDF[is.na(hrsDF)] <- 0
  
  # Give 40 admin hours to the course leader
  message("Notes:")
  message(ifelse(is.null(course_leader), 
                 "No course leader identified so administration hours will not be assigned.",  
                 paste("-",
                       admin_hours, 
                       "hours will be assigned to", 
                       course_leader, 
                       "as course leader.")))
  hrsDF[hrsDF$Teacher==course_leader, 'Administration'] <- admin_hours
  
  # Warning about no development hours given by this program
  message("- Development hours are not assigned by this program. Add these manually if needed and remember to update the GU hours.")
  message(paste0("- Output file is written as '", outfile, "'"))
  # Save output
  if(grepl(".xls", outfile)){
    writexl::write_xlsx(hrsDF, outfile)
  }
  
  if(grepl(".csv", outfile)){
    write.csv(hrsDF, outfile, row.names = F)
  }
  
}





