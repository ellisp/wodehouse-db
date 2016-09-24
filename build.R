library(devtools)
library(stringr)
library(RSQLite)
library(sqldf)

db <- dbConnect(SQLite(), dbname = "pkg/inst/ext/pgw.sqlite")


#============load data into database==============
all_files <- list.files("source-data")
all_tables <- str_sub(all_files, end = -5)


for(i in 1:length(all_files)){
  tmp <- read.csv(paste0("source-data/", all_files[i]))
  print(paste("Writing", all_tables[i]))
  dbWriteTable(conn = db, name = all_tables[i], value = tmp, 
               row.names = FALSE, overwrite = TRUE)
}


#=======tests============
# Identify:
# all bookscharacters.BookID in books.BookID
# all bookscharacters.CharacterID in characters.CharacterID

#========validation and future work========
# Identiy: 
# books with few or no characters
# characters with no books
# characters with no jobs




#============indexing===========


#==========views==============
# eg one that knocks out the reshashes
