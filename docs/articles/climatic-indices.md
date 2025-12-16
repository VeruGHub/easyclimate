# Calculating basic climatic indices with data from easyclimate

First, let’s download daily climatic data for a specific location and
store it in a dataframe:

``` r

library(easyclimate)
library(tidyr)
library(dplyr)

coords <- matrix(c(-5.36, 37.40), ncol = 2)

daily <- get_daily_climate(coords,
                           period = 2001:2005,
                           climatic_var = c("Prcp", "Tmin", "Tmax"))  
```

Here we calculate the daily mean temperature:

``` r

daily <- daily |> 
  mutate(Tmean = (Tmin + Tmax) / 2, # Daily mean temperature
         date = as.Date(date),
         month = format(date, format = "%m"),
         year = format(date, format = "%Y"))
```

  

## Average climatic values per site or time period

To calculate average temperatures by site or time period we can use
`group_by` and `summarise` from `dplyr`, or `by` and `aggregate` from
base R:

``` r

daily |> 
  group_by(ID_coords) |> 
  summarise(Tmin.site = mean(Tmin),
            Tmean.site = mean(Tmean),
            Tmax.site = mean(Tmax))
## # A tibble: 1 × 4
##   ID_coords Tmin.site Tmean.site Tmax.site
##       <dbl>     <dbl>      <dbl>     <dbl>
## 1         1      11.5       18.2      24.9

daily |> 
  group_by(year) |>  
  summarise(Tmin.year = mean(Tmin),
            Tmean.year = mean(Tmean),
            Tmax.year = mean(Tmax)) |> 
  kable(digits = 1)
```

| year | Tmin.year | Tmean.year | Tmax.year |
|:-----|----------:|-----------:|----------:|
| 2001 |      11.9 |       18.2 |      24.6 |
| 2002 |      11.5 |       18.0 |      24.5 |
| 2003 |      12.2 |       18.7 |      25.2 |
| 2004 |      11.1 |       18.0 |      25.0 |
| 2005 |      10.6 |       17.9 |      25.2 |

Similarly, you can calculate accumulated precipitation over different
time periods:

``` r
daily |> 
  group_by(year) |>  
  summarise(sumPrec = sum(Prcp)) |> 
  kable(digits = 0)
```

| year | sumPrec |
|:-----|--------:|
| 2001 |     539 |
| 2002 |     594 |
| 2003 |     605 |
| 2004 |     359 |
| 2005 |     238 |

  

## Climatic anomalies

Sometimes it can be useful to calculate the deviation of climate values
from a reference value. For example, if we consider as the reference the
mean value for the period 2001-2005, we can calculate the deviations per
site and year as follows:

``` r

daily |>    
  group_by(ID_coords, year) |>  
  summarise(avgTm = mean(Tmean)) |>  
  group_by(ID_coords) |>  
  mutate(refTm = mean(avgTm)) |>  # Reference mean temperature
  mutate(devTm = avgTm - refTm) |>  
  kable(digits = 1)
```

| ID_coords | year | avgTm | refTm | devTm |
|----------:|:-----|------:|------:|------:|
|         1 | 2001 |  18.2 |  18.2 |   0.1 |
|         1 | 2002 |  18.0 |  18.2 |  -0.2 |
|         1 | 2003 |  18.7 |  18.2 |   0.5 |
|         1 | 2004 |  18.0 |  18.2 |  -0.1 |
|         1 | 2005 |  17.9 |  18.2 |  -0.3 |

``` r

daily |>    
  group_by(ID_coords, year) |>  
  summarise(sumPrec = sum(Prcp)) |> 
  group_by(ID_coords) |> 
  mutate(refPrec = mean(sumPrec)) |>  # Reference precipitation
  mutate(devPrec = sumPrec - refPrec) |>  
  kable(digits = 0)
```

| ID_coords | year | sumPrec | refPrec | devPrec |
|----------:|:-----|--------:|--------:|--------:|
|         1 | 2001 |     539 |     467 |      72 |
|         1 | 2002 |     594 |     467 |     127 |
|         1 | 2003 |     605 |     467 |     138 |
|         1 | 2004 |     359 |     467 |    -108 |
|         1 | 2005 |     238 |     467 |    -229 |

  

## Climatic events

Having daily values allows us to calculate climatic indices such as the
number of consecutive days above a given temperature (e.g. heat waves or
growing degree days), the number of spring frosts or the number of
consecutive days without rain.

  

Let’s start with an example on heat waves, or number of days with
maximum temperatures above a given threshold:

``` r

threshold <- 32  

daily |>  
  mutate(ID_coords = as.factor(ID_coords),
         year = factor(year)) |>  
  group_by(ID_coords, year) |>  
  mutate(event = ifelse(Tmax >= threshold, 1, 0), # NAs will be 0 
         start = c(1, diff(event) != 0),
         run = cumsum(start)) |>  
  filter(event == 1) |> 
  group_by(run, .add = TRUE) |>  
  mutate(length = n()) |>  
  group_by(ID_coords, year) |> 
  summarise(max_heatwave = max(length), # longest heatwave per year (in days)
            mean_heatwave = mean(length), # average length of heatwaves per year
            n_heatwave = n()) |>  # No. of events per year
  kable(digits = 1)
```

