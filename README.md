# jwcalendarR

`jwcalendarR` is an R package for structural calendar analysis, finite-domain
date-rule compilation, and temporal validation. Civil dates are represented as
integer days; the core never converts them through midnight timestamps or time
zones.

The first release focuses on a transparent pure-R reference implementation:
validated Gregorian dates, proleptic Julian conversion, ordinal and ISO week
coordinates, natural calendar grids and signatures, a small rule expression
language, finite-domain set operations, boundary diagnostics, and reproducible
test vectors. The intended contribution is the connected workflow from
calendar structure to rule selection and auditable validation, not a replacement
for established date-time or interval packages.

```r
library(jwcalendarR)

workdays <- compile_calendar(
  rule_and(on_weekday(1:5), rule_not(on_month_day(1))),
  "2027-01-01", "2027-12-31"
)
calendar_count(workdays)
explain_date("2027-01-01")
```

See [the ecosystem gap note](docs/ECOSYSTEM-GAP.md) for scope and comparison,
and the vignettes for date representation, rule compilation, structure, and
validation. This package is under development; see
[release readiness](docs/RELEASE-READINESS.md) for checks that remain before
any CRAN submission.

## License

MIT. Copyright 2026 Karen Cohen.
