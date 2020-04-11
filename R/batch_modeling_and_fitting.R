#' Batch Run Keras Models
#'
#' @inheritParams modeling_and_fitting
#' @param param_combination A parameter `matrix`/`data.frame` with each row representing the parameters
#' for run Keras model once. Column names should indicate parameter names and should be same as in modeling function.
#' [base::expand.grid()] may be very useful to generate it.
#' @param ... Other arguments passing to [modeling_and_fitting].
#'
#' @return a `tibble`.
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
#' pc <- expand.grid(
#'   c(10, 20, 50, 100),
#'   c(0, 0.1, 0.2, 0.3, 0.4, 0.5),
#'   c(10, 20, 50, 100),
#'   c(0, 0.1, 0.2, 0.3, 0.4, 0.5)
#' )
#' colnames(pc) <- c(
#'   "first_layer_unit", "second_layer_drop_rate",
#'   "third_layer_unit", "fourth_layer_drop_rate"
#' )
#'
#' # Just use 2 rows for illustration
#' batch_res <- batch_modeling_and_fitting(dat_list, param_combination = pc %>% head(2))
#' batch_res
#'
#' tidy(batch_res)
batch_modeling_and_fitting <- function(data_list,
                                       param_combination,
                                       ...) {
  stopifnot(is.matrix(param_combination) | is.data.frame(param_combination))

  if (is.matrix(param_combination)) {
    if (is.null(colnames(param_combination))) {
      stop("Colnames of param_combination must be set to map the parameters in 'modeling_and_fitting' like function!")
    }
    param_combination <- as.data.frame(param_combination)
  }

  args <- list(...)
  args$data_list <- data_list

  model_df <- dplyr::tibble()
  for (i in 1:nrow(param_combination)) {
    message("=> Running model with parameter combination #", i)
    args_update <- c(args, param_combination[i, , drop = FALSE])

    temp_df <- do.call("modeling_and_fitting", args = args_update)
    print(temp_df)
    model_df <- dplyr::bind_rows(model_df, temp_df)
  }

  return(model_df)
}
