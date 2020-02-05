library(dplyr)
library(httr)
library(rvest)

################################################################################
### Configurable settings
################################################################################

# What to search for
query <- '("mental health"| depression| anxiety| well-being| wellbeing| "quality of life"| "life satisfaction"| "psychological distress") + (income*| "social security"| earning*| salar*| wage*| money| financ*| loan*| debt*| lottery| poverty| "cash transfer"| welfare) + (change*| alter*| shock*| w?n)'

# Where to save the RIS output
output_file <- "export.ris"

# What page to begin and end with (starting with 0 - important!).
from_page <- 0
to_page   <- 100 # If you want all pages, set this to something high - it will stop when it reaches the end.

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




if (file.exists(output_file)) {
  stop("Output file already exists. If you want to replace it, please delete it first (I'm too scared to do that automatically).")
}

url <- "https://ideas.repec.org/search.html"

################################################################################
# Step 1: Visit each "results" page and store the URLs for each result.
################################################################################

# Initiate a session (necessary to submit the search form)
session <- html_session(url)

# Set the inputs in the form to desired values
search_form <- html_form(session)[[3]] %>%
  set_values(
    ul = publication_type,
    q = query,
    wf = search_in
  )

# Submit the form and keep hold of the results page
first_page <- submit_form(session, search_form)

# Get the generic URL for a "results" page for later use
result_url <- first_page$url

result_urls <- list() # an empty list to store the results in

# Visit each results page, and store the URL for each result on it
for (i in from_page:to_page) {
  # In order to request a specific page, we need to use the result URL with a
  # query parameter e.g. "&np=1" appended. First page is i=0.
  result_page <- session %>%
    jump_to(result_url, query = list(np = i))
  
  urls_on_this_page <- result_page %>%
    html_node("ol.list-group") %>%
    html_nodes("li") %>%
    html_nodes("a") %>%
    html_attr("href")

  if (length(urls_on_this_page) == 0) {
    print("No more results.")
    break
  }
  
  paste("Results on page", i + 1) %>% print()
  result_urls[[i + 1]] <- urls_on_this_page
  print(urls_on_this_page)
}

result_urls <- unlist(result_urls)

paste("Found", length(result_urls), "results.") %>% print()




################################################################################
# Step 2: Visit the page for each result, and save its reference.
################################################################################

failed_urls <- c()
failed_numbers <- c()

for (i in 1:length(result_urls)) {
  # Visit the result URL, and request a reference in RIS format
  paste("Result", i, ":", result_urls[[i]]) %>% print()
  
  tryCatch(
    {
      result_page <- session %>%
        jump_to(result_urls[[i]])
      
      export_reference_form <- html_form(result_page)[[3]] %>%
        set_values(output = "3") # "3" corresponds to "RIS (EndNote, RefMan, ProCite)"
      
      reference_response <- submit_form(session, export_reference_form)
      
      # Append the RIS reference to the output file
      ris_data <- content(reference_response$response, "text") %>% trimws()
      cat(ris_data, "\n", file= output_file, append = TRUE)
    },
    error = function(cond) {
      # TODO: Don't use <<- here - it's an antipattern. Probably better to extract some functions so we can return a status or something
      failed_urls <<- c(failed_urls, result_urls[[i]])
      failed_numbers <<- c(failed_numbers, i)
    }
  )
}

print("Done.")
if (length(failed_urls) != 0) {
  paste(length(failed_urls), "references couldn't be retrieved:") %>% print()
  print(
    data.frame(number = failed_numbers, url = failed_urls),
    right = FALSE,
    row.names = FALSE
  )
}
