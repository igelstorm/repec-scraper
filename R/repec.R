#' Search the RePEc IDEAS database.
#' 
#' `repec_search` performs a search and returns the results as a data frame.
#' 
#' @param query The search terms to use.
#' @param from_page Integer describing which page of results to start on (the first page is 0).
#' @param to_page Integer describing which page of results to end on.
#' @param publication_type String describing which publication type to search. Possible values: `all`, `articles`, `papers`, `chapters`, `books`, `software`
#' @param search_in String describing which fields to search in. Possible values: `whole_record`, `abstract`, `keywords`, `title`, `author`
#' @return A data frame containing the URL for each search result.
#' @importFrom magrittr %>%
#' @export
repec_search <- function(query,
                        from_page = 0,
                        to_page = 1000,
                        publication_type = "all",
                        search_in = "whole_record") {
  url <- "https://ideas.repec.org/search.html"

  session <- rvest::html_session(url)

  # Fill in and submit the search form
  search_form <- rvest::html_form(session)[[3]] %>%
    rvest::set_values(
      ul = publication_type(publication_type),
      q = query,
      wf = search_in(search_in)
    )
  first_page <- rvest::submit_form(session, search_form)

  # Get the generic URL for a "results" page for later use
  result_url <- first_page$url

  result_urls <- list() # an empty list to store the results in

  # Visit each results page, and store the URL for each result on it
  for (i in from_page:to_page) {
    # In order to request a specific page, we need to use the result URL with a
    # query parameter e.g. "&np=1" appended. First page is i=0.
    result_page <- session %>%
      rvest::jump_to(result_url, query = list(np = i))

    urls_on_this_page <- result_page %>%
      rvest::html_node("ol.list-group") %>%
      rvest::html_nodes("li") %>%
      rvest::html_nodes("a") %>%
      rvest::html_attr("href")

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

#' @export
get_references <- function(results) {
  results$ris_data <- lapply(results$url, get_reference)
  results
}

publication_type <- function(name) {
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

search_in <- function(name) {
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

url_from <- function(path) {
  url <- urltools::url_parse("https://ideas.repec.org/")
  url$path <- path
  urltools::url_compose(url)
}

#' @importFrom magrittr %>%
get_reference <- function(path) {
  tryCatch(
    {
      session <- rvest::html_session(url_from(path))

      export_reference_form <- rvest::html_form(session)[[3]] %>%
        rvest::set_values(output = "3") # "3" corresponds to "RIS (EndNote, RefMan, ProCite)"

      reference_response <- rvest::submit_form(session, export_reference_form)

      ris_data <- httr::content(reference_response$response, "text") %>% trimws()
      ris_data
    },
    error = function(cond) {
      NA
    }
  )
}
