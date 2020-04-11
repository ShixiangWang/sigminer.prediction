#' Tidy Modeling Result
#'
#' @param x A result `tibble` from either [modeling_and_fitting] or [batch_modeling_and_fitting].
#'
#' @return a `tibble`
#' @export
tidy <- function(x) {
  stopifnot(!is.null(x$performance))
  dt <- dplyr::bind_rows(x$performance)
  dt2 <- dplyr::bind_rows(x$key_params)
  x %>%
    dplyr::select(-c("key_params", "performance")) %>%
    dplyr::bind_cols(dt, dt2)
}

#' Copy Model File
#'
#' It is usefully when your result model file is stored in temp directory and
#' you want to keep it.
#'
#' @param model_file A file path to the model file.
#' @param dest The destination file path.
#'
#' @return Nothing
#' @export
copy_model <- function(model_file, dest) {
  if (file.copy(model_file, dest)) {
    message("Successfully copied model to ", dest)
  }
}
