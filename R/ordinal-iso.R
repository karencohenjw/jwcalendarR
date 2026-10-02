#' Convert ordinal and ISO week dates
#' @param year,week,weekday,day Whole-number date coordinates.
#' @param x Gregorian civil dates.
#' @return A list of date coordinates or `jwc_date` values.
#' ISO week-years may be 10000 at the upper supported Gregorian boundary when
#' the resulting civil date remains within year 9999.
#' @examples
#' ordinal_date(civil_date(2024, 12, 31))
#' iso_week(civil_date(2024, 12, 31))
#' @export
ordinal_date <- function(x) {
  x <- .jwc_as_date(x); p <- .rd_to_gregorian(unclass(x))
  y0 <- p$year - 1L
  start <- 365 * y0 + y0 %/% 4L - y0 %/% 100L + y0 %/% 400L + 1L
  list(year = p$year, day = as.integer(unclass(x) - start + 1L))
}

#' @rdname ordinal_date
#' @export
from_ordinal_date <- function(year, day) {
  p <- .jwc_recycle(year, day)
  y <- .jwc_number(p[[1L]], "year", 1, 9999); d <- .jwc_number(p[[2L]], "day", 1, 366)
  lim <- ifelse(is_leap_year(y), 366L, 365L)
  if (any(!is.na(d) & d > lim)) .jwc_abort("Ordinal day is outside the supplied year's range.", "jwcalendar_invalid_date")
  start <- 365 * (y - 1L) + (y - 1L) %/% 4L - (y - 1L) %/% 100L + (y - 1L) %/% 400L + 1L
  structure(as.integer(start + d - 1L), class = "jwc_date")
}

.jwc_week1_start <- function(year) {
  y0 <- as.double(year) - 1
  jan4 <- 365 * y0 + floor(y0 / 4) - floor(y0 / 100) + floor(y0 / 400) + 4
  jan4_weekday <- (jan4 - 1) %% 7 + 1
  as.integer(jan4 - jan4_weekday + 1)
}

#' @rdname ordinal_date
#' @export
iso_week <- function(x) {
  x <- .jwc_as_date(x); rd <- unclass(x); wd <- weekday(x)
  thu <- rd + (4L - wd)
  iso_y <- .rd_to_gregorian(rd)$year
  beyond <- !is.na(thu) & thu > 3652059L
  iso_y[beyond] <- 10000L
  iso_y[is.na(rd)] <- NA_integer_
  week1 <- .jwc_week1_start(iso_y)
  list(year = iso_y, week = as.integer((rd - week1) %/% 7L + 1L), weekday = wd)
}

#' @rdname ordinal_date
#' @export
iso_week_year <- function(x) iso_week(x)$year
#' @rdname ordinal_date
#' @export
iso_weekday <- function(x) weekday(x)
#' @rdname ordinal_date
#' @export
from_iso_week_date <- function(year, week, weekday = 1L) {
  p <- .jwc_recycle(year, week, weekday)
  y <- .jwc_number(p[[1L]], "year", 1, 10000); w <- .jwc_number(p[[2L]], "week", 1, 53)
  d <- if (is.character(p[[3L]])) .jwc_weekday(p[[3L]], "weekday") else .jwc_number(p[[3L]], "weekday", 1, 7)
  miss <- is.na(y) | is.na(w) | is.na(d)
  start <- .jwc_week1_start(y)
  out <- start + (w - 1L) * 7L + d - 1L
  if (any(!miss & (out < 1L | out > 3652059L))) .jwc_abort("ISO week date maps outside supported Gregorian years 1 to 9999.", "jwcalendar_domain_error")
  result <- structure(as.integer(out), class = "jwc_date")
  actual <- iso_week(result)
  if (any(!miss & (actual$year != y | actual$week != w))) .jwc_abort("Invalid ISO week for the supplied ISO week-year.", "jwcalendar_invalid_date")
  result
}

#' @rdname ordinal_date
#' @export
as_iso_week_date <- function(x) iso_week(x)
