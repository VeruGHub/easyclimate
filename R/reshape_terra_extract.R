

#' Reshape terra output from get_montly_climate_single and get_daily_climate_single
#' when output = "df"
#'
#' @param df.wide A data.frame with the output of terra::extract.
#' @param climvar Character. Climatic variable to be downloaded.
#' One of 'Tmax', 'Tmin', 'Tavg' or 'Prcp'.
#'
#' @return A data.frame
#'
#' @keywords internal
#' @noRd
#'
#' @author Veronica Cruz-Alonso, Francisco Rodriguez-Sanchez


reshape_terra_extract <- function(df.wide, climvar) {

  df.wide <- df.wide[,!names(df.wide) %in% c("lon", "lat")]
  names(df.wide)[names(df.wide) %in% c("x", "y")] <- c("lon", "lat")

  names(df.wide)[!names(df.wide) %in% c("ID", "lon", "lat")] <-
    paste0(climvar, ".", names(df.wide)[!names(df.wide) %in% c("ID", "lon", "lat")])

  df.long <- stats::reshape(df.wide, direction = "long",
                            idvar = c("ID", "lon", "lat"),
                            varying = names(df.wide)[!names(df.wide) %in%
                                                       c("ID", "lon", "lat")],
                            timevar = "date")

  df.long <- df.long[order(df.long$ID, df.long$date), ]
  row.names(df.long) <- NULL

  df.long

}
