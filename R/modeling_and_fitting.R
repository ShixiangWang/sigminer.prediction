#' Create 5-layer Keras Model and Fitting Datasets
#'
#' @inheritParams keras::compile.keras.engine.training.Model
#' @inheritParams keras::fit.keras.engine.training.Model
#' @param data_list A `list` containing predictor and label matrix of training data and test data.
#' Please use [prepare_data] to generate this.
#' @param first_layer_unit Positive integer, dimensionality of the output space for the first layer.
#' @param second_layer_drop_rate Float between 0 and 1. Fraction of the input units to drop for the second layer.
#' @param third_layer_unit Positive integer, dimensionality of the output space for the third layer.
#' @param fourth_layer_drop_rate Float between 0 and 1. Fraction of the input units to drop for the fourth layer.
#' @param epochs Number of epochs to train the model, default is `30`.
#' @param batch_size Integer or NULL. Number of samples per gradient update. If unspecified, batch_size will default to `16`.
#' @param test_split Float between 0 and 1. Fraction of the all data to be used as test data.
#' If not set, it will be auto-calculated from input data. This value is used for calculating
#' total accuracy.
#' @param first_layer_activation activation function for the first layer, default is "relu".
#' @param third_layer_activation activation function for the third layer, default is "relu".
#' @param fifth_layer_activation activation function for the fifth layer, default is "softmax".
#' @param model_file file path to save the model file in `hdf5` format. Default use a temp file path,
#' the path will be stored in returned data. You can load the model with [keras::load_model_hdf5()].
#' @param test_mode Default is `FALSE`, if `TRUE`, print the input parameters from the user and exit.
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
#' res <- modeling_and_fitting(dat_list, 20, 0, 20, 0.1)
#' res$history[[1]] %>% plot()
#'
#' ## Load model and predict
#' model <- load_model_hdf5(res$model_file)
#'
#' model %>% predict_classes(dat_list$x_train[1, , drop = FALSE])
#' model %>% predict_proba(dat_list$x_train[1, , drop = FALSE])
modeling_and_fitting <- function(data_list,
                                 first_layer_unit,
                                 second_layer_drop_rate,
                                 third_layer_unit,
                                 fourth_layer_drop_rate,
                                 epochs = 30,
                                 batch_size = 16,
                                 validation_split = 0.2,
                                 test_split = NULL,
                                 first_layer_activation = "relu",
                                 third_layer_activation = "relu",
                                 fifth_layer_activation = "softmax",
                                 loss = "categorical_crossentropy",
                                 optimizer = optimizer_rmsprop(),
                                 metrics = c("accuracy"),
                                 model_file = tempfile(
                                   pattern = "keras_model",
                                   tmpdir = file.path(tempdir(), "sigminer.pred"),
                                   fileext = ".h5"
                                 ),
                                 test_mode = FALSE) {
  if (test_mode) {
    ## sys.call() also work
    print(str(as.list(match.call()),
      max.level = 1
    ))
    return(invisible(NULL))
  }

  dir_model <- dirname(model_file)
  if (!dir.exists(dir_model)) {
    dir.create(dir_model, recursive = TRUE, showWarnings = TRUE)
  }

  x_train <- data_list$x_train
  y_train <- data_list$y_train
  x_test <- data_list$x_test
  y_test <- data_list$y_test

  n_vars <- ncol(x_train)
  n_class <- ncol(y_train)

  if (is.null(test_split)) {
    test_split <- round(nrow(x_test) / sum(nrow(x_train), nrow(x_test)), 4)
  }

  ## Defining model
  model <- keras_model_sequential()
  model %>%
    layer_dense(
      units = first_layer_unit,
      activation = first_layer_activation,
      input_shape = n_vars
    ) %>%
    layer_dropout(rate = second_layer_drop_rate) %>%
    layer_dense(
      units = third_layer_unit,
      activation = third_layer_activation
    ) %>%
    layer_dropout(rate = fourth_layer_drop_rate) %>%
    layer_dense(units = n_class, activation = fifth_layer_activation)

  model %>% compile(
    loss = loss,
    optimizer = optimizer,
    metrics = metrics
  )

  ## Training and evaluation
  history <- model %>% fit(
    x_train, y_train,
    epochs = epochs,
    batch_size = batch_size,
    validation_split = validation_split
  )

  ## Performance
  acc_train <- history$metrics$accuracy
  acc_train_last <- acc_train[length(acc_train)]

  acc_val <- history$metrics$val_accuracy
  acc_val_last <- acc_val[length(acc_val)]

  pf <- model %>% evaluate(x_test, y_test)
  acc_test <- pf$accuracy

  ## Save model and results
  save_model_hdf5(model, filepath = model_file)

  dplyr::tibble(
    model_file = model_file,
    history = list(history),
    n_param = count_params(model),
    key_params = list(dplyr::tibble(
      first_layer_unit = first_layer_unit,
      second_layer_drop_rate = second_layer_drop_rate,
      third_layer_unit = third_layer_unit,
      fourth_layer_drop_rate = fourth_layer_drop_rate
    )),
    performance = list(dplyr::tibble(
      acc_train_last = acc_train_last,
      acc_val_last = acc_val_last,
      acc_test = acc_test,
      acc_total = getTotalAcc(acc_train_last, acc_val_last, acc_test,
        validation_split = validation_split,
        test_split = test_split
      )
    ))
  )
}

getTotalAcc <- function(train_last_acc, validate_last_acc, test_acc, validation_split = 0.2, test_split = 0.2) {
  (train_last_acc * (1 - validation_split) + validate_last_acc * validation_split) * (1 - test_split) + test_acc * test_split
}
