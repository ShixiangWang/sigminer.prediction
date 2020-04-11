
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sigminer.prediction

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Mutational signatures represent mutational processes occured in cancer
evolution, thus are stable and genetic resources for subtyping. This
tool provides functions for training neutral network models to predict
the subtype a sample belongs to based on ‘keras’ and
[‘sigminer’](https://github.com/ShixiangWang/sigminer) packages.

> This is part of **sigminer** project.

## Installation

You can install the **sigminer.prediction** from **GitHub** with::

``` r
# install.packages("remotes")
remotes::install_github("ShixiangWang/sigminer.prediction")
```

Keras package and library are required.

``` r
install.packages("keras")
keras::install_keras()
```

## Usage

``` r
library(sigminer.prediction)
#> Loading required package: keras
```

Load data from our group study.

``` r
load(system.file("extdata", "wang2020-input.RData",
  package = "sigminer.prediction", mustWork = TRUE
))
```

Prepare data.

``` r
dat_list <- prepare_data(expo_all,
  col_to_vars = c(paste0("Sig", 1:5), paste0("AbsSig", 1:5)),
  col_to_label = "enrich_sig",
  label_names = paste0("Sig", 1:5)
)
```

Construct *Keras* model and fit with train and test datasets.

``` r
res <- modeling_and_fitting(dat_list, 20, 0, 20, 0.1)
```

> See `?modeling_and_fitting` for more.

Plot modeling history.

``` r
res$history[[1]] %>% plot()
#> `geom_smooth()` using formula 'y ~ x'
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

Load the model and use it to predict.

``` r
model <- load_model_hdf5(res$model_file)

## You can set other data here
model %>% predict_classes(dat_list$x_train[1, , drop = FALSE])
#> [1] 4
model %>% predict_proba(dat_list$x_train[1, , drop = FALSE])
#>             [,1]         [,2]         [,3]        [,4]     [,5]
#> [1,] 0.000699665 1.826513e-08 4.774969e-07 0.001207887 0.998092
```

## Citation

-----

***Copy number signature analyses in prostate cancer reveal distinct
etiologies and clinical outcomes, under submission***

-----
