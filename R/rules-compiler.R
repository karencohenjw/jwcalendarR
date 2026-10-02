.jwc_rule <- function(op, ...) structure(c(list(op = op), list(...)), class = c("jwc_calendar_rule", "jwc_rule"))

#' Build declarative date-rule expressions
#' @param month,day,weekday,ordinal Whole-number selectors.
#' @param x One or more rule objects.
#' @param n Positive recurrence interval.
#' @return A composable `jwc_rule` expression.
#' @examples
#' rule_and(on_month(2), on_weekday(1:5))
#' @export
on_month <- function(month) .jwc_rule("month", month = .jwc_month(month))
#' @rdname on_month
#' @export
on_month_day <- function(month, day = NULL) {
  if (is.null(day)) .jwc_rule("month_day", month = NULL, day = .jwc_number(month, "day", 1, 31, FALSE))
  else .jwc_rule("month_day", month = .jwc_month(month), day = .jwc_number(day, "day", 1, 31, FALSE))
}
#' @rdname on_month
#' @export
on_weekday <- function(weekday) .jwc_rule("weekday", weekday = .jwc_weekday(weekday))
#' @rdname on_month
#' @export
on_ordinal_day <- function(ordinal) .jwc_rule("ordinal", ordinal = .jwc_number(ordinal, "ordinal", 1, 366, FALSE))
#' @rdname on_month
#' @export
nth_weekday <- function(weekday, n, month = NULL) {
  wd <- .jwc_weekday(weekday); n <- .jwc_number(n, "n", -5, 5, FALSE)
  if (any(n == 0)) .jwc_abort("`n` must be nonzero.", "jwcalendar_invalid_rule")
  .jwc_rule("nth_weekday", weekday = wd, n = n, month = if (is.null(month)) NULL else .jwc_month(month))
}
#' @rdname on_month
#' @export
last_weekday <- function(weekday, month = NULL) .jwc_rule("last_weekday", weekday = .jwc_weekday(weekday), month = if (is.null(month)) NULL else .jwc_month(month))
#' @rdname on_month
#' @export
every_n_days <- function(n, anchor) .jwc_rule("every_days", n = .jwc_number(n, "n", 1, 3652059, FALSE), anchor = .jwc_as_date(anchor))
#' @rdname on_month
#' @export
every_n_weeks <- function(n, weekday, anchor) .jwc_rule("every_weeks", n = .jwc_number(n, "n", 1, 521721, FALSE), weekday = .jwc_weekday(weekday), anchor = .jwc_as_date(anchor))
#' @rdname on_month
#' @export
between_dates <- function(start, end) {
  a <- .jwc_as_date(start); b <- .jwc_as_date(end)
  if (length(a) != 1L || length(b) != 1L || is.na(a) || is.na(b) || unclass(a) > unclass(b)) .jwc_abort("`start` and `end` must be ordered scalar dates.", "jwcalendar_invalid_rule")
  .jwc_rule("between", start = a, end = b)
}
#' @rdname on_month
#' @export
rule_and <- function(...) .jwc_rule("and", rules = list(...))
#' @rdname on_month
#' @export
rule_or <- function(...) .jwc_rule("or", rules = list(...))
#' @rdname on_month
#' @export
rule_not <- function(x) .jwc_rule("not", rule = x)
#' @rdname on_month
#' @export
include <- function(x) rule_and(x)
#' @rdname on_month
#' @export
exclude <- function(x) rule_not(x)

