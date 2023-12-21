count_hours_multi <- function(infile, 
                              outpath, 
                              course_leaders=NULL, 
                              course_codes=NULL,
                              exclude_no_teacher=TRUE, 
                              admin_hours=40){
  
  require(officer)
  
  # Initialize object to hold a list of all course tables, original from TE
  course_list <- list()
  
  # Create the output file structure ()
  dir.create(paste0(outpath, "Courses_for_review"))
  dir.create(paste0(outpath, "OG_data"))

  # Read the input file (exclude first 5 rows header)
  teall <- as.data.frame(readxl::read_excel(infile, skip=5))
  
  # Loop through the individual courses included in the multi-course schedule downloaded from TimeEdit
  for(i in seq_along(course_codes)){
    
    # Subset the i course
    te <- teall[grepl(course_codes[i], teall$`Course signatur`),]
    
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
    te$Length <- strptime(te$`End time`, format='%H:%M') - strptime(te$`Begin time`, format='%H:%M')
    te$hours <- plyr::round_any(as.numeric(te$Length)/60, 1, ceiling)
    
    ### Activity code
    # The hours assigned to each activity get multiplied to arrive at GU hours.
    # This is based on the follow multipliers: 
    # Lecture = 4 x
    # Lab, exercise = 2 x
    # Excursion, field trip, seminar = 1.5 x
    # Presentation, supervision = 1 x
    
    # Get the activity for each session
    te$activity <- tolower(te[,grep("Reason|Moment", colnames(te))])
    
    te$multiplier <- as.numeric(dplyr::case_when(
      grepl('lecture|föreläsning', te$activity) ~ "4",
      grepl('exercise|lab|övning', te$activity) ~ "2", 
      grepl('excursion|field|seminar|exkursion|fältkurs|seminarium', te$activity) ~ "1.5",
      grepl('exam|presentation|supervision|tentamen|övervakning', te$activity) ~ "1"))
    
    te$activity_code <- as.numeric(dplyr::case_when(
      grepl('lecture|föreläsning', te$activity) ~ "1",
      grepl('exercise|lab|övning', te$activity) ~ "2", 
      grepl('excursion|field|seminar|exkursion|fältkurs|seminarium', te$activity) ~ "3",
      grepl('exam|presentation|supervision|tentamen|övervakning', te$activity) ~ "4"))
    
    if(any(is.na(te$multiplier))){
      base::message(paste("Warning: Activity type is not recognized in the 'Reason/Moment' column. 
Specifically in the following row(s) from the input spreadsheet from TimeEdit:"))
      
      mat <- data.frame(Date=te$`Begin date`[which(is.na(te$multiplier))],
                        Start_time=te$`Begin time`[which(is.na(te$multiplier))],
                        Activity=te$Reason[which(is.na(te$multiplier))],
                        Teacher=te[,name_col][which(is.na(te$multiplier))])
      print(mat)
      
      base::message("If assigned to a teacher, these hours have been multiplied by 1 and counted as 'Supervision'. To ensure the correct multiplier, use one of these labels in the 'Reason/Moment' column:
- lecture / föreläsning (x 4)
- exercise / lab / övning (x 2)
- excursion / seminar / exkursion / fältkurs / seminarium (x 1.5)
- exam / presentation / supervision / tentamen / övervakning (x 1)\n")
    }
    
    te$multiplier[is.na(te$multiplier)] <- 1
    
    levels(te$activity_code) <- 1:4
    te$activity_code[is.na(te$activity_code)] <- 4
    
    hrmat <- te[,c('activity','activity_code','hours','multiplier')]
    
    hrmat$GU_hours <- hrmat$multiplier * hrmat$hours
    
    # Make a list of all teachers
    teachers <- sort(unique(c(course_leaders[i], unlist(strsplit(te[,name_col], ', ')))))
    
    # Count hours per teacher per activity
    hrsDF <- data.frame(Teacher=teachers, 
                        Administration=NA, 
                        Development=NA, 
                        Lecture=NA, 
                        Exercise=NA, 
                        Seminar_Excursion=NA, 
                        Supervision=NA, 
                        Total_GU=NA)
    
    for(tch in seq_along(teachers)){
      fochrdf <- hrmat[grepl(teachers[tch], te[,name_col]),]
      fochrdf$activity_code <- factor(fochrdf$activity_code, levels=1:4)
      hrsDF[tch,4:7] <- tapply(fochrdf$hours, fochrdf$activity_code, sum)
      hrsDF[tch,8] <- sum(fochrdf$GU_hours) + admin_hours * teachers[tch] %in% course_leaders[i]
    }
    
    hrsDF[is.na(hrsDF)] <- 0
    
    # Give 40 admin hours to the course leader
    base::message("Notes:")
    base::message(ifelse(is.null(course_leaders[i]), 
                         "No course leader identified so administration hours will not be assigned.",  
                         paste("-",
                               admin_hours, 
                               "hours will be assigned to", 
                               course_leaders[i], 
                               "as course leader.")))
    if(!is.na(course_leaders[i])){
      hrsDF[hrsDF$Teacher==course_leaders[i], 'Administration'] <- admin_hours
    }
    
    # Warning about no development hours given by this program
    base::message("- Development hours are not assigned by this program. Add these manually if needed and remember to update the GU hours.")
    
    font1 <- fp_text(color = "blue", bold = TRUE, font.size = 14)
    font2 <- fp_text(font.size = 12)
    font3 <- fp_text(color = "red", font.size = 12)
    font4 <- fp_text(font.size = 8)
    
    fpar1 <- fpar(ftext(paste0("Report for TimeEdit hour counting of ", course_codes[i], 
                               " (", te$Course[1],")"), prop=font1))
    
    fpar2 <- fpar(ftext(ifelse(is.null(course_leaders[i]), 
                               "No course leader identified so administration hours will not be assigned.",  
                               paste("-",
                                     admin_hours, 
                                     "hours were assigned to", 
                                     course_leaders[i], 
                                     "as course leader.")), prop=font2))
    
    fpar3 <- fpar(ftext("- Development hours are not assigned by this program. Add these manually if needed and remember to update the GU hours.", prop=font2))
    
    if(exists("mat")){
      fpar4 <- fpar(ftext(paste("Warning: Activity type is not recognized in the 'Reason/Moment' column. 
Specifically, the following row(s) in the input spreadsheet from TimeEdit:"), prop=font3))
      
      fpar5 <- fpar(ftext("If assigned to a teacher, these hours were multiplied by 1 and counted as 'Supervision'. To ensure the correct multiplier, you need to use one of the following labels in the 'Reason/Moment' column when building your TimeEdit schedule:", prop=font3))
      
      fpar6 <- fpar(ftext("- lecture / lab / föreläsning (x 4)", prop=font2))
      fpar7 <- fpar(ftext("- exercise / övning (x 2)", prop=font2))
      fpar8 <- fpar(ftext("- excursion / seminar / exkursion / fältkurs / seminarium (x 1.5)", 
                          prop=font2))
      fpar9 <- fpar(ftext("- exam / presentation / supervision / tentamen / övervakning (x 1)", 
                          prop=font2))
    }
    
    fpar11 <- fpar(ftext(paste0("Report generated ", Sys.Date(), 
                                " based on file: '", infile, 
                                "' and course signature(s) ", 
                                paste(unique(te$`Course signatur`), collapse="; ")),
                         prop=font4))
    
    mydoc <- read_docx()
    mydoc <- body_add_fpar(mydoc, fpar1)
    mydoc <- body_add_fpar(mydoc, fpar11)
    mydoc <- body_add_par(mydoc, "")
    mydoc <- body_add_fpar(mydoc, fpar2)
    mydoc <- body_add_par(mydoc, "")
    mydoc <- body_add_fpar(mydoc, fpar3)
    mydoc <- body_add_par(mydoc, "")
    
    if(exists("mat")){
      
      library(flextable)
      ft <- flextable(mat)
      ft <- theme_vanilla(ft)
      ft <- fontsize(ft, size=8)
      ft <- autofit(ft)
      
      mydoc <- body_add_fpar(mydoc, fpar4)
      mydoc <- body_add_par(mydoc, "")
      mydoc <- body_add_flextable(mydoc, ft)
      mydoc <- body_add_par(mydoc, "")
      mydoc <- body_add_fpar(mydoc, fpar5)
      mydoc <- body_add_par(mydoc, "")
      mydoc <- body_add_fpar(mydoc, fpar6)
      mydoc <- body_add_fpar(mydoc, fpar7)
      mydoc <- body_add_fpar(mydoc, fpar8)
      mydoc <- body_add_fpar(mydoc, fpar9)
      rm(mat)
      rm(ft)
    }
    
    # Write the report
    print(mydoc, target=paste0(outpath, "Courses_for_review/", course_codes[i], "_Report.docx"))
    
    # Write the .xlsx files for review
    Course_leader_comments <- data.frame(Course_leader_comments=rep("", nrow(hrsDF)))
    hrsDF$Course_Leader <- as.character(hrsDF$Teacher == course_leaders[i])
    hrsDF <- cbind(course_codes[i], hrsDF)
    names(hrsDF)[1] <- "Code"
    course_list[[i]] <- hrsDF
    names(course_list)[i] <- course_codes[i]
    writexl::write_xlsx(cbind(hrsDF, Course_leader_comments), 
                        paste0(outpath, "Courses_for_review/", course_codes[i], ".xlsx"))

    # Write the OG data
    saveRDS(course_list, file=paste0(paste0(outpath, "OG_data/"), gsub(".xlsx", "", basename(infile)), ".RDA"))
    
  }
}






