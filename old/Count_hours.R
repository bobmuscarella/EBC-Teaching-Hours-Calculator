require(xlsx)
require(readxl)
require(timeDate)

# Read in the TimeEdit excel file schedule
te <- readxl::read_excel('TimeEdit_2019-03-08_15_58_EDITED.xls', skip=5)

# Remove lines with no teacher assigned
te <- te[!is.na(te$Teacher),]

# Get start times/dates
sdts <- te$`Begin date`
stms <- te$`Begin time`
s <- timeDate::timeDate(paste(sdts, stms), format = "%Y-%m-%d %H:%M")

# Convert start times at quarter past to one hour
s[grepl(':15', s)] <- s[grepl(':15', s)] - (15*60)

# Get end times/dates
edts <- te$`End date`
etms <- te$`End time`
e <- timeDate::timeDate(paste(edts, etms), format = "%Y-%m-%d %H:%M")

# Count hours
hrvec <- as.vector((e-s)/60)

# Add the activity code
# For now, this needs to be manually added as a column named 'Code' to the Excel sheet prior to starting this script.
# Each row with a teacher needs a code.
# The hours assigned to each activity code get multiplied differently for the total working hours
# Codes: 1=lecture, 2=lab, 3=excursion, 4=presentation, supervision
# Hour multipliers: Lecture = x4, Lab = x2, Excursion = x1.5, Presentation, supervision = x1
hrmat <- data.frame(code=as.factor(te$Code), hrvec)

# Make a list of all teachers
teachers <- sort(unique(unlist(strsplit(te$Teacher, ', '))))

# Count hours per teacher per activity
hrsDF <- data.frame(Teacher=teachers, Administration=NA, Development=NA, 
                    Lecture=NA, Lab=NA, Excursion=NA, Supervision=NA)
for(i in seq_along(teachers)){
  fochrdf <- hrmat[grepl(teachers[i], te$Teacher),]
  hrsDF[i,4:7] <- tapply(fochrdf$hrvec, fochrdf$code, sum)
}
hrsDF[is.na(hrsDF)] <- 0

# Give 40 admin hours to the course coordinator
cc <- 'Robert Muscarella'
hrsDF[hrsDF$Teacher==cc,'Administration'] <- 40

# Give Development hours?
hrsDF[hrsDF$Teacher==cc,'Development'] <- 10

# Add a Total column per teacher (including activity multipliers)
hrsDF$Total <- rowSums(hrsDF[,c(2,3,7)]) + (hrsDF[,4] * 4) + (hrsDF[,5] * 2) + (hrsDF[,6] * 1.5)

# View output
hrsDF

# Save output
outfile <- 'Teaching_hours_1BG324_Ekol_met.xlsx'
xlsx::write.xlsx(hrsDF, outfile, row.names = F)
