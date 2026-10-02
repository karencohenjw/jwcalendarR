#' Convert between proleptic Gregorian and Julian dates
#' @param x A Gregorian date for `gregorian_to_julian()`, or a Julian
#'   coordinate list for `julian_to_gregorian()`.
#' @param year,month,day Whole-number Julian calendar coordinates.
#' @return `gregorian_to_julian()` returns a list of integer coordinates;
#'   `julian_to_gregorian()` returns `jwc_date` values.
#' @examples
#' gregorian_to_julian(civil_date(2024, 3, 1))
#' @export
gregorian_to_julian <- function(x) {
  rd <- as.double(unclass(.jwc_as_date(x)))
  jdn <- rd + 1721425
  z <- floor(jdn - 1721424)
  era <- floor(z / 1461)
  doe <- z - era * 1461
  yoe <- pmin(floor(doe / 365), 3)
  year <- era * 4 + yoe + 1
  doy <- doe - yoe * 365 + 1
  starts <- c(0,31,59,90,120,151,181,212,243,273,304,334)
  month <- findInterval(doy - 1, starts)
  day <- doy - starts[month]
  year[is.na(rd)] <- month[is.na(rd)] <- day[is.na(rd)] <- NA_real_
  list(year = as.integer(year), month = as.integer(month), day = as.integer(day))
}

#' @rdname gregorian_to_julian
#' @param year,month,day Julian date fields; these may instead be supplied as
#'   the named list returned by `gregorian_to_julian()`.
#' @export
julian_to_gregorian <- function(year, month = NULL, day = NULL) {
  if (is.list(year) && all(c("year", "month", "day") %in% names(year))) {
    month <- year$month; day <- year$day; year <- year$year
  }
  p <- .jwc_recycle(year, month, day)
  y <- .jwc_number(p[[1L]], "year", 1, 9999)
  m <- .jwc_number(p[[2L]], "month", 1, 12)
  d <- .jwc_number(p[[3L]], "day", 1, 31)
  miss <- is.na(y) | is.na(m) | is.na(d)
  leap <- !miss & y %% 4L == 0L
  mdays <- c(31L,28L,31L,30L,31L,30L,31L,31L,30L,31L,30L,31L)
  lim <- rep(NA_integer_, length(y)); lim[!miss] <- mdays[m[!miss]] + as.integer(leap[!miss] & m[!miss] == 2L)
  if (any(!miss & d > lim)) .jwc_abort("Invalid Julian day for the supplied year and month.", "jwcalendar_invalid_date")
  before <- 365 * (y - 1L) + (y - 1L) %/% 4L
  cum <- c(0L,31L,59L,90L,120L,151L,181L,212L,243L,273L,304L,334L)
  bm <- integer(length(y)); bm[!miss] <- cum[m[!miss]]
  adj <- !miss & m > 2L & leap; bm[adj] <- bm[adj] + 1L
  rd <- before + bm + d - 1L
  out <- rd - 1L # Julian 0001-01-01 is two days before Gregorian 0001-01-01.
  if (any(!miss & (out < 1 | out > 3652059))) .jwc_abort("Julian date maps outside supported Gregorian years 1 to 9999.", "jwcalendar_domain_error")
  structure(as.integer(out), class = "jwc_date")
}

#' Julian day number for a Gregorian civil date
#' @param x Supported Gregorian dates.
#' @return Integer astronomical Julian day numbers. Standard integer JDN values
#'   use the noon-based convention; fractional astronomical Julian Dates are
#'   outside this package's scope.
#' @examples
#' julian_day_number(civil_date(2000, 1, 1))
#' @export
julian_day_number <- function(x) as.integer(unclass(.jwc_as_date(x)) + 1721425L)
