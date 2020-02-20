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

results <- get_results(
  query = '("mental health"| depression| anxiety| well-being| wellbeing| "quality of life"| "life satisfaction"| "psychological distress") + (income*| "social security"| earning*| salar*| wage*| money| financ*| loan*| debt*| lottery| poverty| "cash transfer"| welfare) + (change*| alter*| shock*| w?n)',
  to_page = 0,
  publication_type = "articles",
  search_in = "abstract"
) %>%
  get_references()

results$ris_data
results$ris_data %>%
  na.omit() %>%
  stri_join_list(sep = "\n") %>%
  stri_write_lines(output_file, sep = "\n")

print("Done.")

failures <- results[is.na(results$ris_data),]

if (length(failures$url) != 0) {
  paste(length(failures$url), "references couldn't be retrieved:") %>% print()
  print(failures)
}