.jwc_eval_rule <- function(rule, dates) {
  if (!inherits(rule, "jwc_rule")) .jwc_abort("Expected a rule created by jwcalendarR.", "jwcalendar_invalid_rule")
  p <- .rd_to_gregorian(unclass(dates)); op <- rule$op
  switch(op,
    month = p$month %in% rule$month,
    month_day = p$day %in% rule$day & (is.null(rule$month) | p$month %in% rule$month),
    weekday = weekday(dates) %in% rule$weekday,
    ordinal = ordinal_day(dates) %in% rule$ordinal,
    nth_weekday = {
      allowed_month <- if (is.null(rule$month)) rep(TRUE, length(dates)) else p$month %in% rule$month
      idx <- ifelse(rule$n > 0, (p$day - 1L) %/% 7L + 1L, -((days_in_month(p$year, p$month) - p$day) %/% 7L + 1L))
      allowed_month & weekday(dates) %in% rule$weekday & idx %in% rule$n
    },
    last_weekday = {
      allowed_month <- if (is.null(rule$month)) rep(TRUE, length(dates)) else p$month %in% rule$month
      allowed_month & weekday(dates) %in% rule$weekday & p$day + 7L > days_in_month(p$year, p$month)
    },
    every_days = (unclass(dates) - unclass(rule$anchor)) %% rule$n == 0L,
    every_weeks = weekday(dates) == rule$weekday & ((unclass(dates) - unclass(rule$anchor)) %/% 7L) %% rule$n == 0L,
    between = unclass(dates) >= unclass(rule$start) & unclass(dates) <= unclass(rule$end),
    and = Reduce(`&`, lapply(rule$rules, .jwc_eval_rule, dates = dates), init = rep(TRUE, length(dates))),
    or = Reduce(`|`, lapply(rule$rules, .jwc_eval_rule, dates = dates), init = rep(FALSE, length(dates))),
    not = !.jwc_eval_rule(rule$rule, dates),
    .jwc_abort(sprintf("Unknown rule operator `%s`.", op), "jwcalendar_invalid_rule")
  )
}

#' Compile a date rule over a finite civil-date domain
#' @param rule A declarative rule expression.
#' @param start,end Inclusive Gregorian domain endpoints.
#' @return A compiled finite calendar object containing selected dates and its
#'   original rule expression.
#' @examples
#' compile_calendar(on_weekday(1:5), "2027-01-01", "2027-01-31")
#' @export
compile_calendar <- function(rule, start, end = NULL) {
  if (inherits(start, "jwc_calendar") && is.null(end)) { end <- start$end; start <- start$start }
  if (is.null(end)) .jwc_abort("Supply a domain object or both `start` and `end`.", "jwcalendar_invalid_domain")
  a <- .jwc_as_date(start); b <- .jwc_as_date(end)
  if (length(a) != 1L || length(b) != 1L || is.na(a) || is.na(b) || unclass(a) > unclass(b)) .jwc_abort("`start` and `end` must be ordered scalar dates.", "jwcalendar_invalid_domain")
  domain <- structure(seq.int(unclass(a), unclass(b)), class = "jwc_date")
  selected <- domain[.jwc_eval_rule(rule, domain)]
  structure(list(start = a, end = b, dates = selected, rule = rule), class = c("jwc_compiled_calendar", "jwc_calendar"))
}

#' @export
calendar_domain <- function(start, end) compile_calendar(rule_and(), start, end)
#' @export
calendar_contains <- function(calendar, x) {
  if (!inherits(calendar, "jwc_calendar")) .jwc_abort("`calendar` must be compiled.", "jwcalendar_invalid_calendar")
  unclass(.jwc_as_date(x)) %in% unclass(calendar$dates)
}
#' @export
calendar_count <- function(calendar) length(calendar$dates)
#' @export
is_satisfiable <- function(rule, start, end) calendar_count(compile_calendar(rule, start, end)) > 0L
#' @export
calendar_next <- function(calendar, x, inclusive = FALSE) {
  rd <- unclass(.jwc_as_date(x)); candidates <- unclass(calendar$dates)
  if (length(rd) != 1L || is.na(rd) || !is.logical(inclusive) || length(inclusive) != 1L || is.na(inclusive)) .jwc_abort("`x` and `inclusive` must be non-missing scalars.", "jwcalendar_invalid_date")
  candidates <- candidates[if (inclusive) candidates >= rd else candidates > rd]
  if (!length(candidates)) return(structure(NA_integer_, class = "jwc_date"))
  structure(as.integer(min(candidates)), class = "jwc_date")
}
#' @export
calendar_previous <- function(calendar, x, inclusive = FALSE) {
  rd <- unclass(.jwc_as_date(x)); candidates <- unclass(calendar$dates)
  if (length(rd) != 1L || is.na(rd) || !is.logical(inclusive) || length(inclusive) != 1L || is.na(inclusive)) .jwc_abort("`x` and `inclusive` must be non-missing scalars.", "jwcalendar_invalid_date")
  candidates <- candidates[if (inclusive) candidates <= rd else candidates < rd]
  if (!length(candidates)) return(structure(NA_integer_, class = "jwc_date"))
  structure(as.integer(max(candidates)), class = "jwc_date")
}
