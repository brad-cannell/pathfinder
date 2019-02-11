#' Get Project Root
#'
#' @description Find root and get a list of all files under the root. Save the
#' path to the current project root directory. Make here::here() the default
#' location for finding the project root, but allow the user to override it.
#'
#' @param path
#'
#' @return The root directory
#'
#' @examples
#' \dontrun{
#' # Default. Returns the same thing as here::here()
#' root_dir <- get_project_root()
#'
#' # Example user-provided path
#' root_dir <- get_project_root("../packages/pathfinder_example_project")
#' }
get_project_root <- function(path = NULL) {
  if (is.null(path)) {
    root_dir <- here::here()
  } else {
    root_dir <- path
  }
  root_dir
}
