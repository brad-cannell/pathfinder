#' Get File Extension
#'
#' @description Given a file name with an extention (e.g.,
#' analysis_descriptive.Rmd), This function returns the extension.
#'
#' This regex starts scanning from the beginning of the string for one or more
#' (+) non-whitespace characters (\\S) preceeded by ((?<=) is a Lookbehind) a
#' period.
#'
#' @param char_vect A character vector containing file names with extensions
#'
#' @examples
#' \dontrun{
#' get_file_extension(root_dir_file_list)
#' }
get_file_extension <- function(char_vect) {
  out <- stringr::str_extract(char_vect, "(?<=\\.)\\S+")
  out
}
