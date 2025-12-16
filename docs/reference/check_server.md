# Check climate data server

Check that the online climate data server is available and working
correctly.

## Usage

``` r
check_server(climatic_var = NULL, year = NULL, verbose = TRUE)
```

## Arguments

- climatic_var:

  Optional. One of "Prcp", "Tmin", or "Tmax".

- year:

  Optional. Year between 1950 and 2022.

- verbose:

  Logical. Print diagnostic messages, or just return TRUE/FALSE?

## Value

TRUE if the server seems available, FALSE otherwise.

## Details

This function checks access to the latest version of the climatic
dataset (version 4).

## Examples

``` r
if (FALSE) { # interactive()
check_server()
}
```
