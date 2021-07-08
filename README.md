
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `easyclimate`

# Easy access to high-resolution daily climate data for Europe

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
climatic database hosted at
<ftp://palantir.boku.ac.at/Public/ClimateData/>.

This climatic dataset was originally built by [A. Moreno & H.
Hasenauer](https://doi.org/10.1002/joc.4436) and further developed by W.
Rammer, C. Pucher & M. Neumann from the University of Natural Resources
and Life Sciences, Vienna, Austria. Please check [this
document](https://github.com/VeruGHub/easyclimate/tree/master/inst/Description_Evaluation_Validation_Downscaled_Climate_Data_v2.pdf)
for more details on the development and characteristics of the climatic
dataset.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("VeruGHub/easyclimate")
```

## Examples

Obtaining a data frame with daily climatic values for point coordinates:

``` r
library(easyclimate)

coords <- matrix(c(-5.36, 37.40), ncol = 2)

prec <- get_daily_climate(coords, 
                          period = "2001-01-01:2001-01-03", 
                          climatic_var = "Prcp")
```

| ID\_coords |     x |    y | date       | Prcp |
|-----------:|------:|-----:|:-----------|-----:|
|          1 | -5.36 | 37.4 | 2001-01-01 |  945 |
|          1 | -5.36 | 37.4 | 2001-01-02 |   12 |
|          1 | -5.36 | 37.4 | 2001-01-03 |  205 |

<br>

Obtaining a (multi-layer) raster with daily climatic values for an area:

``` r
library(terra)

coords_poly <- vect("POLYGON ((-4.5 41, -4.5 40.5, -5 40.5, -5 41))")

ras_tmax <- get_daily_climate(
  coords_poly,
  period = c("2012-01-01", "2012-08-01"),
  climatic_var = "Tmax",
  output = "raster" # return raster
  )

ras_tmax <- ras_tmax/100
  
plot(ras_tmax, col = rev(heat.colors(7))) 
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

<br> See the package website for more extended tutorials:
<https://verughub.github.io/easyclimate/>

<br>

## CITATION

If you use easyclimate, please cite both the data source and the package
as:

Moreno A, Hasenauer H (2016). “Spatial downscaling of European climate
data.” *International Journal of Climatology*, 1444–1458.

Rammer W, Pucher C, Neumann M (2018). *Description, Evaluation and
Validation of Downscaled Daily Climate Data Version 2*. &lt;URL:
<ftp://palantir.boku.ac.at/Public/ClimateData/>&gt;.

Cruz-Alonso V, Rodríguez-Sánchez F, Pucher C, Ratcliffe S, Astigarraga
J, Neumann M, Ruiz-Benito P (2021). *easyclimate: Easy access to
high-resolution daily climate data for Europe*. &lt;URL:
<https://github.com/VeruGHub/easyclimate>&gt;.
