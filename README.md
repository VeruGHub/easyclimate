
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `easyclimate` <a href='https://verughub.github.io/easyclimate/'><img src="man/figures/easyclimate_logo_small.png" align="right" height="139"/></a>

# Easy access to high-resolution daily climate data for Europe

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/VeruGHub/easyclimate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/VeruGHub/easyclimate/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/VeruGHub/easyclimate/branch/master/graph/badge.svg)](https://codecov.io/gh/VeruGHub/easyclimate?branch=master)
[![HitCount](https://hits.dwyl.com/VeruGHub/easyclimate.svg?style=flat-square)](http://hits.dwyl.com/VeruGHub/easyclimate)
[![HitCount: unique
users](https://hits.dwyl.com/VeruGHub/easyclimate.svg?style=flat-square&show=unique)](http://hits.dwyl.com/VeruGHub/easyclimate)

<!-- badges: end -->

Get high-resolution (1 km) daily climate data (precipitation, minimum
and maximum temperatures) for Europe from the European climatic database
hosted at [University of Natural Resources and Life Sciences, Vienna,
Austria](https://boku.ac.at/en/wabo/waldbau/wir-ueber-uns/daten). Data
are currently available from 1950 to 2022.

This climatic dataset was originally built by [A. Moreno & H.
Hasenauer](https://doi.org/10.1002/joc.4436) and further developed by W.
Rammer, C. Pucher & M. Neumann (see [this
document](https://github.com/VeruGHub/easyclimate/tree/master/inst/Description_Evaluation_Validation_Downscaled_Climate_Data_v2.pdf)
for more details on the development and characteristics of the climatic
dataset, and [this
document](https://doi.org/10.6084/m9.figshare.22962671.v1) for the
updates of the last version - v4).

In this R package we implemented [Cloud-Optimised
Geotiffs](https://www.cogeo.org/)
([v3](https://github.com/VeruGHub/easyclimate/blob/master/inst/Description_Evaluation_Validation_Downscaled_Climate_Data_v2.pdf))
so that we can obtain daily climate data for thousands of sites/days
within minutes, without having to download huge rasters. But if you need
to obtain data for large areas, please download the rasters from the FTP
server (<ftp://palantir.boku.ac.at/Public/ClimateData/>) and extract the
values locally rather than using this package, so as not to saturate the
file server. For that, you may use a FTP client such as
[FileZilla](https://filezilla-project.org/).

## Installation

``` r
# install.packages("remotes")
remotes::install_github("VeruGHub/easyclimate")
```

## Examples

To obtain a data frame of daily climatic values for point coordinates:

``` r
library(easyclimate)

coords <- data.frame(lon = -5.36, lat = 37.40)

prec <- get_daily_climate(coords, 
                          period = "2001-01-01:2001-01-03", 
                          climatic_var = "Prcp",
                          version = 4) # default
```

| ID_coords |   lon |  lat | date       | Prcp |
|----------:|------:|-----:|:-----------|-----:|
|         1 | -5.36 | 37.4 | 2001-01-01 | 8.30 |
|         1 | -5.36 | 37.4 | 2001-01-02 | 0.00 |
|         1 | -5.36 | 37.4 | 2001-01-03 | 3.38 |

<br>

To obtain a (multi-layer) raster of daily climatic values for an area:

``` r
library(terra)
library(ggplot2)

sobrarbe <- mapSpain::esp_get_comarca(comarca = "Sobrarbe")
sobrarbe <- project(vect(sobrarbe), "EPSG:4326")

sobrarbetemp <- get_daily_climate(coords = sobrarbe,
                               climatic_var = "Tmax",
                               period = "2020-05-01:2020-05-03",
                               output = "raster")

sobrarbetemp <- crop(sobrarbetemp, sobrarbe, mask = TRUE)

sobrarbe_df <- as.data.frame(geom(sobrarbe))
sobrarbetemp_df <- terra::as.data.frame(sobrarbetemp, xy = TRUE)
sobrarbetemp_tidydf <- sobrarbetemp_df |> 
  tidyr::pivot_longer(cols = `2020-05-01`:`2020-05-03`, names_to = "dates", values_to = "tmax")

ggplot() +
  geom_vline(xintercept = 0, color = "gray90", linewidth = 1) +
  geom_tile(data = sobrarbetemp_tidydf, aes(x = x, y = y, fill = tmax),
            alpha = 0.9) +
  scale_fill_gradient2(low = "#4B8AB8", mid = "#FAFBC5", high = "#C54A52",
                       midpoint = 15) +
  facet_wrap(dates~., ncol = 3) +
  geom_polygon(data = sobrarbe_df, aes(x=x, y=y, group=part), fill = NA,
               col = "grey30", linewidth = 1) +
  xlab("") + ylab("") +
  labs(fill = "Maximum\ntemperature (ºC)",) +
  theme(panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "grey90"),
        strip.background = element_blank(),
        strip.text = element_text(hjust = 0))
```

![](man/figures/README-unnamed-chunk-3-1.png)<!-- -->

<br> Visit the articles of the [package
website](https://verughub.github.io/easyclimate/) for more extended
tutorials!

<br>

## CITATION

If you use easyclimate, please cite both the data source and the package
as:

Moreno A, Hasenauer H (2016). “Spatial downscaling of European climate
data.” *International Journal of Climatology*, 1444–1458. \<URL:
<https://doi.org/10.1002/joc.4436>\>.

Pucher C, Neumann M (2022). *Description and Evaluation of Downscaled
Daily Climate Data Version 3*. \<URL:
<https://doi.org/10.6084/m9.figshare.19070162.v1>\>.

Pucher C (2023). *Description and Evaluation of Downscaled Daily Climate
Data Version 4*. \<URL:
<https://doi.org/10.6084/m9.figshare.22962671.v1>\>.

Cruz-Alonso V, Pucher C, Ratcliffe S, Ruiz-Benito P, Astigarraga J,
Neumann M, Hasenauer H, Rodríguez-Sánchez F (2023). “The easyclimate R
package: Easy access to high-resolution daily climate data for Europe.”
*Environmental Modelling & Software*, 105627. doi:
10.1016/j.envsoft.2023.105627 (URL:
<https://doi.org/10.1016/j.envsoft.2023.105627>).
