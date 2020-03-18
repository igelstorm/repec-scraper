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

url_from <- function(path) {
  url <- urltools::url_parse("https://ideas.repec.org/")
  url$path <- path
  urltools::url_compose(url)
}
