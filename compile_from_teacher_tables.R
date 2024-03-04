compile_teacher_tables <- function(inpath=NULL, 
                                   outpath=NULL, 
                                   original_TE_file=NULL){
  
  files <- list.files(inpath, full.names = T)
  teachers <- basename(gsub(".xlsx", "", files))
  
  res <- list()
  
  # Load teacher files
  for(i in seq_along(files)){
    
    tmp <- readxl::read_xlsx(files[i])
    
    # See if summed table hours match GU hour column
    GU_check_2 <- tmp$Administration + 
      tmp$Development + 
      (tmp$Lecture * 4) +
      (tmp$Exercise * 2) +
      (tmp$Seminar_Excursion * 1.5) +
      tmp$Supervision
      
      # # T/F if summed table hours match GU hour column
      # tmp$GU_check_2 <- as.character(GU_check_2 == tmp$Total_GU)
      
      # Give details for when table hours don't sum to GU hours
      # for(r in seq_along(nrow(tmp))){
      #   if(tmp$GU_check_2[r]=="FALSE"){
      #     tmp$GU_check_2[r] <- paste0("Hours x multipliers add to ", 
      #                                 GU_check_2, 
      #                                 ". Reported GU hours = ", tmp$Total_GU)
      #   }
      # }
      
    # Overwrite GU hours in table to be internally correct 
    tmp$Total_GU <- GU_check_2
    
    res[[i]] <- tmp
    }
  
  out <- do.call(rbind, res)
  
  og <- do.call(rbind, readRDS(original_TE_file))
  
  names(out)[which(names(out) == "Total_GU")] <- "Total_GU_reported"
  out$OG_TE_GU_hours <-  og$Total_GU[match(paste(out$Code, out$Teacher), paste(og$Code, og$Teacher))] 
  
  out$GU_check_2 <- as.character(out$OG_TE_GU_hours == out$Total_GU_reported)
  
  for(r in 1:nrow(out)){
    if(out$GU_check_2[r]=="FALSE"){
      out$GU_check_2[r] <- paste0("Table hours = ", 
                                  out$Total_GU_reported[r], 
                                  ", TimeEdit hours = ", 
                                  og$Total_GU[match(paste(out$Code, out$Teacher)[r], 
                                                    paste(og$Code, og$Teacher))])
    }
  }
  
  dir.create(paste0(outpath, "Compilation"))
  writexl::write_xlsx(out, 
                      paste0(outpath, "Compilation/Compiled_", 
                             gsub(".RDA", "", basename(original_TE_file)), ".xlsx"))
  
}


