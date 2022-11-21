count_hours <- function(infile, outfile, course_leader=NULL){
  
  # Read the input file
  te <- as.data.frame(readxl::read_excel(infile, skip=5))
  
  name_col <- names(te)[which(tolower(names(te)) %in% c("teacher", "staff"))]
  
  # Remove lines with no teacher assigned
  te <- te[!is.na(te[,name_col]),]
  
  # # Get start times/dates
  # sdts <- te$`Begin date`
  # stms <- te$`Begin time`
  # s <- timeDate::timeDate(paste(sdts, stms), format = "%Y-%m-%d %H:%M")
  # 
  # # Convert start times at quarter past to one hour
  # s[grepl(':15', s)] <- s[grepl(':15', s)] - (15*60)
  # 
  # # Get end times/dates
  # edts <- te$`End date`
  # etms <- te$`End time`
  # e <- timeDate::timeDate(paste(edts, etms), format = "%Y-%m-%d %H:%M")
  
  # Count hours in each row
  # te$hours <- as.vector(e-s)
  
  # Round activity hours to nearest 0.5 (e.g., 45 min sessions get 1 hour)
  te$hours <- plyr::round_any(te$Length, 0.5)
  
  ### Activity code
  # The hours assigned to each activity get multiplied to arrive at GU hours.
  # This is based on the follow rubric multipliers: 
  # Lecture = 4 x
  # Lab, exercise = 2 x
  # Excursion, field trip, seminar = 1.5 x
  # Presentation, supervision = 1 x
  
  # The current code uses the text from the "Reason" column to determine the activity.
  te$multiplier <- ifelse(grepl("lecture", tolower(te$Reason)), 4, 
                          ifelse(grepl("lab", tolower(te$Reason)), 2, 
                                 ifelse(grepl("exercise", tolower(te$Reason)), 2, 
                                        ifelse(grepl("excursion", tolower(te$Reason)), 1.5, 
                                               ifelse(grepl("field", tolower(te$Reason)), 1.5, 
                                                      ifelse(grepl("seminar", tolower(te$Reason)), 1.5, 
                                                             ifelse(grepl("exam", tolower(te$Reason)), 1, 
                                                                    ifelse(grepl("presentation", tolower(te$Reason)), 1, 
                                                                           ifelse(grepl("supervision", tolower(te$Reason)), 1, NA)))))))))
  te$activity <- as.factor(ifelse(grepl("lecture", tolower(te$Reason)), 1, 
                                  ifelse(grepl("lab", tolower(te$Reason)), 2, 
                                         ifelse(grepl("exercise", tolower(te$Reason)), 2,
                                                ifelse(grepl("excursion", tolower(te$Reason)), 3, 
                                                       ifelse(grepl("field", tolower(te$Reason)), 3, 
                                                              ifelse(grepl("seminar", tolower(te$Reason)), 3,
                                                                     ifelse(grepl("exam", tolower(te$Reason)), 4, 
                                                                            ifelse(grepl("presentation", tolower(te$Reason)), 4, 
                                                                                   ifelse(grepl("supervision", tolower(te$Reason)), 4, NA))))))))))
  
  if(any(is.na(te$multiplier))){
    message(paste("Warning: Activity type is not recognized from the 'Reason' column. 
The following row(s) in the input spreadsheet should be checked:"))
    
    mat <- data.frame(cbind(te$Reason[which(is.na(te$multiplier))], which(is.na(te$multiplier))+6))
    names(mat) <- c("Reason","Row")
    print(mat)
    
    message("Until this is changed, these hours will be multiplied by 1 and counted as 'Supervision'. To ensure the correct multiplier, please use one of the following labels in all rows for the 'Reason' column: lecture, lab, exercise, excursion, field course, seminar, exam, presentation, or supervision.")
  }
  
  te$multiplier[is.na(te$multiplier)] <- 1
  levels(te$activity) <- 1:4
  te$activity[is.na(te$activity)] <- 4
  
  hrmat <- te[,c('activity','multiplier','hours')]
  
  hrmat$GU_hours <- hrmat$multiplier * hrmat$hours
  
  # Make a list of all teachers
  teachers <- sort(unique(c(course_leader, unlist(strsplit(te[,name_col], ', ')))))
  
  # Count hours per teacher per activity
  hrsDF <- data.frame(Teacher=teachers, 
                      Administration=NA, 
                      Development=NA, 
                      Lecture=NA, 
                      Exercise=NA, 
                      Excursion=NA, 
                      Supervision=NA, 
                      Total_GU=NA)
  
  for(i in seq_along(teachers)){
    fochrdf <- hrmat[grepl(teachers[i], te[,name_col]),]
    hrsDF[i,4:7] <- tapply(fochrdf$hours, fochrdf$activity, sum)
    hrsDF[i,8] <- sum(fochrdf$GU_hours) + 40*teachers[i] %in% course_leader
  }
  
  hrsDF[is.na(hrsDF)] <- 0
  
  # Give 40 admin hours to the course leader
  message(ifelse(is.null(course_leader), "Warning: no course leader identified so administration hours will not be assigned.",  
                 paste("Note: Course leader is identified as", course_leader)))
  hrsDF[hrsDF$Teacher==course_leader, 'Administration'] <- 40
  
  # Warning about no development hours given by this program
  message("Note: No development hours are assigned by this program. Add these manually if necessary and remember to update the total!")
  
  # Save output
  if(grepl(".xls", outfile)){
    writexl::write_xlsx(hrsDF, outfile)
    }
  
  if(grepl(".csv", outfile)){
  write.csv(hrsDF, outfile, row.names = F)
  }
  
}
