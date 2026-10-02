\name{calendar-structure}
\alias{calendar_class}
\alias{calendar_classes}
\alias{calendar_cycle_summary}
\alias{calendar_equivalent}
\alias{calendar_fingerprint}
\alias{calendar_grid}
\alias{calendar_signature}
\alias{equivalent_years}
\alias{month_signature}
\title{Calendar structure and signatures}
\description{Natural month grids and signatures encode weekday alignment and month length. A year signature is the ordered sequence of its twelve month structures; equivalence therefore means identical layouts under the same first-weekday convention.}
\usage{
calendar_class(year, week_start = 1L)
calendar_classes(year, week_start = 1L)
calendar_cycle_summary(start_year = 2000L, week_start = 1L)
calendar_equivalent(year1, year2, week_start = 1L,
                                structure = c("month-grid", "iso-week", "print-layout"))
calendar_fingerprint(year, week_start = 1L)
calendar_grid(year, month, week_start = 1L, rows = "natural", adjacent = FALSE, iso_week_labels = FALSE)
calendar_signature(year, week_start = 1L)
equivalent_years(year, range = NULL, week_start = 1L)
month_signature(year, month, week_start = 1L)
}
\arguments{
  \item{year}{A whole Gregorian year from 1 to 9999; ISO week-year construction may also use 10000 at the supported upper boundary.}
  \item{week_start}{First displayed weekday; Monday=1 to Sunday=7 or a full English name.}
  \item{start_year}{A value whose required type and range are described in the function details.}
  \item{year1}{First Gregorian year to compare.}
  \item{year2}{Second Gregorian year to compare.}
  \item{structure}{Calendar equivalence definition.}
  \item{month}{A Gregorian month from 1 to 12, or a full English month name where accepted.}
  \item{rows}{Grid row policy: natural, 5, or 6.}
  \item{adjacent}{Whether adjacent-month cells are returned.}
  \item{iso_week_labels}{Whether ISO week coordinates are included.}
  \item{range}{Candidate Gregorian years to compare.}
}
\details{See the package README and vignettes for complete examples. Dates use strict ISO text or explicit integer civil coordinates. Inputs recycle only when their lengths are one or the common vector length.}
\seealso{\code{\link{jwcalendarR-package}}}
\keyword{dates}
