# Deterministic full-cycle validation. Run with Rscript tools/validate-heavy.R.
started <- Sys.time()
library(jwcalendarR)
.cycle_check <- function(year, stage, code) {
  tryCatch(force(code), error = function(e) {
    stop(sprintf("400-year validation failed for %d at %s: %s",
                 year, stage, conditionMessage(e)), call. = FALSE)
  })
}
total_days <- 0L
leap_years <- 0L
for (y in 2000:2399) {
  leap_years <- leap_years + as.integer(is_leap_year(y))
  for (month in 1:12) {
    expected_length <- c(31L, if (is_leap_year(y)) 29L else 28L, 31L, 30L,
                         31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)[month]
    .cycle_check(y, sprintf("month length %02d", month),
                 stopifnot(days_in_month(y, month) == expected_length))
  }
  dates <- .cycle_check(y, "constructing year dates",
                        add_days(civil_date(y, 1, 1), 0:(if (is_leap_year(y)) 365L else 364L)))
  total_days <- total_days + length(dates)
  .cycle_check(y, "strict date round-trip",
               stopifnot(all(as.character(as_jwc_date(as.character(dates))) == as.character(dates))))
  .cycle_check(y, "Gregorian-Julian round-trip", {
    julian <- gregorian_to_julian(dates)
    returned <- julian_to_gregorian(julian)
    mismatches <- which(as.character(returned) != as.character(dates))
    if (length(mismatches)) {
      i <- mismatches[[1L]]
      stop(sprintf("%s -> %04d-%02d-%02d -> %s", as.character(dates[[i]]),
                   julian$year[[i]], julian$month[[i]], julian$day[[i]],
                   as.character(returned[[i]])), call. = FALSE)
    }
  })
  .cycle_check(y, "ISO week-date round-trip",
               stopifnot(all(as.character(from_iso_week_date(iso_week_year(dates), iso_week(dates)$week, weekday(dates))) == as.character(dates))))
  if (y < 2399L) {
    .cycle_check(y, "year-end increment",
                 stopifnot(as.character(add_days(tail(dates, 1L), 1L)) ==
                           as.character(civil_date(y + 1L, 1L, 1L))))
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
