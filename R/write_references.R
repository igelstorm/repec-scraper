#' Save references downloaded from RePEc IDEAS to a file
#' 
#' Saves references retrieved using \code{\link{get_references}} to a file.
#' 
#' @seealso \code{\link{repec_search}} for performing the initial search, and
#'   \code{\link{get_references}} for retrieving reference data.
#'
#' @param results A data frame containing RIS reference data.
#' @param file_name The path to write the output to.
#' @export
write_references <- function(results, file_name) {
  results$ris_data %>%
    stats::na.omit() %>%
    stringi::stri_join_list(sep = "\n") %>%
    stringi::stri_write_lines(file_name, sep = "\n")
}
