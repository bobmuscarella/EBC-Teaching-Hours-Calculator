get_course_codes <- function(infile=NULL, 
                             test_course_leader=FALSE, 
                             courses_to_skip=c("1BG411", "1BG405", 
                                               "1BG600", "1BG602", "1BG604", "1BG606", "1BG607")){
  
  # Read the input file (exclude first 5 rows header)
  teall <- as.data.frame(readxl::read_excel(infile, skip=5))

  # Find the 'course signature' column 
  # It was wisely renamed since an update of TE to a duplicate column name 'course'
  foccol <- which(names(teall) %in% c("`Course signatur", "Course...23"))
  
  teall <- teall[!is.na(teall[,foccol]),]

  teall$code <- sapply(strsplit(teall[,foccol], "-"), function(x) x[[1]])
    
  # Remove courses identified as online only or for whatever reason
  teall <- teall[!teall$code %in% courses_to_skip,]
  
  codes <- sort(unique(teall$code))
  
  # Sometimes we have multiple signatures for a given course code.  We want to keep the multiple signatures in the 'signature' column but aggregate the rows based on course code.
  out <- aggregate(teall$`Course signatur`, 
                   by=list(teall$code), 
                   FUN=function(x) paste(unique(x), collapse="; "))
  
  names(out) <- c("code", "signature")
  
  out$course_name <- teall$Course[match(out$code, teall$code)]
  
  out$course_leader <- NA
  
  # FOR TESTING: TO ADD A TEMP TEST COURSE LEADER
  if(test_course_leader){
  out$course_leader <- sapply(strsplit(teall$Staff[match(out$code, teall$code)], ","), function(x) x[[1]])
  }
  
  writexl::write_xlsx(out, paste0(dirname(infile), "/Course_list_", basename(infile)))
  
}
