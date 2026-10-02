.jwc_abort <- function(message, class = "jwcalendar_error", call = sys.call(-1L)) {
  condition <- structure(
    list(message = message, call = call),
    class = c(class, "error", "condition")
  )
  stop(condition)
}

.jwc_number <- function(x, name, lower = -Inf, upper = Inf, allow_na = TRUE) {
  if (!is.numeric(x) || is.factor(x) || is.complex(x)) {
    .jwc_abort(sprintf("`%s` must be numeric.", name), "jwcalendar_invalid_date")
  }
  if (any(is.nan(x) | is.infinite(x))) {
    .jwc_abort(sprintf("`%s` cannot contain NaN or infinite values.", name), "jwcalendar_invalid_date")
  }
  if (!allow_na && anyNA(x)) {
    .jwc_abort(sprintf("`%s` cannot contain missing values.", name), "jwcalendar_invalid_date")
  }
  ok <- !is.na(x)
  if (any(x[ok] != floor(x[ok]))) {
    .jwc_abort(sprintf("`%s` must contain whole numbers.", name), "jwcalendar_invalid_date")
  }
  if (any(x[ok] < lower | x[ok] > upper)) {
    .jwc_abort(sprintf("`%s` must be between %s and %s.", name, lower, upper), "jwcalendar_invalid_date")
  }
  as.integer(x)
}

.jwc_recycle <- function(...) {
  xs <- list(...)
  n <- max(lengths(xs))
  if (n == 0L) return(lapply(xs, identity))
  lens <- lengths(xs)
  if (any(lens != 1L & lens != n)) {
    .jwc_abort("Inputs must have length one or a common length.", "jwcalendar_invalid_date")
  }
  lapply(xs, rep_len, length.out = n)
}

.jwc_is_date <- function(x) inherits(x, "jwc_date")

.jwc_as_date <- function(x) {
  if (.jwc_is_date(x)) {
    rd <- .jwc_number(unclass(x), "jwc_date", 1, 3652059)
    return(structure(rd, class = "jwc_date"))
  }
  if (inherits(x, "Date")) {
    days <- unclass(x)
    if (any(!is.na(days) & (is.nan(days) | is.infinite(days) | days != floor(days)))) {
      .jwc_abort("`Date` input must contain whole civil days.", "jwcalendar_invalid_date")
    }
    rd <- days + 719163
    if (any(!is.na(rd) & (rd < 1 | rd > 3652059))) {
      .jwc_abort("`Date` input is outside the supported Gregorian years 1 to 9999.", "jwcalendar_domain_error")
    }
    return(structure(as.integer(rd), class = "jwc_date"))
  }
  if (is.character(x)) {
    missing <- is.na(x)
    good <- grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x) | missing
    if (!all(good)) {
      .jwc_abort("Character dates must use the exact YYYY-MM-DD form.", "jwcalendar_parse_error")
    }
    year <- month <- day <- rep(NA_integer_, length(x))
    year[!missing] <- as.integer(substr(x[!missing], 1L, 4L))
    month[!missing] <- as.integer(substr(x[!missing], 6L, 7L))
    day[!missing] <- as.integer(substr(x[!missing], 9L, 10L))
    return(civil_date(year, month, day))
  }
  .jwc_abort("`x` must be a `jwc_date`, a base `Date`, or ISO YYYY-MM-DD character data.", "jwcalendar_invalid_date")
}

