library(sqldf)

pgw <-  "pkg/inst/ext/pgw.sqlite"
db <- dbConnect(SQLite(), dbname = "pkg/inst/ext/pgw.sqlite")




#===========Number of books per character=====
sql <- "SELECT * FROM vw_NumberBooks"

dbGetQuery(db, sql)


#==============number of characters per book=================
sql <- "
SELECT 
  count(c.CharacterID) as NumberCharacters, 
  b.Title, b.Published
FROM 
  books b,
  characters c,
  bookscharacters bc
WHERE b.BookID = bc.BookID AND c.CharacterID = bc.CharacterID
GROUP BY b.BookID
ORDER by NumberCharacters, Published
"

dbGetQuery(db, sql)




#==========characters in a particular book===========
sql <- "
SELECT 
Prefix,  First,  Nickname, Last, c.Title
FROM 
books b,
characters c,
bookscharacters bc
WHERE b.BookID = bc.BookID AND c.CharacterID = bc.CharacterID
AND b.Title = 'Ice in the Bedroom'
"

dbGetQuery(db, sql)

#==========books with a particular character===========
sql <- "
SELECT 
  b.Title
FROM 
  books b,
  characters c,
  bookscharacters bc
WHERE b.BookID = bc.BookID AND c.CharacterID = bc.CharacterID
AND c.First = 'Rupert' AND c.Last = 'Baxter'
"

sql <- "
SELECT 
  b.Title, b.Published
FROM 
  books b,
  characters c,
  bookscharacters bc
WHERE b.BookID = bc.BookID AND c.CharacterID = bc.CharacterID
AND c.First = 'Constance'
ORDER BY Published
"


dbGetQuery(db, sql)



#==============books with no characters=================
sql <- "
SELECT * from (
    SELECT 
      count(bc.CharacterID) as NumberCharacters, 
      b.Title,
      b.Published
    FROM 
      books b
    LEFT JOIN
      bookscharacters bc
    ON b.BookID = bc.BookID
    GROUP BY b.Title
    ORDER by NumberCharacters
  )
  WHERE NumberCharacters = 0
  ORDER BY Published
"

dbGetQuery(db, sql)



#========number of jobs==========
sql <- "
SELECT count(Job) as n, Job
FROM charactersjobs
GROUP BY job
ORDER by n
"
dbGetQuery(db, sql)







dbDisconnect(db)

