#' Test To See If There Is An .Rproj File At The Root
#'
#' @description The regular expression looks for any file name that ends with
#' ".Rproj"
#'
#' @param file_list The list of files to scan from an .Rproj file. Default is the root.
#'
#' @return A message that tells the user if there is a .Rproj file at the root or not.
#'
#' @examples
#' \dontrun {
#' root_dir <- get_project_root()
#' root_dir_file_list <- list.files(path = root_dir, recursive = TRUE)
#' check_for_rproj(file_list = root_dir_file_list)
#' > [1] "There is a .Rproj file at the root directory."
#' }
check_for_rproj <- function(file_list = root_dir_file_list) {
  if ( !( any( stringr::str_detect(file_list, "\\.Rproj" )))) {
    print("Expecting a .Rproj file at the root directory: ", root_dir)
  } else {
    print("There is a .Rproj file at the root directory.")
  }
}