| ID_coords | year | max_heatwave | mean_heatwave | n_heatwave |
|:----------|:-----|-------------:|--------------:|-----------:|
| 1         | 2001 |           16 |           9.4 |         90 |
| 1         | 2002 |           12 |           7.2 |         76 |
| 1         | 2003 |           32 |          14.7 |        100 |
| 1         | 2004 |           30 |          15.6 |        100 |
| 1         | 2005 |           26 |          14.7 |         90 |

  

To calculate the number of days with spring frosts (i.e. minimum
temperatures below 0 during spring months) we can use the next code:

``` r

spring.months <- c("03","04","05") # March to May

daily |>  
  mutate(ID_coords = as.factor(ID_coords),
         year = factor(year)) |>  
  filter(month %in% spring.months) |>  
  mutate(event = ifelse(Tmin < 0, 1, 0)) |>  # NAs will be 0 
  group_by(ID_coords, year) |>  
  mutate(n_frost = sum(event)) |>  # No. of days with minimum temperature < 0 per year
  filter(event == 1) |>  
  group_by(ID_coords, year, n_frost) |>  
  summarise(Tmin_frost_avg = mean(Tmin) / 100) |>  # Mean minimum temperature of frost days
  ungroup() |>  
  complete(ID_coords, year, fill = list(n_frost = 0, Tmin_frost_avg = NA)) |>  
  kable()
```

| ID_coords | year | n_frost | Tmin_frost_avg |
|:----------|:-----|--------:|---------------:|
| 1         | 2001 |       0 |             NA |
| 1         | 2002 |       0 |             NA |
| 1         | 2003 |       0 |             NA |
| 1         | 2004 |       2 |       -0.00795 |
| 1         | 2005 |       0 |             NA |

  

A dry period can be defined as a specific number of consecutive days
with no precipitation:

``` r

threshold <- 30 # threshold in days to count extreme long events of no-rain

daily |>  
  mutate(event = ifelse(Prcp < 0.01, 1, 0), # NAs will be 0 
         start = c(1, diff(event) != 0)) |>  
    group_by(ID_coords, year) |>  
    mutate(run = cumsum(start)) |> 
    filter(event == 1) |>  
    group_by(ID_coords, year, run) |>  
    summarise(length = n()) |>  
    ungroup(run) |> 
    summarise(max_days_norain = max(length), # Maximum length of periods of consecutive days without rain per year
              mean_days_norain = mean(length), 
              nextreme_events = sum(length > threshold)) |> # No. of events per year
  ungroup() |>  
  complete(ID_coords, year, 
           fill = list(max_days_norain = NA, mean_days_norain = NA, nevents = 0))  |>  
  kable(digits = 1)
```

| ID_coords | year | max_days_norain | mean_days_norain | nextreme_events |
|----------:|:-----|----------------:|-----------------:|----------------:|
|         1 | 2001 |             103 |              9.8 |               2 |
|         1 | 2002 |             102 |              8.9 |               1 |
|         1 | 2003 |             145 |              8.9 |               1 |
|         1 | 2004 |             112 |             13.7 |               2 |
|         1 | 2005 |              99 |             13.5 |               4 |

  

## Using ClimInd in combination with easyclimate

The package [`climInd`](https://cran.r-project.org/package=ClimInd) can
be used to calculate multiple climatic indices from data obtained
through {easyclimate}. For example:

  

Number of days with maximum temperature \> 32ºC in summer (June-August):

``` r
library(ClimInd)

Tmax <- as.vector(daily$Tmax)
names(Tmax) <- as.character(format(daily$date, format = "%m/%d/%Y"))

d32(Tmax)
## 2001 2002 2003 2004 2005 
##   72   66   74   75   74
```

  

Growing degree days:

``` r
Tmean <- as.vector(daily$Tmean)
names(Tmean) <- as.character(format(daily$date, format = "%m/%d/%Y"))

gd4(data = Tmean, time.scale = "year") 
##     2001     2002     2003     2004     2005 
## 5197.805 5112.590 5369.960 5135.705 5078.865
```

  

Growing season length:

``` r
gsl(data = Tmean, time.scale = "year") 
## 2001 2002 2003 2004 2005 
##  365  365  365  366  365
```

  

Heavy precipitation days:

``` r
Prec <- as.vector(daily$Prcp)
names(Prec) <- as.character(format(daily$date, format = "%m/%d/%Y"))

d50mm(data = Prec, time.scale = "month")
##      Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
## 2001   0   0   0   0   0   0   0   0   0   0   0   0
## 2002   0   0   0   0   0   0   0   0   1   0   0   0
## 2003   0   0   0   0   0   0   0   0   0   0   0   0
## 2004   0   0   0   0   0   0   0   0   0   0   0   0
## 2005   0   0   0   0   0   0   0   0   0   0   0   0
```

  

## Learn more

To learn more about downloading daily and monthly climatic data, please
consult [this
vignette](https://verughub.github.io/easyclimate/articles/points-df-mat-sf.html)
for point coordinates, or [this
other](https://verughub.github.io/easyclimate/articles/polygons-raster.html)
if you need to extract data for several polygons or a region.
