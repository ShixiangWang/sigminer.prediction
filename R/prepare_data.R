#' Prepare Training and Test Dataset
#'
#' @param data A `data.frame`.
#' @param col_to_vars A character vector specifying the predictive columns.
#' @param col_to_label A column indicating the labels/classes.
#' @param label_names Label/class names. The order is important. For example,
#' "a", "b", "c" will be transformed to 0, 1, 2.
#' @param seed Random seed, default is `1234`.
#' @param test_split A fraction of samples to treated as test dataset, default is `0.2`.
#'
#' @return a `list` containing `x_train`, `y_train`, `x_test`, `y_test` datasets.
#' @import keras
#' @importFrom utils str
#' @export
#'
#' @examples
#' load(system.file("extdata", "wang2020-input.RData",
#'   package = "sigminer.prediction", mustWork = TRUE
#' ))
#' dat_list <- prepare_data(expo_all,
#'   col_to_vars = c(paste0("Sig", 1:5), paste0("AbsSig", 1:5)),
#'   col_to_label = "enrich_sig",
#'   label_names = paste0("Sig", 1:5)
#' )
#' str(dat_list)
prepare_data <- function(data,
                         col_to_vars,
                         col_to_label,
                         label_names,
                         seed = 1234,
                         test_split = 0.2) {
  stopifnot(length(col_to_label) == 1)

  dat <- as.data.frame(data)[, c(col_to_vars, col_to_label)]

  ## label names to integer index
  label_index <- seq_along(label_names) - 1
  mp <- label_index
  names(mp) <- label_names
  dat$.target <- as.integer(mp[dat[[col_to_label]]])

  set.seed(seed = seed)
  idx <- caret::createDataPartition(dat$.target, p = 1 - test_split, list = FALSE)

  dat_train <- dat[idx, ]
  dat_test <- dat[-idx, ]

  x_train <- as.matrix(dat_train[, col_to_vars])
  y_train <- to_categorical(dat_train$.target)

  x_test <- as.matrix(dat_test[, col_to_vars])
  y_test <- to_categorical(dat_test$.target)

  return(
    list(
      x_train = x_train,
      y_train = y_train,
      x_test = x_test,
      y_test = y_test,
      label_map = mp
    )
  )
}
