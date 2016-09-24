library(RSQLite)
library(dplyr)
library(tidyr)
library(igraph)

# db <- dbConnect(SQLite(), dbname = "pkg/inst/ext/pgw.sqlite")

sql <- "
SELECT 
  c1.UsualRef as Name1,
  c2.UsualRef as Name2,
  Links
FROM
  (SELECT
    count(1) as Links,
    Char1,
    Char2
  FROM
    (SELECT *
      FROM
        (SELECT 
          CharacterID as Char1,
          BookID as BookID
        FROM
          bookscharacters
        WHERE
          BookID is not null) a
      JOIN
        (SELECT 
          CharacterID as Char2,
        BookID as BookID
        FROM
        bookscharacters
        WHERE
        BookID is not null) b
      ON
        a.BookID = b.BookID
      WHERE Char1 > Char2)
  GROUP BY Char1, Char2)
LEFT JOIN
  vw_NumberBooks c1
ON
  c1.CharacterID = Char1
LEFT JOIN
  vw_NumberBooks c2
ON
  c2.CharacterID = Char2
WHERE
  c1.NumberBooks > 1
ORDER BY Links
  "

# this next bit doesn't work, should be reworked from bottom up.  Gives a vague indicative idea though.

numberlinks <- dbGetQuery(db, sql) 



bothways <- numberlinks %>%
  rbind(data_frame(Name1 = numberlinks$Name2, Name2 = numberlinks$Name1, Links = numberlinks$Links)) %>%
  group_by(Name1, Name2) %>%
  summarise(Links = sum(Links) / 2)


distances <- bothways %>%
  mutate(Distance = 1 / Links + .5) %>%
  select(-Links) %>%
  spread(Name2, Distance, fill = 2) 

sql <- "SELECT UsualRef as Name, NumberBooks FROM vw_NumberBooks"
sizes <- dbGetQuery(db, sql)


characters <- as.data.frame(cmdscale(jitter(as.matrix(distances[ , -1]), factor = 5))) %>%
  mutate(Name = distances$Name1) %>%
  left_join(sizes, by = "Name")

g <- graph_from_data_frame(numberlinks, directed = TRUE, vertices = characters$Name)

plot(g, 
     edge.arrow.size = 0, edge.curved = TRUE, edge.color = "grey89",
     vertex.frame.color = "grey98", vertex.color = "wheat1", 
     vertex.label.cex = 0.8,
     vertex.label.color = "darkviolet",
     vertex.size = characters$NumberBooks,
     layout = as.matrix(characters[ , c("V1", "V2")]))

