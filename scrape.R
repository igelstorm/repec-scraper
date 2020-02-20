library(dplyr)
library(httr)
library(rvest)
library(stringi)

source("./functions.R")

################################################################################
### Configurable settings
################################################################################

# Where to save the RIS output
output_file <- "export.ris"

################################################################################

# TODO: these are getting modified inside the function in a dirty way.
# They should really be returned somehow or accessible another way.
failed_urls <- c()
failed_numbers <- c()

urls <- get_urls(
  query = '("mental health"| depression| anxiety| well-being| wellbeing| "quality of life"| "life satisfaction"| "psychological distress") + (income*| "social security"| earning*| salar*| wage*| money| financ*| loan*| debt*| lottery| poverty| "cash transfer"| welfare) + (change*| alter*| shock*| w?n)',
  to_page = 0,
  publication_type = "articles",
  search_in = "abstract"
)

references <- get_references(urls)

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
