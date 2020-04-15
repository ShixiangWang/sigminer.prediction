#' List Current Available Trained Keras Models
#'
#' @return A `tibble` containing summary models.
#' @export
#'
#' @examples
#' list_trained_models()
list_trained_models <- function() {
  ext_path <- system.file("extdata", package = "sigminer.prediction")
  if (!dir.exists(ext_path)) {
    ext_path <- system.file("inst", "extdata", package = "sigminer.prediction")
  }



  model_list <- dplyr::tibble(
    TargetCancerType = c("PRAD", "PRAD", "PRAD"),
    Application = c("Universal", "WES", "Target Sequencing"),
    Cohort = c("Combined", "Wang et al", "MSKCC 2020"),
    AccuracyTrainLast = c(0.904, 0.980, 0.974),
    AccuracyValLast = c(0.905, 0.960, 0.976),
    AccuracyTest = c(0.919, 0.984, 0.969),
    Date = as.Date(rep("2020-04-09", 3)),
    ModelFile = c(
      file.path(ext_path, "keras_model_for_all_cohorts_20200409.h5"),
      file.path(ext_path, "keras_model_for_wang_cohort_20200409.h5"),
      file.path(ext_path, "keras_model_for_mskcc_cohort_20200409.h5")
    )
  ) %>%
    dplyr::mutate(Index = dplyr::row_number()) %>%
    dplyr::select("Index", dplyr::everything())

  model_list
}
