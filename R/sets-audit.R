.jwc_new_calendar <- function(dates, start = NULL, end = NULL, rule = NULL) {
  dates <- structure(sort(unique(as.integer(unclass(.jwc_as_date(dates))))), class = "jwc_date")
  dates <- dates[!is.na(dates)]
  if (is.null(start)) start <- if (length(dates)) dates[1L] else structure(NA_integer_, class = "jwc_date")
  if (is.null(end)) end <- if (length(dates)) dates[length(dates)] else structure(NA_integer_, class = "jwc_date")
  if (!inherits(start, "jwc_date")) start <- structure(as.integer(start), class = "jwc_date")
  if (!inherits(end, "jwc_date")) end <- structure(as.integer(end), class = "jwc_date")
  structure(list(start = start, end = end, dates = dates, rule = rule), class = c("jwc_compiled_calendar", "jwc_calendar"))
}

#' Calendar set operations
#' @param ... Compiled calendar objects.
#' @param x,y Compiled calendar objects.
#' @return A compiled calendar containing the operation's dates.
#' @examples
#' a <- compile_calendar(on_weekday(1:5), "2027-01-01", "2027-01-31")
#' b <- compile_calendar(on_month_day(1:15), "2027-01-01", "2027-01-31")
#' calendar_intersection(a, b)
#' @export
calendar_union <- function(...) {
  xs <- list(...); if (!length(xs) || any(!vapply(xs, inherits, logical(1), "jwc_calendar"))) .jwc_abort("Supply one or more compiled calendars.", "jwcalendar_invalid_calendar")
  .jwc_new_calendar(do.call(c, lapply(xs, `[[`, "dates")), min(vapply(xs, function(z) unclass(z$start), integer(1))), max(vapply(xs, function(z) unclass(z$end), integer(1))))
}
#' @export
calendar_intersection <- function(x, y) {
  .jwc_check_calendars(x, y)
  .jwc_new_calendar(structure(intersect(unclass(x$dates), unclass(y$dates)), class = "jwc_date"), max(unclass(x$start), unclass(y$start)), min(unclass(x$end), unclass(y$end)))
}
#' @export
calendar_set_difference <- function(x, y) {
  .jwc_check_calendars(x, y)
  .jwc_new_calendar(structure(setdiff(unclass(x$dates), unclass(y$dates)), class = "jwc_date"), x$start, x$end)
}
#' @export
calendar_symmetric_difference <- function(x, y) {
  .jwc_check_calendars(x, y)
  .jwc_new_calendar(structure(setdiff(union(unclass(x$dates), unclass(y$dates)), intersect(unclass(x$dates), unclass(y$dates))), class = "jwc_date"))
}
#' @export
calendar_complement <- function(x, start = x$start, end = x$end) {
  .jwc_check_calendars(x)
  start <- .jwc_as_date(start); end <- .jwc_as_date(end)
  if (length(start) != 1L || length(end) != 1L || is.na(start) || is.na(end) || unclass(start) > unclass(end)) .jwc_abort("`start` and `end` must be ordered scalar dates.", "jwcalendar_invalid_domain")
  full <- unclass(start):unclass(end)
  .jwc_new_calendar(structure(setdiff(full, unclass(x$dates)), class = "jwc_date"), start, end)
}
.jwc_check_calendars <- function(...) {
  xs <- list(...); if (any(!vapply(xs, inherits, logical(1), "jwc_calendar"))) .jwc_abort("Inputs must be compiled calendars.", "jwcalendar_invalid_calendar")
  invisible(TRUE)
}
#' Compare finite calendars or calendar-year structure
#' @param x,y Compiled calendars, or scalar Gregorian years.
#' @return For calendars, the dates only in each set and those shared. For
#'   years, a structured comparison of leap status, month layouts, and ISO
#'   boundary coordinates.
#' @export
calendar_diff <- function(x, y) {
  if (!inherits(x, "jwc_calendar") && !inherits(y, "jwc_calendar")) {
    a <- .jwc_number(x, "x", 1, 9999, allow_na = FALSE); b <- .jwc_number(y, "y", 1, 9999, allow_na = FALSE)
    if (length(a) != 1L || length(b) != 1L) .jwc_abort("Year comparison requires scalar years.", "jwcalendar_invalid_date")
    sx <- calendar_signature(a); sy <- calendar_signature(b)
    return(list(years = c(x = a, y = b), leap = c(x = sx$leap, y = sy$leap),
      january_first_weekday = c(x = sx$january_first_weekday, y = sy$january_first_weekday),
      month_length_differences = which(sx$month_lengths != sy$month_lengths),
      month_start_weekday_differences = which(sx$month_start_weekdays != sy$month_start_weekdays),
      grid_differences = which(sx$month_grids != sy$month_grids),
      iso_year_boundary = list(x = c(sx$iso_year_start, sx$iso_year_end), y = c(sy$iso_year_start, sy$iso_year_end)),
      equivalent = identical(calendar_fingerprint(a), calendar_fingerprint(b))))
  }
  .jwc_check_calendars(x, y)
  list(only_x = structure(setdiff(unclass(x$dates), unclass(y$dates)), class = "jwc_date"),
       only_y = structure(setdiff(unclass(y$dates), unclass(x$dates)), class = "jwc_date"),
       shared = structure(intersect(unclass(x$dates), unclass(y$dates)), class = "jwc_date"))
}
#' @export
calendar_between <- function(x, start, end) {
  .jwc_check_calendars(x); a <- unclass(.jwc_as_date(start)); b <- unclass(.jwc_as_date(end))
  if (length(a) != 1L || length(b) != 1L || a > b) .jwc_abort("`start` and `end` must be ordered scalar dates.", "jwcalendar_invalid_domain")
  .jwc_new_calendar(x$dates[unclass(x$dates) >= a & unclass(x$dates) <= b], start, end, x$rule)
}

