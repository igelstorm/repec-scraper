library(dplyr)
library(httr)
library(rvest)
library(stringi)

source("./functions.R")

################################################################################
### Configurable settings
################################################################################

# What to search for
query <- '("mental health"| depression| anxiety| well-being| wellbeing| "quality of life"| "life satisfaction"| "psychological distress") + (income*| "social security"| earning*| salar*| wage*| money| financ*| loan*| debt*| lottery| poverty| "cash transfer"| welfare) + (change*| alter*| shock*| w?n)'

# Where to save the RIS output
output_file <- "export.ris"

# What page to begin and end with (starting with 0 - important!).
from_page <- 0
to_page   <- 0 # If you want all pages, set this to something high - it will stop when it reaches the end.

# What publication type to search for
# ""      = All
# "%/a/%" = Articles
# "%/p/%" = Papers
# "%/h/%" = Chapters
# "%/b/%" = Books
# "%/c/%" = Software
publication_type <- "%/a/%"

# What to search in
# "4BFF"  = Whole record
# "F000"  = Abstract
# "0F00"  = Keywords
# "00F0"  = Title
# "000F"  = Author
search_in <- "F000"

################################################################################

references <- get_references()

references %>%
  stri_join_list(sep = "\n") %>%
  stri_write_lines(output_file, sep = "\n")

print("Done.")
if (length(failed_urls) != 0) {
  paste(length(failed_urls), "references couldn't be retrieved:") %>% print()
  print(
    data.frame(number = failed_numbers, url = failed_urls),
    right = FALSE,
    row.names = FALSE
  )
}
