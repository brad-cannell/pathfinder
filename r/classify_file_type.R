#' Classify File Type
#'
#' @description Given a file extention, this function returns one of three
#' types: code, data, or output.
#'
#' Right now I'm just manually telling R which category each file extension I
#' explicitly mention below goes in. Eventually, I'd like to figure out a better
#' way to do this.
#'
#' @param char_vect A character vector containing file extensions
#'
#' @examples
#' \dontrun{
#' get_file_extension(root_dir_file_list)
#' }
classify_file_type <- function(char_vect) {
  code_extentions   <- c("py", "R", "Rmd")
  data_extentions   <- c("csv", "feather", "rds", "xls", "xlsx")
  output_extentions <- c(
    "bmp", "doc", "docx", "eps", "html", "jpeg", "jpg",
    "nb.html", "pdf", "png", "ps", "svg", "tex", "tiff", "wmf"
  )
  char_vect[char_vect %in% code_extentions]   <- "code"
  char_vect[char_vect %in% data_extentions]   <- "data"
  char_vect[char_vect %in% output_extentions] <- "output"
  char_vect[is.na(char_vect)] <- "other"
  char_vect
}
