# Compile a table for Plant Eco Evo



filelist <- list.files(full.names=T)[grepl("2024", list.files())]

d <- data.frame()
for(p in 1:4){
  file <- list.files(paste0(filelist, "/Compilation"), full.names=T)[p]
  x <- readxl::read_xlsx(file)
  x$period <- p
  d <- rbind(x, d)
}


url <- "https://docs.google.com/spreadsheets/d/1zfKNOv4wPi5iaXze-gZDyvoFmEhgdHTL13Y2pHU0q3s/edit?gid=0#gid=0"
s <- googlesheets4::read_sheet(url)
staff <- paste(s$`First Name`, s$`Last Name`)

# Check teacher list who are *not* registered at Plant Eco Evo
sort(unique(d$Teacher[!d$Teacher %in% staff]))

# Subset to Plant Program
d <- as.data.frame(d[d$Teacher %in% staff,])


d <- d[order(d$Teacher),1:10]
write.csv(d, "/Users/au529793/Desktop/Plant-teaching-hours-2024.csv", row.names = F)


write.csv(tapply(d$Total_GU_reported, d$Teacher, sum), 
          "/Users/au529793/Desktop/Plant-teaching-hours-2024-totalGU.csv")


