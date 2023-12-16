### PARAMETERS FOR TESTING
inpath="/Users/au529793/Desktop/test-My_Multi-Output/Courses_for_review/"
outpath="/Users/au529793/Desktop/test-My_Multi-Output/"


### TEST THE FUNCTION
count_hours_teachers(inpath=inpath,
                     outpath=outpath)

### FUNCTION CODE
count_hours_teachers <- function(inpath=NULL, 
                                 outpath=NULL){
  
  dir.create(paste0(outpath, "Teachers_for_review"))
  
  files <- list.files(inpath, pattern = ".xlsx")
  codes <- tools::file_path_sans_ext(files)

  course_hours_list <- list()
  
  for(f in seq_along(files)){
    tmp <- readxl::read_excel(paste0(inpath, files[f]))
    course_hours_list[[f]] <- tmp
  }
  
  hours_table <- do.call(rbind, course_hours_list)
  
  teachers <- sort(unique(hours_table$Teacher))
  
  for(i in seq_along(teachers)){
    
    tmp <- hours_table[hours_table$Teacher %in% teachers[i],]
    
    GU_check_1 <- tmp$Administration + 
      tmp$Development + 
      (tmp$Lecture * 4) +
      (tmp$Exercise * 2) +
      (tmp$Seminar_Excursion * 1.5) +
      tmp$Supervision
    
    tmp$GU_check_1 <- as.character(GU_check_1 == tmp$Total_GU)
    
    for(r in seq_along(nrow(tmp))){
      if(tmp$GU_check_1[r]=="FALSE"){
        
        tmp$GU_check_1[r] <- paste0("Hours x multipliers add to ", 
                                    GU_check_1, ". Reported GU hours = ", tmp$Total_GU)
      }
    }
    
    # Write the .xlsx files for review
    Teacher_comments <- data.frame(Teacher_comments=rep("", nrow(tmp)))
    writexl::write_xlsx(cbind(tmp, Teacher_comments), 
                        paste0(outpath, "Teachers_for_review/", teachers[i], ".xlsx"))
  }
}



