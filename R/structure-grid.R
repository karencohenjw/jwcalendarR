.jwc_weekday_names <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
.jwc_weekday <- function(x, name = "weekday") {
  if (is.character(x)) {
    idx <- match(tolower(x), tolower(.jwc_weekday_names))
    if (anyNA(idx)) .jwc_abort(sprintf("`%s` must use an English weekday name or an integer from 1 to 7.", name), "jwcalendar_invalid_date")
    return(as.integer(idx))
  }
  .jwc_number(x, name, 1, 7, allow_na = FALSE)
}
.jwc_month <- function(x, name = "month") {
  if (is.character(x)) {
    names <- c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")
    idx <- match(tolower(x), names)
    if (anyNA(idx)) .jwc_abort(sprintf("`%s` must use an English month name or an integer from 1 to 12.", name), "jwcalendar_invalid_rule")
    return(as.integer(idx))
  }
  .jwc_number(x, name, 1, 12, allow_na = FALSE)
}

#' Create a natural-month calendar grid
#' @param year,month Gregorian calendar coordinates.
#' @param week_start First displayed weekday, Monday=1 through Sunday=7; full
#'   English weekday names are also accepted.
#' @param rows `"natural"`, `5`, or `6`; six-row mode has a stable height.
#' @param adjacent If `TRUE`, return a long data frame including adjacent-month
#'   dates. Unsupported dates beyond years 1 to 9999 appear as missing.
#' @param iso_week_labels Include ISO week coordinates in the result.
#' @return By default, an integer matrix of day numbers. With `adjacent = TRUE`,
#'   a data frame of grid cells and civil dates.
#' @examples
#' calendar_grid(2027, 1, week_start = 1)
#' @export
calendar_grid <- function(year, month, week_start = 1L, rows = "natural", adjacent = FALSE, iso_week_labels = FALSE) {
  y <- .jwc_number(year, "year", 1, 9999, allow_na = FALSE)
  m <- .jwc_number(month, "month", 1, 12, allow_na = FALSE)
  ws <- .jwc_weekday(week_start, "week_start")
  if (length(y) != 1L || length(m) != 1L || length(ws) != 1L) .jwc_abort("Grid coordinates must be scalar.", "jwcalendar_invalid_date")
  rows <- match.arg(as.character(rows), c("natural", "5", "6"))
  first <- civil_date(y, m, 1L); nday <- days_in_month(y, m)
  lead <- (weekday(first) - ws) %% 7L
  nrow <- if (rows == "6") 6L else if (rows == "5") 5L else ceiling((lead + nday) / 7)
  if (nrow * 7L < lead + nday) .jwc_abort("This month does not fit in the requested number of rows.", "jwcalendar_domain_error")
  cell <- seq_len(nrow * 7L) - lead
  labels <- .jwc_weekday_names[((ws - 1L + 0:6) %% 7L) + 1L]
  if (!isTRUE(adjacent)) {
    out <- matrix(ifelse(cell >= 1 & cell <= nday, cell, NA_integer_), nrow = nrow, byrow = TRUE,
                  dimnames = list(NULL, labels))
    if (isTRUE(iso_week_labels)) {
      starts <- unclass(first) - lead + (seq_len(nrow) - 1L) * 7L
      starts[starts < 1L | starts > 3652059L] <- NA_integer_
      weeks <- iso_week(structure(as.integer(starts), class = "jwc_date"))
      rownames(out) <- sprintf("%04d-W%02d", weeks$year, weeks$week)
      attr(out, "iso_week") <- weeks
    }
    return(out)
  }
  rd <- unclass(first) + cell - 1L
  rd[rd < 1L | rd > 3652059L] <- NA_integer_
  dates <- structure(as.integer(rd), class = "jwc_date")
  iso <- if (isTRUE(iso_week_labels)) iso_week(dates) else NULL
  out <- data.frame(row = rep(seq_len(nrow), each = 7L), column = rep(seq_len(7L), nrow),
    weekday = rep(labels, nrow), date = dates, day = civil_day(dates),
    in_month = cell >= 1L & cell <= nday, stringsAsFactors = FALSE)
  if (!is.null(iso)) { out$iso_year <- iso$year; out$iso_week <- iso$week }
  out
}

.jwc_month_signature <- function(year, month, week_start = 1L) {
  grid <- calendar_grid(year, month, week_start, "natural")
  flat <- as.vector(t(grid))
  paste0(nrow(grid), ":", paste(ifelse(is.na(flat), "0", "1"), collapse = ""), ":",
         paste(sprintf("%02d", flat[!is.na(flat)]), collapse = ","))
}

