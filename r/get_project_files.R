get_project_files <- function(code_file_extensions = c("R", "Rmd"),
                              ignore_files) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  root_dir = root_dir_file_list = NULL


  # ===========================================================================
  # Inventory the current file directory
  #   * Find and save the file path to the project root
  #   * Save the name of every file in the the root directory
  #   * Test to make sure there is an .Rproj file (i.e., that we are in an R
  #     project)
  # ===========================================================================

  # Save the path to the current project root directory
  root_dir <- here::here()

  # Save a vector containing the names of all the files in the root directory
  root_dir_file_list <- list.files(path = root_dir, recursive = TRUE)

  # Test to make sure there is an .Rproj file
  if (!(any(stringr::str_detect(root_dir_file_list, "\\.Rproj" )))) {
    stop("Expecting a .Rproj file at the root directory: ", root_dir)
  }


  # ===========================================================================
  # Create list of files that can be used for read/write search
  #
  # At this point, we know that we are in an R project. We also have a list of
  # all files that are in that project.
  #
  # Next, we want to subset the file names to only contain files that would
  # plausibly be used for read/write operations. By default, those file types
  # include:
  #   * R
  #   * Rmd
  # ===========================================================================
  code_file_extensions <- code_file_extensions
  readwrite_file_names <- vector(mode = "character")
  ignore_files         <- paste(ignore_files, collapse = "|")
  for(i in seq_along(code_file_extensions)) {

    # Look for extention in the project root
    extension_regex <- paste0("\\.", code_file_extensions[[i]], "$")
    extension_index <- stringr::str_detect(root_dir_file_list, extension_regex)
    extension_names <- root_dir_file_list[extension_index]

    # Add files to readwrite_file_names vector
    readwrite_file_names <- c(readwrite_file_names, extension_names)

    # Ignore files
    # Give the user the option to ignore files that they don't want searched for
    # the keywords read and write
    ignore_index         <- stringr::str_detect(readwrite_file_names, ignore_files)
    readwrite_file_names <- readwrite_file_names[!ignore_index]
  }

  # Create full file paths
  # All the file paths above are relative to the project root. This can sometimes
  # cause problems. To make the file paths more robust, we will paste these
  # relative paths to the root path.
  readwrite_file_names <- paste(root_dir, readwrite_file_names, sep = "/")

  # Create short names
  # Here we create a vector of short names for the R script and R markdown
  # files. These short names will be used to name list elements below.
  # Keep only the text after the final "/" in code file names.
  # The regular expression below scans through of the full file paths to for
  # all of the .R and .Rmd files in the project (readwrite_file_names).
  # Starting from the end of the string, it looks for one or more word
  # characters, followed by any one non-word character, followed by the rest
  # of the word characters that come after the final "/".
  readwrite_file_short_names <- stringr::str_extract(readwrite_file_names, "\\w+\\W\\w+$")


  # ===========================================================================
  # Read in all text from readwrite files
  #
  # This literally grabs all the text (i.e. comments, code, etc.) from every
  # code file (i.e., readwrite_file_names).
  #
  # Name the list "readwrite_all_lines" elements with the name of the file that
  # the lines came from using set_names.
  # ===========================================================================
  readwrite_all_lines <- readwrite_file_names %>%
    purrr::map(readLines) %>%
    purrr::set_names(readwrite_file_short_names)


  # ===========================================================================
  # Search for data files that are read-in in any of the code files
  # ===========================================================================

  # Check for keyword "read" in the text of the code files (TRUE/FALSE) and
  # get their line numbers
  read_keyword_line_numbers <-
    purrr::map(readwrite_all_lines, stringr::str_detect, "read\\S\\w{3,}") %>%
    purrr::map(which)

  # Next, we want to check and see if the same line includes a closing
  # parenthesis. If it does, great! The entire read_whatever function should
  # be on one line. If not, the very next line that does include a closing
  # parenthesis should conclude the read_whatever function.
  # Remember, the whole point is that we want the name of the file being read.
  close_parenthesis_line_number <-
    purrr::map(readwrite_all_lines, stringr::str_detect, "\\)") %>%
    purrr::map(which)

  close_parenthesis_matching_line_number <- purrr::map2(
    .x = read_keyword_line_numbers,
    .y = close_parenthesis_line_number,
    .f = ~ {
      purrr::map_dbl(
        .x,
        .f = function(x) {
          .y[.y >= x][1]
        }
      )
    }
  )

  # Keep the needed lines only
  # Only keep close_parenthesis_line_index_number that greater than
  # read_keyword_line_index_number
  keep_read_line_numbers <- purrr::map2(
    .x = read_keyword_line_numbers,
    .y = close_parenthesis_matching_line_number,
    .f = ~ {
      purrr::map2(.x, .y, seq) %>%
        unlist() %>%
        unique()
    }
  )

  # Keep only need lines
  # Keep only the lines of text from the code files that include a function
  # for reading-in data -- these functions may be spread over multiple lines
  read_lines <- purrr::map2(readwrite_all_lines, keep_read_line_numbers, `[`)

  # Identify rows that contain a file name
  # The regular expression below scans through instances when a read*
  # function was used to read-in data in a code file. Starting from the
  # beginning of the line it looks for one or more characters, followed by a
  # single '.', followed by any three or more letters (e.g., 'csv' or
  # 'feather').
  read_file_names_index <- purrr::map(read_lines, stringr::str_detect, "(\\w+\\.\\w{3,})")
  read_lines            <- purrr::map2(read_lines, read_file_names_index, `[`)

  # Strip out everything except the name of the file being read-in and its
  # extension
  # The regular expression below scans through instances when a read* function
  # was used to read-in data in a code file.
  # Starting from the beginning of the line, the first group (i.e., the regex
  # in the first set of parentheses) looks for one or more characters (e.g.,
  # "foo"), followed by a single '.', followed by any three or more letters
  # (e.g., 'csv' or 'feather').
  # The second group (i.e., the regex in the second set of parentheses) is a
  # negative lookahead. It tells r not to count the first group as a match if
  # it is followed by an open parenthesis This prevents matching read.*
  # function calls, e.g., "read.csv("
  # Finally, if the same dataset is read-in to a file more than one time
  # (as "student_scores_01.csv" was in data_clean_student_data_01.R), we only
  # want to keep the dataset name once. That's why we iterate unique through
  # the list using purrr::map.
  files_read_in <- purrr::map(read_lines, stringr::str_extract, "(\\w+\\.\\w{3,})(?!\\()")
  files_read_in <- purrr::map(files_read_in, unique)


  # ===========================================================================
  # Search for code files that write-out in any data files
  # ===========================================================================

  # Check for keyword "write" in the text of the code files (TRUE/FALSE) and
  # get their line numbers
  write_keyword_line_numbers <-
    purrr::map(readwrite_all_lines, stringr::str_detect, "write\\S\\w{3,}") %>%
    purrr::map(which)

  # Next, we want to check and see if the same line includes a closing
  # parenthesis. If it does, great! The entire write_whatever function should
  # be on one line. If not, the very next line that does include a closing
  # parenthesis should conclude the write_whatever function.
  # Remember, the whole point is that we want the name of the file being written.
  close_parenthesis_line_number <-
    purrr::map(readwrite_all_lines, stringr::str_detect, "\\)") %>%
    purrr::map(which)

  close_parenthesis_matching_line_number <- purrr::map2(
    .x = write_keyword_line_numbers,
    .y = close_parenthesis_line_number,
    .f = ~ {
      purrr::map_dbl(
        .x,
        .f = function(x) {
          .y[.y >= x][1]
        }
      )
    }
  )

  # Keep the needed lines only
  # Only keep close_parenthesis_line_index_number that greater than
  # write_keyword_line_index_number
  keep_write_line_numbers <- purrr::map2(
    .x = write_keyword_line_numbers,
    .y = close_parenthesis_matching_line_number,
    .f = ~ {
      purrr::map2(.x, .y, seq) %>%
        unlist() %>%
        unique()
    }
  )

  # Keep only need lines
  # Keep only the lines of text from the code files that include a function
  # for writing-out data -- these functions may be spread over multiple lines
  write_lines <- purrr::map2(readwrite_all_lines, keep_write_line_numbers, `[`)

  # Identify rows that contain a file name
  # The regular expression below scans through instances when a write*
  # function was used to write-out data in a code file. Starting from the
  # beginning of the line it looks for one or more characters, followed by a
  # single '.', followed by any three or more letters (e.g., 'csv' or
  # 'feather').
  write_file_names_index <- purrr::map(write_lines, stringr::str_detect, "(\\w+\\.\\w{3,})")
  write_lines            <- purrr::map2(write_lines, read_file_names_index, `[`)

  # Strip out everything except the name of the file being written-out and its
  # extension
  # The regular expression below scans through instances when a write* function
  # was used to write-out data in a code file.
  # Starting from the beginning of the line, the first group (i.e., the regex
  # in the first set of parentheses) looks for one or more characters (e.g.,
  # "foo"), followed by a single '.', followed by any three or more letters
  # (e.g., 'csv' or 'feather').
  # The second group (i.e., the regex in the second set of parentheses) is a
  # negative lookahead. It tells r not to count the first group as a match if
  # it is followed by an open parenthesis This prevents matching write.*
  # function calls, e.g., "write.csv("
  # Finally, if the same dataset is written-out to a file more than one time
  # (as "student_scores_01.csv" was in data_clean_student_data_01.R), we only
  # want to keep the dataset name once. That's why we iterate unique through
  # the list using purrr::map.
  files_written_out <- purrr::map(write_lines, stringr::str_extract, "(\\w+\\.\\w{3,})(?!\\()")
  files_written_out <- purrr::map(files_written_out, unique)

  # Return list of code files
  out <- list(
    code_full_paths   = readwrite_file_names,
    code_file_names   = readwrite_file_short_names,
    files_read_in     = files_read_in,
    files_written_out = files_written_out
  )
  out
}

get_project_files()