#' Construct a Gregorian civil date
#'
#' `civil_date()` validates year, month, and day coordinates and stores dates
#' as integer absolute days. The supported years are 1 through 9999; no time
#' zone or timestamp conversion is involved.
#' @param year,month,day Whole-number vectors. Length-one inputs recycle to the
#'   common vector length; other incompatible lengths are errors. Missing input
#'   in any coordinate yields a missing date.
#' @return An integer vector of class `jwc_date`.
#' @examples
#' civil_date(2027, 1, 1)
#' @export
civil_date <- function(year, month, day) {
  parts <- .jwc_recycle(year, month, day)
  year <- .jwc_number(parts[[1L]], "year", 1, 9999)
  month <- .jwc_number(parts[[2L]], "month", 1, 12)
  day <- .jwc_number(parts[[3L]], "day", 1, 31)
  missing <- is.na(year) | is.na(month) | is.na(day)
  leap <- !missing & (year %% 4L == 0L & (year %% 100L != 0L | year %% 400L == 0L))
  mdays <- c(31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
  limit <- rep(NA_integer_, length(year))
  limit[!missing] <- mdays[month[!missing]] + as.integer(leap[!missing] & month[!missing] == 2L)
  if (any(!missing & day > limit)) {
    .jwc_abort("Invalid Gregorian day for the supplied year and month.", "jwcalendar_invalid_date")
  }
  y1 <- year - 1L
  before_year <- 365 * y1 + y1 %/% 4L - y1 %/% 100L + y1 %/% 400L
  cumulative <- c(0L, 31L, 59L, 90L, 120L, 151L, 181L, 212L, 243L, 273L, 304L, 334L)
  before_month <- integer(length(year))
  before_month[!missing] <- cumulative[month[!missing]]
  before_month[!missing & month > 2L & leap] <- before_month[!missing & month > 2L & leap] + 1L
  rd <- before_year + before_month + day
  rd[missing] <- NA_integer_
  structure(as.integer(rd), class = "jwc_date")
}

#' Convert supported date representations to `jwc_date`
#' @param x A `jwc_date`, `Date`, or strict ISO date character vector.
#' @return An integer vector of class `jwc_date`.
#' @examples
#' as_jwc_date("2027-01-01")
#' @export
as_jwc_date <- function(x) .jwc_as_date(x)

.rd_to_gregorian <- function(rd) {
  rd <- as.double(rd)
  missing <- is.na(rd)
  if (any(!missing & (rd < 1 | rd > 3652059 | rd != floor(rd)))) {
    .jwc_abort("Absolute day is outside the supported Gregorian years 1 to 9999.", "jwcalendar_domain_error")
  }
  n <- rd - 1
  era <- floor(n / 146097)
  doe <- n - era * 146097
  yoe <- floor((doe - floor(doe / 1460) + floor(doe / 36524) - floor(doe / 146096)) / 365)
  year <- era * 400 + yoe + 1
  leap <- year %% 4 == 0 & (year %% 100 != 0 | year %% 400 == 0)
  y0 <- year - 1
  year_start <- 365 * y0 + floor(y0 / 4) - floor(y0 / 100) + floor(y0 / 400) + 1
  doy <- rd - year_start + 1
  starts <- c(0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334)
  month_index <- findInterval(doy - 1 - as.integer(leap & doy > 60), starts)
  month <- month_index
  day <- doy - starts[month] - as.integer(leap & month > 2)
  year[missing] <- month[missing] <- day[missing] <- NA_real_
  data.frame(year = as.integer(year), month = as.integer(month), day = as.integer(day))
}

#' @export
civil_year <- function(x) .rd_to_gregorian(.jwc_as_date(x))$year
#' @export
civil_month <- function(x) .rd_to_gregorian(.jwc_as_date(x))$month
#' @export
civil_day <- function(x) .rd_to_gregorian(.jwc_as_date(x))$day

#' Absolute day number in the Rata Die epoch
#'
#' `absolute_day()` is the count of days relative to Gregorian 0001-01-01,
#' which is day 1. This convention is used internally by `jwc_date`.
#' @param x A supported Gregorian date.
#' @return An integer vector, with missing values preserved.
#' @examples
#' absolute_day(civil_date(1, 1, 1))
#' @export
absolute_day <- function(x) as.integer(.jwc_as_date(x))

#' @export
as.Date.jwc_date <- function(x, ...) structure(as.numeric(unclass(x)) - 719163, class = "Date")
#' @export
as.character.jwc_date <- function(x, ...) format(x, ...)
#' @export
format.jwc_date <- function(x, ...) {
  parts <- .rd_to_gregorian(unclass(x))
  out <- sprintf("%04d-%02d-%02d", parts$year, parts$month, parts$day)
  out[is.na(unclass(x))] <- NA_character_
  out
}
#' @export
print.jwc_date <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
#' @export
`[.jwc_date` <- function(x, i, ...) structure(NextMethod("["), class = "jwc_date")
#' @export
c.jwc_date <- function(..., recursive = FALSE) {
  xs <- list(...)
  vals <- unlist(lapply(xs, function(x) unclass(.jwc_as_date(x))), recursive = recursive, use.names = FALSE)
  structure(as.integer(vals), class = "jwc_date")
}

#' Gregorian leap years and month lengths
#' @param year Whole Gregorian years from 1 to 9999.
#' @param month Whole month numbers from 1 to 12. Length-one arguments recycle.
#' @return `is_leap_year()` returns logical values; `days_in_month()` returns
#'   integer month lengths. Missing values are preserved.
#' @examples
#' is_leap_year(c(1900, 2000, 2024))
#' days_in_month(c(2024, 2025), 2)
#' @export
is_leap_year <- function(year) {
  year <- .jwc_number(year, "year", 1, 9999)
  out <- year %% 4L == 0L & (year %% 100L != 0L | year %% 400L == 0L)
  out[is.na(year)] <- NA
  out
}

#' @rdname is_leap_year
#' @export
days_in_month <- function(year, month) {
  p <- .jwc_recycle(year, month)
  y <- .jwc_number(p[[1L]], "year", 1, 9999)
  m <- .jwc_number(p[[2L]], "month", 1, 12)
  out <- c(31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)[m]
  out[!is.na(y) & !is.na(m) & m == 2L & is_leap_year(y)] <- 29L
  out[is.na(y) | is.na(m)] <- NA_integer_
  as.integer(out)
}

#' Weekday and ordinal-day coordinates
#'
#' Weekdays use ISO numbering: Monday is 1 and Sunday is 7. The day-of-year
#' coordinate is 1-based.
#' @param x A supported Gregorian date.
#' @param labels If `TRUE`, return English weekday names.
#' @return Integer weekday or ordinal day vectors, or weekday names.
#' @examples
#' weekday(civil_date(2027, 1, 1))
#' ordinal_day(civil_date(2024, 12, 31))
#' @export
weekday <- function(x, labels = FALSE) {
  rd <- unclass(.jwc_as_date(x))
  w <- as.integer((rd - 1L) %% 7L + 1L)
  w[is.na(rd)] <- NA_integer_
  if (isTRUE(labels)) {
    out <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")[w]
    out[is.na(w)] <- NA_character_
    return(out)
  }
  w
}

#' @rdname weekday
#' @export
ordinal_day <- function(x) {
  x <- .jwc_as_date(x)
  p <- .rd_to_gregorian(unclass(x))
  y0 <- p$year - 1L
  start <- 365 * y0 + y0 %/% 4L - y0 %/% 100L + y0 %/% 400L + 1L
  as.integer(unclass(x) - start + 1L)
}

#' Add and compare civil days
#' @param x,start,end Supported Gregorian dates.
#' @param n Whole day offsets. Length-one inputs recycle to the common length.
#' @return `add_days()` returns `jwc_date`; `difference_days()` returns an
#'   integer vector (`end - start`).
#' @examples
#' add_days(civil_date(2024, 2, 28), 1:2)
#' difference_days(civil_date(2024, 3, 1), civil_date(2024, 2, 28))
#' @export
add_days <- function(x, n) {
  p <- .jwc_recycle(.jwc_as_date(x), n)
  rd <- as.double(unclass(p[[1L]]))
  offset <- .jwc_number(p[[2L]], "n", -3652059, 3652059)
  out <- rd + offset
  if (any(!is.na(out) & (out < 1 | out > 3652059))) {
    .jwc_abort("Day arithmetic would leave the supported years 1 to 9999.", "jwcalendar_domain_error")
  }
  structure(as.integer(out), class = "jwc_date")
}

#' @rdname add_days
#' @export
difference_days <- function(end, start) {
  p <- .jwc_recycle(.jwc_as_date(end), .jwc_as_date(start))
  as.integer(unclass(p[[1L]]) - unclass(p[[2L]]))
}

#' Add months or years with an explicit invalid-day policy
#'
#' The `previous-valid` policy clamps to the last valid day of the target
#' month. The default `error` policy rejects any clamp that would be needed.
#' @param x A supported Gregorian date.
#' @param n Whole number of months or years to add.
#' @param invalid Either `"error"` or `"previous-valid"`.
#' @return A `jwc_date` vector.
#' @examples
#' add_months(civil_date(2024, 1, 31), 1, invalid = "previous-valid")
#' @export
add_months <- function(x, n, invalid = c("error", "previous-valid")) {
  invalid <- match.arg(invalid)
  p <- .jwc_recycle(.jwc_as_date(x), n)
  x <- p[[1L]]
  n <- .jwc_number(p[[2L]], "n", -120000, 120000)
  parts <- .rd_to_gregorian(unclass(x))
  idx <- (parts$year - 1L) * 12L + parts$month - 1L + n
  target_year <- idx %/% 12L + 1L
  target_month <- idx %% 12L + 1L
  if (any(!is.na(idx) & (target_year < 1L | target_year > 9999L))) {
    .jwc_abort("Month arithmetic would leave the supported years 1 to 9999.", "jwcalendar_domain_error")
  }
  target_day <- parts$day
  max_day <- days_in_month(target_year, target_month)
  bad <- !is.na(target_day) & target_day > max_day
  if (any(bad) && invalid == "error") {
    .jwc_abort("Target month does not contain the source day; use `invalid = 'previous-valid'` to clamp.", "jwcalendar_invalid_date")
  }
  target_day[bad] <- max_day[bad]
  civil_date(target_year, target_month, target_day)
}

#' @rdname add_months
#' @export
add_years <- function(x, n, invalid = c("error", "previous-valid")) {
  invalid <- match.arg(invalid)
  n <- .jwc_number(n, "n", -9999, 9999)
  add_months(x, n * 12L, invalid = invalid)
}
