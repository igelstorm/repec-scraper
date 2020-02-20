library(urltools)

get_results <- function(query,
                        from_page = 0,
                        to_page = 1000,
                        publication_type = "all",
                        search_in = "whole_record") {
  url <- "https://ideas.repec.org/search.html"
  
  session <- html_session(url)
  
  # Fill in and submit the search form
  search_form <- html_form(session)[[3]] %>%
    set_values(
      ul = .publication_type(publication_type),
      q = query,
      wf = .search_in(search_in)
    )
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
  
  result_urls <- unlist(result_urls, use.names = FALSE)
  
  paste("Found", length(result_urls), "results.") %>% print()
  
  data.frame(url = result_urls)
}

get_references <- function(results) {
  results$ris_data <- lapply(results$url, .get_reference)
  results
}

.publication_type <- function(name) {
  switch(
    name,
    "all" = "",
    "articles" = "%/a/%",
    "papers" = "%/p/%",
    "chapters" = "%/h/%",
    "books" = "%/b/%",
    "software" = "%/c/%",
    stop("Unknown publication type.")
  )
}

.search_in <- function(name) {
  switch(
    name,
    "whole_record" = "4BFF",
    "abstract" = "F000",
    "keywords" = "0F00",
    "title" = "00F0",
    "author" = "000F",
    stop("Unknown field to search in.")
  )  
}

.url_from <- function(path) {
  url <- url_parse("https://ideas.repec.org/")
  url$path <- path
  url_compose(url)
}

.get_reference <- function(path) {
  tryCatch(
    {
      session <- html_session(.url_from(path))
      
      export_reference_form <- html_form(session)[[3]] %>%
        set_values(output = "3") # "3" corresponds to "RIS (EndNote, RefMan, ProCite)"
      
      reference_response <- submit_form(session, export_reference_form)
      
      ris_data <- content(reference_response$response, "text") %>% trimws()
      ris_data
    },
    error = function(cond) {
      NA
    }
  )
}
