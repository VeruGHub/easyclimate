
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `easyclimate`: Easy access to high-resolution daily climate data for Europe

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/VeruGHub/easyclimate/workflows/R-CMD-check/badge.svg)](https://github.com/VeruGHub/easyclimate/actions)
[![Codecov test
coverage](https://codecov.io/gh/VeruGHub/easyclimate/branch/master/graph/badge.svg)](https://codecov.io/gh/VeruGHub/easyclimate?branch=master)
<!-- badges: end -->

Easily get high-resolution (1 km) daily climate data (precipitation,
minimum and maximum temperatures) across Europe, from the European
climatic database <ftp://palantir.boku.ac.at/Public/ClimateData/>.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("VeruGHub/easyclimate")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(easyclimate)
coords <- matrix(c(-5.36, 37.40), ncol = 2)
prec <- get_daily_climate(coords, period = "2001-01-01:2001-01-10", climatic_var = "Prcp")
prec
```

## Citation

If you use easyclimate, please cite both the data source and the package
as:

Werner Rammer, Christoph Pucher, Mathias Neumann. 2018. Description,
Evaluation and Validation of Downscaled Daily Climate Data Version 2.
<ftp://palantir.boku.ac.at/Public/ClimateData/>

Adam Moreno, Hubert Hasenauer. 2016. Spatial downscaling of European
climate data International Journal of Climatology, 36: 1444-1458

Verónica Cruz-Alonso, Francisco Rodríguez-Sánchez, Christoph Pucher,
Sophia Ratcliffe, Julen Astigarraga, Mathias Neumann and Paloma
Ruiz-Benito. 2021. easyclimate: Easy access to high-resolution daily
climate data for Europe. <https://github.com/VeruGHub/easyclimate>

To see these entries in BibTeX format, use ‘print(<citation>,
bibtex=TRUE)’, ‘toBibtex(.)’, or set ‘options(citation.bibtex.max=999)’.
