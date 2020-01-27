library(rvest)
library(dplyr)

query <- '("mental health"| depression| anxiety| well-being| wellbeing| "quality of life"| "life satisfaction"| "psychological distress") + (income*| "social security"| earning*| salar*| wage*| money| financ*| loan*| debt*| lottery| poverty| "cash transfer"| welfare) + (change*| alter*| shock*| w?n)'
url <- "https://ideas.repec.org/search.html"
max_pages <- 100

session <- html_session(url)

search_form <- html_form(session)[[3]] %>%
  set_values(
    ul = "%/a/%",
    q = query
  )

first_page <- session %>%
  submit_form(search_form)
  
result_url <- first_page %>%
  html_node("a.page-link") %>%
  html_attr("href")

result_urls <- list()

for (i in 0:max_pages) {
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
