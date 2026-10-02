# Ecosystem and intended contribution

**Research snapshot: 2026-10-02.** This note describes documented scope; it is
not a claim that any package is incapable of related work. The proposed gap is
the integrated, reproducible workflow that connects a structural signature,
finite-domain rule compilation, date membership, boundary analysis, and
human-readable diagnostics. Each part must remain small and independently
verifiable. This package should not duplicate the mature parsing, time-zone,
interval, or plotting features below.

## Existing packages

| Package | Existing documented strengths | `jwcalendarR` boundary |
|---|---|---|
| [`clock`](https://clock.r-lib.org/) | Calendar-aware date/time types, parsing, arithmetic, invalid-date resolution, time zones and DST policies. | Do not reimplement timestamp/time-zone infrastructure. Keep the civil-date model explicit and timezone-free. |
| [`almanac`](https://search.r-project.org/CRAN/refmans/almanac/html/rrule.html) | Recurrence-rule sets, holiday calendars, observance and custom holiday definitions. The CRAN mirror records its archival on 2026-08-22. | Do not clone its recurrence DSL. Offer only a compact finite-date predicate compiler whose focus is structure, finite-domain results and audit explanations. Compare behavior, not brand positioning. |
| [`ivs`](https://ivs.ashfordharris.com/) | Interval vectors, interval relationships, grouping and set operations. | Do not build a general interval-vector type. Calendar set operations here are over finite selected civil dates. |
| [`lubridate`](https://lubridate.tidyverse.org/reference/lubridate-package.html) | Parsing, date-time manipulation, durations, periods, intervals and timezone utilities. | Use only where interoperability is needed; do not wrap or replace its date-time API. |
| [`bizdays`](https://cran.mirror.garr.it/mirrors/CRAN/web/packages/bizdays/index.html) | Business-day calculations based on holiday calendars and nonworking weekdays. | Do not claim financial business-day coverage; this initial engine has no exchange calendars or holiday database. |
| [`timeDate`](https://cran.r-project.org/web/packages/timeDate/index.html) | Time/date classes, financial centers and time-zone-aware data. | Avoid financial-market calendars and time-zone responsibilities. |
| [`timechange`](https://search.r-project.org/CRAN/refmans/timechange/html/timechange-package.html) | Efficient date-time updates with time-zone and daylight-saving handling. | No time-zone conversion or timestamp mutation in the core. |
| [`calendR`](https://cran.r-project.org/web/packages/calendR/index.html) | Customizable monthly/yearly and heatmap calendar graphics. | Do not provide a plotting system. The numeric grid is a structural representation for analysis. |

The project site [JW Calendar](https://jwcalendar.com/) provides calendar
reference and printable calendar material. This package is not a site client
or API wrapper. The site distinguishes its Julian Day Number reference from a
historical Julian civil calendar; this package documents both concepts
separately.

## Intended technical gap

The contribution is a local, deterministic pipeline with four linked objects
of analysis:

1. **Civil-date coordinates.** Strict Gregorian dates map to a timezone-free
   integer epoch, with explicit conversion to ordinal, ISO week, Julian civil,
   and integer Julian Day Number coordinates.
2. **Structure.** A natural-month grid is encoded into a stable signature;
   month and year classes can be compared without rendering a calendar.
3. **Finite rule compilation.** Small composable date predicates evaluate over
   an explicitly bounded domain and produce a set suitable for reproducible
   membership, next/previous, and set operations.
4. **Validation evidence.** Boundary flags, drift comparisons, explanations,
   and adversarial vectors expose dates around leap days, month ends, ISO-year
   boundaries, and the 400-year Gregorian cycle.

The first implementation is deliberately pure R. It does not claim a
general-purpose constraint solver, recurrence standard implementation,
optimized bitset engine, C++ acceleration, historical jurisdictional calendar
reform model, holiday database, or arbitrary interval algebra. Those would
require independent requirements and differential/benchmark evidence before
being proposed. The actual first-release API and its limitations take
precedence over the broader concept note.

## CRAN constraints to preserve

CRAN asks for a non-trivial contribution, portable source, limited side effects,
fast examples/tests, accurate package metadata, and checks on supported
platforms. Package names must not conflict case-insensitively with current or
past CRAN packages or current Bioconductor packages. The current [CRAN policy](https://stat.ethz.ch/CRAN/web/packages/policies.html),
[submission checklist](https://stat.ethz.ch/CRAN/web/packages/submission_checklist.html),
[Writing R Extensions](https://stat.ethz.ch/CRAN/doc/manuals/r-release/R-exts.html),
and [URL check guidance](https://stat.ethz.ch/CRAN/web/packages/URL_checks.html)
must be rechecked against the exact release candidate.

## Name check status

The name remains **provisional**. The development-only
`tools/check-name-availability.R` script compares the candidate without regard
to case against active CRAN package names, every package directory linked from
the full CRAN Archive index, and package names across the current repositories
returned by `BiocManager::repositories()`. It has not yet run in an R
environment. See [the evidence table](RELEASE-READINESS.md); do not treat the
candidate as cleared until a fresh successful run is recorded.