#' Generate reproducible adversarial calendar test vectors
#' @param years Gregorian years to inspect.
#' @param cases One or more of `"all"`, `"leap"`, `"month-end"`, `"iso-week"`,
#'   `"julian"`, `"ordinal"`, and `"year-boundary"`.
#' @return A data frame of boundary-focused civil dates and labels.
#' @examples
#' calendar_test_vectors(1900:1901)
#' @export
calendar_test_vectors <- function(years = c(1L, 4L, 100L, 400L, 1900L, 2000L, 2024L, 9999L),
                                  cases = c("all", "leap", "month-end", "iso-week", "julian", "ordinal", "year-boundary")) {
  years <- .jwc_number(years, "years", 1, 9999, FALSE)
  cases <- unique(as.character(cases))
  allowed <- c("all", "leap", "month-end", "iso-week", "julian", "ordinal", "year-boundary")
  if (!length(cases) || any(!cases %in% allowed)) .jwc_abort("`cases` must be selected from the documented test-vector families.", "jwcalendar_invalid_date")
  if ("all" %in% cases) cases <- setdiff(allowed, "all")
  dates <- lapply(years, function(y) {
    month_ends <- do.call(c, lapply(1:12, function(m) civil_date(y, m, days_in_month(y, m))))
    all_dates <- c(civil_date(y, 1L, 1:4), civil_date(y, 2L, 28L),
      if (is_leap_year(y)) civil_date(y, 2L, 29L), civil_date(y, 3L, 1L),
      civil_date(y, 12L, 28:31), month_ends)
    all_dates <- all_dates[!duplicated(unclass(all_dates))]
    p <- .rd_to_gregorian(unclass(all_dates))
    keep <- rep(FALSE, length(all_dates))
    if ("leap" %in% cases) keep <- keep | (p$month == 2L & p$day >= 28L & p$day <= 29L) | (p$month == 3L & p$day == 1L)
    if ("month-end" %in% cases) keep <- keep | p$day == days_in_month(p$year, p$month)
    if ("iso-week" %in% cases) keep <- keep | (p$month == 12L & p$day >= 28L) | (p$month == 1L & p$day <= 4L)
    if ("julian" %in% cases) keep <- keep | p$month %in% c(1L, 3L, 10L, 12L) & p$day == 1L
    if ("ordinal" %in% cases) keep <- keep | (p$month == 1L & p$day == 1L) | p$month == 12L & p$day == 31L | (p$month == 2L & p$day == 29L)
    if ("year-boundary" %in% cases) keep <- keep | (p$month == 1L & p$day == 1L) | (p$month == 12L & p$day == 31L)
    all_dates[keep]
  })
  d <- do.call(c, dates)
  julian <- gregorian_to_julian(d)
  data.frame(date = as.character(d), absolute_day = absolute_day(d), weekday = weekday(d),
             ordinal = ordinal_day(d), iso_year = iso_week_year(d), iso_week = iso_week(d)$week,
             julian_year = julian$year, julian_month = julian$month, julian_day = julian$day,
             julian_day_number = julian_day_number(d),
             stringsAsFactors = FALSE)
}

