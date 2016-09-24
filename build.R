library(devtools)
library(stringr)
library(RSQLite)
library(sqldf)


#============load data into database==============
all_files <- list.files("source-data")
all_tables <- str_sub(all_files, end = -5)


db <- dbConnect(SQLite(), dbname = "pkg/inst/ext/pgw.sqlite")

for(i in 1:length(all_files)){
  tmp <- read.csv(paste0("source-data/", all_files[i]))
  print(paste("Writing", all_tables[i]))
  dbWriteTable(conn = db, name = all_tables[i], value = tmp, 
               row.names = FALSE, overwrite = TRUE)
}



#============indexing===========
