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
  if(all_tables[i] == "characters"){
    # Construct the "UsualRef" variable as the single column name for most purposes.
    # If there's on in the CSV use that; otherwise use Nickname Lastname if possible,
    # or Prefix, First name, Last name, Title.  This seems to work. 
    tmp <- tmp %>%
      mutate(UsualRef = ifelse(UsualRef != "", as.character(UsualRef),
                               ifelse(Nickname == "", paste(Prefix, First, Last, Title), 
                                      paste(Nickname, Last))),
             UsualRef = str_trim(UsualRef),
             UsualRef = gsub("  ", " ", UsualRef),
             UsualRef = gsub("  ", " ", UsualRef))
     }
  
  
  print(paste("Writing", all_tables[i]))
  dbWriteTable(conn = db, name = all_tables[i], value = tmp, 
               row.names = FALSE, overwrite = TRUE)
}


#======create views===========
sql <- "
CREATE VIEW vw_NumberBooks AS
SELECT 
  count(b.Title) as NumberBooks, 
  c.CharacterID, UsualRef
FROM 
  books b,
  characters c,
  bookscharacters bc
WHERE b.BookID = bc.BookID AND c.CharacterID = bc.CharacterID
GROUP BY c.CharacterID
ORDER BY NumberBooks
"
try(dbGetQuery(db, "DROP VIEW vw_NumberBooks"))
dbGetQuery(db, sql)



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