#' Diagnose date-pipeline drift and boundary behavior
#' @param before,after Supported date vectors to compare.
#' @return A data frame with changed rows and day offsets.
#' @examples
#' date_drift("2024-02-28", "2024-02-29")
#' @export
date_drift <- function(before, after) {
  a <- .jwc_as_date(before); b <- .jwc_as_date(after); p <- .jwc_recycle(a, b)
  data.frame(before = as.character(p[[1L]]), after = as.character(p[[2L]]),
       changed = unclass(p[[1L]]) != unclass(p[[2L]]),
       offset_days = as.integer(unclass(p[[2L]]) - unclass(p[[1L]])),
       before_weekday = weekday(p[[1L]]), after_weekday = weekday(p[[2L]]), stringsAsFactors = FALSE)
}
#' @export
temporal_audit <- function(before, after) date_drift(before, after)
#' @export
audit_date_columns <- function(data, before, after) {
  if (!is.data.frame(data) || !all(c(before, after) %in% names(data))) .jwc_abort("`before` and `after` must name columns in a data frame.", "jwcalendar_invalid_audit")
  d <- date_drift(data[[before]], data[[after]])
  data.frame(row = seq_len(nrow(data)), before = d$before, after = d$after,
             changed = d$changed, offset_days = d$offset_days, weekday_before = d$before_weekday,
             weekday_after = d$after_weekday, stringsAsFactors = FALSE)
}
#' Mark month, year, leap-day and ISO-year boundaries
#' @param x Civil dates or Gregorian years.
#' @return A data frame with boundary flags for each generated or supplied date.
#' @export
boundary_cases <- function(x) {
  if (is.numeric(x) && !inherits(x, "Date") && !inherits(x, "jwc_date")) {
    years <- .jwc_number(x, "year", 1, 9999, allow_na = FALSE)
    dates <- do.call(c, lapply(years, function(y) c(civil_date(y, 1L, 1L), civil_date(y, 2L, 28L),
      if (is_leap_year(y)) civil_date(y, 2L, 29L), civil_date(y, 3L, 1L), civil_date(y, 12L, 31L))))
    x <- dates[!duplicated(unclass(dates))]
  }
  x <- .jwc_as_date(x); p <- .rd_to_gregorian(unclass(x))
  data.frame(date = as.character(x), month_start = p$day == 1L,
             month_end = p$day == days_in_month(p$year, p$month),
             year_start = p$month == 1L & p$day == 1L,
             year_end = p$month == 12L & p$day == 31L,
             leap_day = p$month == 2L & p$day == 29L,
             iso_year_boundary = iso_week_year(x) != p$year, stringsAsFactors = FALSE)
}
#' Scan civil-date or Gregorian-year boundaries
#' @param start,end Inclusive civil-date endpoints, or a vector of Gregorian
#'   years when `end` is omitted.
#' @return A data frame of boundary flags.
#' @export
boundary_scan <- function(start, end = NULL) {
  if (is.null(end)) return(boundary_cases(start))
  dates <- compile_calendar(rule_and(), start, end)$dates
  flags <- boundary_cases(dates)
  keep <- Reduce(`|`, flags[-1L], init = rep(FALSE, nrow(flags)))
  flags[keep, , drop = FALSE]
}
#' @export
calendar_conflicts <- function(x, y) {
  diff <- calendar_diff(x, y)
  list(shared_dates = diff$shared, x_only_count = length(diff$only_x), y_only_count = length(diff$only_y),
       identical = !length(diff$only_x) && !length(diff$only_y))
}
#' @export
explain_conflict <- function(x, y) calendar_conflicts(x, y)
#' @export
explain_rule_plan <- function(rule, start, end) {
  compiled <- compile_calendar(rule, start, end)
  list(operator = rule$op, domain = c(start = as.character(compiled$start), end = as.character(compiled$end)),
       normalized_rule = rule, selected_count = calendar_count(compiled), satisfiable = calendar_count(compiled) > 0L,
       evaluated_dates = unclass(compiled$end) - unclass(compiled$start) + 1L)
}
#' @export
explain_date <- function(x) {
  x <- .jwc_as_date(x); list(date = as.character(x), absolute_day = absolute_day(x),
    gregorian = list(year = civil_year(x), month = civil_month(x), day = civil_day(x)),
    weekday = weekday(x, labels = TRUE), ordinal = ordinal_date(x), iso_week = iso_week(x),
    leap_year = is_leap_year(civil_year(x)), julian = gregorian_to_julian(x),
    julian_day_number = julian_day_number(x), month_grid = list(
      row = ((weekday(civil_date(civil_year(x), civil_month(x), 1L)) - 1L + civil_day(x) - 1L) %/% 7L) + 1L,
      column = weekday(x)), boundaries = boundary_cases(x),
    structural_class = calendar_class(civil_year(x)))
}
#' @noRd
.jwc_explain_rule <- function(rule, date) {
  op <- rule$op
  if (op %in% c("and", "or")) {
    children <- lapply(rule$rules, .jwc_explain_rule, date = date)
    matched <- if (op == "and") all(vapply(children, `[[`, logical(1), "matched")) else any(vapply(children, `[[`, logical(1), "matched"))
    return(list(operator = op, matched = matched, children = children))
  }
  if (op == "not") {
    child <- .jwc_explain_rule(rule$rule, date)
    return(list(operator = op, matched = !child$matched, children = list(child)))
  }
  list(operator = op, matched = isTRUE(.jwc_eval_rule(rule, date)), parameters = rule[setdiff(names(rule), "op")])
}
#' @export
why_date <- function(calendar, x) {
  .jwc_check_calendars(calendar)
  x <- .jwc_as_date(x)
  if (length(x) != 1L || is.na(x)) .jwc_abort("`x` must be one non-missing date.", "jwcalendar_invalid_date")
  rd <- unclass(x)
  in_domain <- !is.na(calendar$start) && !is.na(calendar$end) && rd >= unclass(calendar$start) && rd <= unclass(calendar$end)
  trace <- if (inherits(calendar$rule, "jwc_rule")) .jwc_explain_rule(calendar$rule, x) else NULL
  list(date = x, in_domain = in_domain, included = in_domain && calendar_contains(calendar, x), explanation = trace)
}
#' @export
next_date <- function(rule, after, end) calendar_next(compile_calendar(rule, after, end), after)
