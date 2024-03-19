count_hours_teachers <- function(inpath=NULL, 
                                 outpath=NULL,
                                 original_TE_file=NULL){
  
  # Create directory to hold teacher hour tables
  dir.create(paste0(outpath, "Teachers_for_review"))
  
  # Get list of course hour table files and course codes
  files <- list.files(inpath, pattern = ".xlsx")
  codes <- tools::file_path_sans_ext(files)

  # Initialize a list to hold hours per course
  course_hours_list <- list()

  # Read in all course hour tables  
  for(f in seq_along(files)){
    tmp <- readxl::read_excel(paste0(inpath, files[f]))
    course_hours_list[[f]] <- tmp
  }
  
  # Condense course hour table into a data.frame
  hours_table <- do.call(rbind, course_hours_list)
  
  # Extract all teacher names from the condensed course hour table
  teachers <- sort(unique(hours_table$Teacher))
  
  # Build an hour table for each teacher
  for(i in seq_along(teachers)){
    
    # Subset hours for the i teacher
    tmp <- hours_table[hours_table$Teacher %in% teachers[i],]
    
    # Sum the table hours
    GU_check_1 <- tmp$Administration + 
      tmp$Development + 
      (tmp$Lecture * 4) +
      (tmp$Exercise * 2) +
      (tmp$Seminar_Excursion * 1.5) +
      tmp$Supervision
    
    # # T/F if table hours summed = table GU hours
    # tmp$GU_check_1 <- as.character(GU_check_1 == tmp$Total_GU)
    
    # Overwrite GU hours in table to be internally correct 
    tmp$Total_GU <- GU_check_1
      
    # Load original TE data
    og <- do.call(rbind, readRDS(original_TE_file))
    
    # T/F if table GU hours match OG TE GU hours
    tmp$GU_check_1 <- as.character(og$Total_GU[og$Teacher==teachers[i]] == GU_check_1)
    
    for(r in 1:nrow(tmp)){
      if(tmp$GU_check_1[r]=="FALSE"){
        tmp$GU_check_1[r] <- paste0("Table hours = ", 
                                    GU_check_1, 
                                    ", TimeEdit hours = ", 
                                    og$Total_GU[og$Teacher==teachers[i]])
      }
    }
    
    # Add column for teacher comments
    Teacher_comments <- data.frame(Teacher_comments=rep("", nrow(tmp)))
    
    # Write the .xlsx files for review
    writexl::write_xlsx(cbind(tmp, Teacher_comments), 
                        paste0(outpath, "Teachers_for_review/", teachers[i], ".xlsx"))
  }
}


