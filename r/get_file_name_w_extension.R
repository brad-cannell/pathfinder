#' Get File Names With Extensions
#'
#' @description Here we create a variable of short names for each file under
#' the root directory. These short names will be used to name list elements
#' later.
#' This regex starts scanning from the end of the string ($) for one or
#' more (+) non-whitespace characters (\S) preceeded by ((?<=) is a
#' Lookbehind) a forward slash.
#'
#' @param char_vect A character vector of file names/paths
#'
#' @examples
#' \dontrun{
#' get_file_name_w_extension(root_dir_file_list)
#' }
get_file_name_w_extension <- function(char_vect) {
  out <- stringr::str_extract(char_vect, "(?<=\\/)\\S+$")
  out
}
