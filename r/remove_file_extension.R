#' Remove extension from file name
#'
#' @description This will be used later when we matching code files with output
#' files based on file name (assumes knitting). This regex grabs just the file
#' name without the extension. Starting at the beginning of the string (^) it
#' looks for one or more word characters followed by a period.
#'
#' @param char_vect A character vector of file names/paths
#'
#' @examples
#' #' \dontrun{
#' root_dir_file_table <- root_dir_file_table %>%
#'   mutate(
#'     file_name_no_extension = remove_file_extension(file_name_w_extension)
#'   )
#' }
remove_file_extension <- function(char_vect) {
  out <- str_extract(char_vect, "^\\w+(?=\\.)")
  out
}
