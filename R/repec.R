#' Search the RePEc IDEAS database
#' 
#' Automatically searches RePEc IDEAS and, returns the results as a data frame.
#' 
#' The output of this function will be a data frame that only contains the URL
#' for each search result, and no other information. In order to fetch the full
#' reference, you will need to pass this data frame to the
#' \code{\link{get_references}} function, which will visit each URL and extract
#' the full reference data.
#' 
#' These URLs are more or less permanent (i.e. they are not specific to each
#' search, and do not expire), so once a search has been made, it should be safe
#' to save these URLs and fetch the full references using
#' \code{\link{get_references}} at a later stage. In other words, if the exact
#' timing of the search is important to you, it should only matter when you run
#' \code{\link{repec_search}}, not when you run \code{\link{get_references}}.
#' 
#' @seealso \code{\link{get_references}} for fetching the full reference for
#'   each search result, and \code{\link{write_references}} for saving the
#'   references to a file.
#' 
#' @param query The search terms to use.
#' @param from_page Integer describing which page of results to start on (the
#'   first page is 0).
#' @param to_page Integer describing which page of results to end on.
#' @param publication_type String describing which publication type to search.
#'   Possible values: `all`, `articles`, `papers`, `chapters`, `books`,
#'   `software`
#' @param search_in String describing which fields to search in. Possible
#'   values: `whole_record`, `abstract`, `keywords`, `title`, `author`
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

#' Fetch full references for search results from RePEc IDEAS
#' 
#' Automatically fetches full reference data for a list of search results
#' returned by the \code{\link{repec_search}} function.
#' 
#' @seealso \code{\link{repec_search}} for performing the initial search, and
#'   \code{\link{write_references}} for saving the references to a file.
#' 
#' @param results A data frame containing the URLs of one or more RePEc search
#'   results (see \code{\link{repec_search}}).
#' @return A new data frame, with reference data for each search result added.
#' @export
get_references <- function(results) {
  results$ris_data <- lapply(results$url, get_reference)
  results
}

#' Save references downloaded from RePEc IDEAS to a file
#' 
#' Saves references retrieved using \code{\link{get_references}} to a file.
#' 
#' @seealso \code{\link{repec_search}} for performing the initial search, and
#'   \code{\link{get_references}} for retrieving reference data.
write_references <- function(results, file_name) {
  results$ris_data %>%
    stats::na.omit() %>%
    stringi::stri_join_list(sep = "\n") %>%
    stringi::stri_write_lines(file_name, sep = "\n")
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
