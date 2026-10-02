# Deterministic full-cycle validation. Run with Rscript tools/validate-heavy.R.
started <- Sys.time()
library(jwcalendarR)
total_days <- 0L
leap_years <- 0L
for (y in 2000:2399) {
  leap_years <- leap_years + as.integer(is_leap_year(y))
  for (month in 1:12) {
    expected_length <- c(31L, if (is_leap_year(y)) 29L else 28L, 31L, 30L,
                         31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)[month]
    stopifnot(days_in_month(y, month) == expected_length)
  }
  dates <- add_days(civil_date(y, 1, 1), 0:(if (is_leap_year(y)) 365L else 364L))
  total_days <- total_days + length(dates)
  stopifnot(all(as.character(as_jwc_date(as.character(dates))) == as.character(dates)))
  stopifnot(all(as.character(julian_to_gregorian(gregorian_to_julian(dates))) == as.character(dates)))
  stopifnot(all(as.character(from_iso_week_date(iso_week_year(dates), iso_week(dates)$week, weekday(dates))) == as.character(dates)))
  if (y < 2399L) {
    stopifnot(as.character(add_days(tail(dates, 1L), 1L)) ==
              as.character(civil_date(y + 1L, 1L, 1L)))
  }
}
stopifnot(total_days == 146097L, leap_years == 97L)
elapsed <- as.numeric(difftime(Sys.time(), started, units = "secs"))
evidence <- c(
  "# 400-year Gregorian-cycle validation",
  "",
  paste0("Run date: ", format(Sys.Date(), "%Y-%m-%d")),
  "Interval: 2000-01-01 through 2399-12-31 (inclusive).",
  paste0("Days checked: ", total_days, "."),
  paste0("Leap years checked: ", leap_years, "."),
  "Properties: strict date round-trip, proleptic-Julian conversion round-trip, ISO week-date round-trip, all month lengths, year-end day increments, 400-year day count, and leap-year count.",
  paste0("Elapsed seconds: ", format(elapsed, digits = 6), "."),
  "Result: PASS."
)
writeLines(evidence, "docs/400-YEAR-VALIDATION.md")
cat(paste(evidence, collapse = "\n"), "\n")
