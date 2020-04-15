#' Load Trained Models
#'
#' @param x A subset from [list_trained_models].
#'
#' @return A (list of) Keras model.
#' @export
#'
#' @examples
#' z <- list_trained_models() %>%
#'   head(1) %>%
#'   load_trained_model()
#' z
load_trained_model <- function(x) {
  stopifnot(is.data.frame(x), "ModelFile" %in% colnames(x))

  if (nrow(x) == 1) {
    model <- keras::load_model_hdf5(x$ModelFile)
  } else {
    model <- list()
    for (i in 1:nrow(x)) {
      model[[paste0("Model", i)]] <- keras::load_model_hdf5(x$ModelFile[i])
    }
  }

  return(model)
}
