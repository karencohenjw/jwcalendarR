\name{calendar-validation}
\alias{[.jwc_date}
\alias{as.Date.jwc_date}
\alias{as.character.jwc_date}
\alias{audit_date_columns}
\alias{boundary_cases}
\alias{boundary_scan}
\alias{c.jwc_date}
\alias{calendar_between}
\alias{calendar_complement}
\alias{calendar_conflicts}
\alias{calendar_diff}
\alias{calendar_intersection}
\alias{calendar_set_difference}
\alias{calendar_symmetric_difference}
\alias{calendar_test_vectors}
\alias{calendar_union}
\alias{date_drift}
\alias{explain_conflict}
\alias{explain_date}
\alias{explain_rule_plan}
\alias{format.jwc_date}
\alias{print.jwc_date}
\alias{print.jwc_compiled_calendar}
\alias{print.jwc_signature}
\alias{as.data.frame.jwc_compiled_calendar}
\alias{as.data.frame.jwc_signature}
\alias{temporal_audit}
\alias{why_date}
\title{Calendar sets and temporal validation}
\description{Compiled calendars support finite set operations and membership queries. Audit helpers report date shifts and structural boundaries without inferring timestamps, time zones, or locale-dependent parsing.}
\usage{
\method{as.Date}{jwc_date}(x, ...)
\method{as.character}{jwc_date}(x, ...)
audit_date_columns(data, before, after)
boundary_cases(x)
boundary_scan(start, end = NULL)
\method{c}{jwc_date}(..., recursive = FALSE)
calendar_between(x, start, end)
calendar_complement(x, start = x$start, end = x$end)
calendar_conflicts(x, y)
calendar_diff(x, y)
calendar_intersection(x, y)
calendar_set_difference(x, y)
calendar_symmetric_difference(x, y)
calendar_test_vectors(years = c(1L, 4L, 100L, 400L, 1900L, 2000L, 2024L, 9999L),
                                  cases = c("all", "leap", "month-end", "iso-week", "julian", "ordinal", "year-boundary"))
calendar_union(...)
date_drift(before, after)
explain_conflict(x, y)
explain_date(x)
explain_rule_plan(rule, start, end)
\method{format}{jwc_date}(x, ...)
\method{print}{jwc_date}(x, ...)
\method{print}{jwc_compiled_calendar}(x, ...)
\method{print}{jwc_signature}(x, ...)
\method{as.data.frame}{jwc_compiled_calendar}(x, row.names = NULL, optional = FALSE, ...)
\method{as.data.frame}{jwc_signature}(x, row.names = NULL, optional = FALSE, ...)
temporal_audit(before, after)
why_date(calendar, x)
}
\arguments{
  \item{x}{A supported civil date, date vector, signature, or compiled calendar, according to the function.}
  \item{...}{Additional arguments passed to the generic or combined rule constructor.}
  \item{data}{A data frame containing the date columns to compare.}
  \item{before}{Original or earlier civil-date values.}
  \item{after}{Later civil-date values.}
  \item{start}{Inclusive Gregorian date or finite-domain start.}
  \item{end}{Inclusive Gregorian date or finite-domain end.}
  \item{recursive}{A value whose required type and range are described in the function details.}
  \item{y}{A Gregorian year.}
  \item{years}{Gregorian years to inspect.}
  \item{cases}{Boundary-vector families to return.}
  \item{rule}{A rule expression constructed by the package rule constructors.}
  \item{row.names}{Optional row names.}
  \item{optional}{Whether generated column names may be changed.}
  \item{calendar}{A compiled finite calendar object.}
}
\details{See the package README and vignettes for complete examples. Dates use strict ISO text or explicit integer civil coordinates. Inputs recycle only when their lengths are one or the common vector length.}
\seealso{\code{\link{jwcalendarR-package}}}
\keyword{dates}
