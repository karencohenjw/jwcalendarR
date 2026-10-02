\name{civil-dates}
\alias{absolute_day}
\alias{add_days}
\alias{add_months}
\alias{add_years}
\alias{as_iso_week_date}
\alias{as_jwc_date}
\alias{civil_date}
\alias{civil_day}
\alias{civil_month}
\alias{civil_year}
\alias{days_in_month}
\alias{difference_days}
\alias{from_iso_week_date}
\alias{from_ordinal_date}
\alias{gregorian_to_julian}
\alias{is_leap_year}
\alias{iso_week}
\alias{iso_week_year}
\alias{iso_weekday}
\alias{julian_day_number}
\alias{julian_to_gregorian}
\alias{ordinal_date}
\alias{ordinal_day}
\alias{weekday}
\title{Civil dates and coordinate conversions}
\description{Civil values are whole days, not timestamps. The representation supports Gregorian arithmetic, proleptic Julian coordinates, ordinal dates, ISO week dates, and integer Julian Day Numbers. Invalid fields and out-of-domain arithmetic raise typed errors.}
\usage{
absolute_day(x)
add_days(x, n)
add_months(x, n, invalid = c("error", "previous-valid"))
add_years(x, n, invalid = c("error", "previous-valid"))
as_iso_week_date(x)
as_jwc_date(x)
civil_date(year, month, day)
civil_day(x)
civil_month(x)
civil_year(x)
days_in_month(year, month)
difference_days(end, start)
from_iso_week_date(year, week, weekday = 1L)
from_ordinal_date(year, day)
gregorian_to_julian(x)
is_leap_year(year)
iso_week(x)
iso_week_year(x)
iso_weekday(x)
julian_day_number(x)
julian_to_gregorian(year, month = NULL, day = NULL)
ordinal_date(x)
ordinal_day(x)
weekday(x, labels = FALSE)
}
\arguments{
  \item{x}{A supported civil date, date vector, signature, or compiled calendar, according to the function.}
  \item{n}{A whole-number offset or recurrence interval; its valid range depends on the function.}
  \item{invalid}{Policy for an invalid target month day: error or previous-valid.}
  \item{year}{A whole Gregorian year from 1 to 9999; ISO week-year construction may also use 10000 at the supported upper boundary.}
  \item{month}{A Gregorian month from 1 to 12, or a full English month name where accepted.}
  \item{day}{A valid day-of-month or ordinal day as described by the function.}
  \item{end}{Inclusive Gregorian date or finite-domain end.}
  \item{start}{Inclusive Gregorian date or finite-domain start.}
  \item{week}{An ISO week number.}
  \item{weekday}{An ISO weekday number (Monday=1 to Sunday=7) or a full English weekday name where accepted.}
  \item{labels}{A value whose required type and range are described in the function details.}
}
\details{See the package README and vignettes for complete examples. Dates use strict ISO text or explicit integer civil coordinates. Inputs recycle only when their lengths are one or the common vector length.}
\seealso{\code{\link{jwcalendarR-package}}}
\keyword{dates}
