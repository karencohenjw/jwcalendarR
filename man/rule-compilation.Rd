\name{rule-compilation}
\alias{between_dates}
\alias{calendar_contains}
\alias{calendar_count}
\alias{calendar_domain}
\alias{calendar_next}
\alias{calendar_previous}
\alias{compile_calendar}
\alias{every_n_days}
\alias{every_n_weeks}
\alias{exclude}
\alias{include}
\alias{is_satisfiable}
\alias{last_weekday}
\alias{next_date}
\alias{nth_weekday}
\alias{on_month}
\alias{on_month_day}
\alias{on_ordinal_day}
\alias{on_weekday}
\alias{rule_and}
\alias{rule_not}
\alias{rule_or}
\title{Finite date-rule compilation}
\description{Rule constructors create a small composable predicate tree. compile_calendar() evaluates that tree over an inclusive finite domain and stores the selected civil dates. Work grows with the number of domain days; this is not a general SAT solver or high-performance recurrence engine.}
\usage{
between_dates(start, end)
calendar_contains(calendar, x)
calendar_count(calendar)
calendar_domain(start, end)
calendar_next(calendar, x, inclusive = FALSE)
calendar_previous(calendar, x, inclusive = FALSE)
compile_calendar(rule, start, end = NULL)
every_n_days(n, anchor)
every_n_weeks(n, weekday, anchor)
exclude(x)
include(x)
is_satisfiable(rule, start, end)
last_weekday(weekday, month = NULL)
next_date(rule, after, end)
nth_weekday(weekday, n, month = NULL)
on_month(month)
on_month_day(month, day = NULL)
on_ordinal_day(ordinal)
on_weekday(weekday)
rule_and(...)
rule_not(x)
rule_or(...)
}
\arguments{
  \item{start}{Inclusive Gregorian date or finite-domain start.}
  \item{end}{Inclusive Gregorian date or finite-domain end.}
  \item{calendar}{A compiled finite calendar object.}
  \item{x}{A supported civil date, date vector, signature, or compiled calendar, according to the function.}
  \item{inclusive}{Whether the query includes the supplied date.}
  \item{rule}{A rule expression constructed by the package rule constructors.}
  \item{n}{A whole-number offset or recurrence interval; its valid range depends on the function.}
  \item{anchor}{Anchor civil date for an interval rule.}
  \item{weekday}{An ISO weekday number (Monday=1 to Sunday=7) or a full English weekday name where accepted.}
  \item{month}{A Gregorian month from 1 to 12, or a full English month name where accepted.}
  \item{after}{Later civil-date values.}
  \item{day}{A valid day-of-month or ordinal day as described by the function.}
  \item{ordinal}{A day-of-year number.}
  \item{...}{Additional arguments passed to the generic or combined rule constructor.}
}
\details{See the package README and vignettes for complete examples. Dates use strict ISO text or explicit integer civil coordinates. Inputs recycle only when their lengths are one or the common vector length.}
\seealso{\code{\link{jwcalendarR-package}}}
\keyword{dates}
