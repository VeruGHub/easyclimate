
#' Select tiles
#' 
#' @description obtain the tiles for all x & y coordinates in WGS84
#' 
#' @param coords data frame where first column is long and second column is lat
#' 
#' @return a vector of tiles 
#' @export
#' 
#' @examples
#' @author Veronica Cruz-Alonso

select_tiles <- function(coords) {

    contain <- function (x, y) {
    ifelse(
      x[1] < y[,"xmax"] & x[1] > y[,"xmin"] & 
        x[2] < y[,"ymax"] & x[2] > y[,"ymin"],
      y[,"tile"], NA) }
  
  load(here("0aux/tileextent.RData"))
  tile <- rep(NA, length(coords))
  
  for (i in 1:nrow(tileextent)) {
    tilei <- tileextent[i,]
    a <- apply(coords, 1, contain, y = tilei)
    tile <- ifelse(!is.na(a), a, tile)
  }
  
  return(tile)
  
}
