library(rvest)
library(dplyr)

################################################################################
### Configurable settings
################################################################################

# What to search for
query <- '("mental health"| depression| anxiety| well-being| wellbeing| "quality of life"| "life satisfaction"| "psychological distress") + (income*| "social security"| earning*| salar*| wage*| money| financ*| loan*| debt*| lottery| poverty| "cash transfer"| welfare) + (change*| alter*| shock*| w?n)'

# How many pages to try looking at - although it will stop automatically when
# there are no results, so this doesn't matter too much as long as it's high
# enough.
max_pages <- 100

################################################################################




################################################################################
# Step 1: Visit each "results" page and store the URLs for each result.
################################################################################

url <- "https://ideas.repec.org/search.html"

# Initiate a session (necessary to submit the search form)
session <- html_session(url)

# Set the inputs in the form to desired values ("ul" is publication type)
search_form <- html_form(session)[[3]] %>%
  set_values(
    ul = "%/a/%",
    q = query
  )

# Submit the form and keep hold of the results page
first_page <- session %>%
  submit_form(search_form)

# Get the generic URL for a "results" page for later use
result_url <- first_page %>%
  html_node("a.page-link") %>%
  html_attr("href")

result_urls <- list() # an empty list to store the results in

# Visit each results page, and store the URL for each result on it
for (i in 0:max_pages) {
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
  
  paste("Results on page", i + 1, ":")
  result_urls[[i + 1]] <- urls_on_this_page
  print(urls_on_this_page)
}

result_urls <- unlist(result_urls)

paste("Found", length(result_urls), "results.")
