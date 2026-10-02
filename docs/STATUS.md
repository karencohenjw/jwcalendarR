# Development status snapshot

Snapshot date: 2026-10-02. The existing pure-R source has been retained and
release engineering work is in progress. This project is not submitted to
CRAN and is not yet a tested release candidate.

| Area | Current state |
|---|---|
| Gregorian civil dates, proleptic Julian conversion, integer JDN, ordinal and ISO week coordinates | Implemented in source; not yet executed in R during this release audit |
| Calendar grids, structural signatures and equivalence | Implemented; fingerprint stability remains to be exercised in R |
| Finite date-rule DSL and set operations | Implemented over explicitly bounded finite domains; not a symbolic solver or general interval algebra |
| Boundary, drift and audit helpers | Implemented in source; runtime behavior remains unverified |
| Test suite | Existing testthat tests retained; no test run evidence yet |
| 400-year validation | Script now targets 2000-01-01 through 2399-12-31 and checks 146097 days and 97 leap years; not run yet |
| Dependencies | Runtime is base R; testthat, knitr and rmarkdown are suggested for tests/vignettes |
| C++ parity and benchmarks | Not implemented; no acceleration claim is made |
| Name availability | Auditable active CRAN, full CRAN Archive, and current Bioconductor check added; not run yet |
| Build and platform checks | Exact-tarball GitHub Actions workflow prepared for Linux release/devel/oldrel, Windows, and macOS; no workflow result exists yet |
| Winbuilder / R-hub | Not run |
| Repository and issue tracker | Public repository created at the preferred GitHub location; source push and URL checks pending |
| Maintainer metadata | Karen Cohen, `jwcalendarcom@gmail.com` |
| CRAN submission / confirmation / publication | Not submitted |

See [release readiness](RELEASE-READINESS.md) for the evidence table and
[ecosystem gap](ECOSYSTEM-GAP.md) for the scope comparison. No unavailable
local R installation is treated as a test result; remote checks still need to
run before release decisions.