#' Structural signature for a Gregorian month
#' @param year,month Gregorian calendar coordinates.
#' @param week_start First weekday, Monday=1 through Sunday=7.
#' @return A stable character signature for each requested month.
#' @examples
#' month_signature(2027, 1)
#' @export
month_signature <- function(year, month, week_start = 1L) {
  p <- .jwc_recycle(year, month, week_start)
  vapply(seq_along(p[[1L]]), function(i) .jwc_month_signature(p[[1L]][i], p[[2L]][i], p[[3L]][i]), character(1))
}

#' Calendar structural signatures and equivalence classes
#' @param year Gregorian years; one year or a vector.
#' @param week_start First weekday, Monday=1 through Sunday=7.
#' @param range Candidate Gregorian years to compare in `equivalent_years()`.
#' @param structure Equivalence definition: `"month-grid"`, `"iso-week"`, or
#'   `"print-layout"`. The current proleptic Gregorian layouts make these
#'   equivalent when their encoded layout fields agree.
#' @return `calendar_signature()` returns a structured signature object;
#'   `calendar_class()` returns a versioned fingerprint;
#'   `calendar_classes()` groups supplied years by that fingerprint.
#' @examples
#' calendar_signature(2027)
#' equivalent_years(2024)
#' @export
calendar_signature <- function(year, week_start = 1L) {
  y <- .jwc_number(year, "year", 1, 9999, allow_na = FALSE)
  if (length(y) != 1L) .jwc_abort("`year` must be scalar.", "jwcalendar_invalid_date")
  months <- vapply(1:12, function(m) .jwc_month_signature(y, m, week_start), character(1))
  structure(list(algorithm = "jwcalendar-structure-v1", year = y,
    leap = is_leap_year(y), january_first_weekday = weekday(civil_date(y, 1L, 1L)),
    month_lengths = days_in_month(y, 1:12), month_start_weekdays = weekday(add_months(civil_date(y, 1L, 1L), 0:11)),
    month_grids = months, iso_year_start = iso_week_year(civil_date(y, 1L, 1L)),
    iso_year_end = iso_week_year(civil_date(y, 12L, 31L)), week_start = .jwc_weekday(week_start)), class = "jwc_signature")
}
#' @export
calendar_fingerprint <- function(year, week_start = 1L) {
  sig <- calendar_signature(year, week_start)
  paste(c(sig$algorithm, sig$month_grids,
    paste0("iso-offset:", sig$iso_year_start - sig$year, ":", sig$iso_year_end - sig$year)), collapse = "|")
}
#' @export
calendar_class <- function(year, week_start = 1L) calendar_fingerprint(year, week_start)
#' @export
calendar_classes <- function(year, week_start = 1L) {
  y <- .jwc_number(year, "year", 1, 9999, allow_na = FALSE)
  sig <- vapply(y, calendar_class, character(1), week_start = week_start)
  split(y, sig)
}
#' @export
calendar_equivalent <- function(year1, year2, week_start = 1L,
                                structure = c("month-grid", "iso-week", "print-layout")) {
  structure <- match.arg(structure)
  a <- calendar_signature(year1, week_start); b <- calendar_signature(year2, week_start)
  if (structure == "print-layout") return(identical(c(a$leap, a$january_first_weekday), c(b$leap, b$january_first_weekday)))
  same_grid <- identical(a$month_grids, b$month_grids)
  if (structure == "month-grid") return(same_grid)
  same_grid && identical(c(a$iso_year_start - a$year, a$iso_year_end - a$year),
                         c(b$iso_year_start - b$year, b$iso_year_end - b$year))
}
#' @export
equivalent_years <- function(year, range = NULL, week_start = 1L) {
  y <- .jwc_number(year, "year", 1, 9999, allow_na = FALSE)
  if (length(y) != 1L) .jwc_abort("`year` must be scalar.", "jwcalendar_invalid_date")
  if (is.null(range)) range <- seq.int(max(1L, y - 400L), min(9999L, y + 400L))
  range <- .jwc_number(range, "range", 1, 9999, allow_na = FALSE)
  range[vapply(range, calendar_equivalent, logical(1), year2 = y, week_start = week_start)]
}
#' @export
calendar_cycle_summary <- function(start_year = 2000L, week_start = 1L) {
  start_year <- .jwc_number(start_year, "start_year", 1, 9600, allow_na = FALSE)
  if (length(start_year) != 1L) .jwc_abort("`start_year` must be scalar and leave room for 400 years.", "jwcalendar_invalid_date")
  years <- seq.int(start_year, length.out = 400L)
  sig <- vapply(years, calendar_class, character(1), week_start = week_start)
  list(years = years, unique_structures = length(unique(sig)), cycle_years = 400L,
       leap_years = sum(is_leap_year(years)), week_start = week_start)
}
