# Release-readiness evidence

Snapshot date: 2026-10-02. This is a candidate checklist, not a declaration
that the CRAN gate has passed. A result is marked **PASS** only after the
referenced command or service has produced auditable evidence for the exact
candidate.

| Gate | Evidence | Result | URL / artifact |
|---|---|---|---|
| Active CRAN name | `tools/check-name-availability.R`; not run yet | PENDING | [CRAN package index](https://cloud.r-project.org) |
| Complete CRAN Archive name | Full archive directory index comparison in the same script; not run yet | PENDING | [CRAN Archive](https://cran.r-project.org/src/contrib/Archive/) |
| Current Bioconductor name | `BiocManager::repositories()` indexes; not run yet | PENDING | [Bioconductor](https://bioconductor.org/) |
| Unit tests | `tests/testthat/`; not run in local environment | PENDING | GitHub Actions check artifact after repository publication |
| Full 400-year cycle | `tools/validate-heavy.R` covers 2000-01-01 through 2399-12-31; not run yet | PENDING | CI artifact `400-year-validation-evidence` |
| Linux R-release | Exact source tarball check; not run yet | PENDING | CI artifact `check-linux-release` |
| Linux R-devel | Exact source tarball check; not run yet | PENDING | CI artifact `check-linux-devel` |
| Linux R-oldrel | Exact source tarball check; not run yet | PENDING | CI artifact `check-linux-oldrel` |
| Windows R-release | Exact source tarball check; not run yet | PENDING | CI artifact `check-windows-release` |
| macOS R-release | Exact source tarball check; not run yet | PENDING | CI artifact `check-macos-release` |
| `R CMD build` | Release workflow builds the source archive once; not run yet | PENDING | CI artifact `release-source-tarball` |
| Exact tarball `R CMD check --as-cran` | CI checks the same uploaded archive on each matrix platform; manual is omitted in matrix checks | PENDING | CI `00check.log` artifacts |
| Winbuilder | Current Winbuilder instructions require a built archive; not submitted | PENDING | [Winbuilder](https://win-builder.r-project.org/) |
| R-hub | Supplemental service; not run | PENDING | [R-hub v2](https://r-hub.github.io/rhub/) |
| Public GitHub repository | Repository created; source commit has not yet been pushed | PENDING | [jwcalendarR](https://github.com/karencohenjw/jwcalendarR) |
| Homepage / repository URLs | `DESCRIPTION` now lists homepage, repository, and issue tracker; URL checks have not run | PENDING | [JW Calendar](https://jwcalendar.com/), [GitHub issues](https://github.com/karencohenjw/jwcalendarR/issues) |
| Clean install | Not run | PENDING | Release workflow install from the exact source archive |
| Source-path and package-content audit | To be performed against the built archive | PENDING | Release workflow artifacts |

Candidate metadata currently records version `0.1.0`, maintainer Karen Cohen
(`jwcalendarcom@gmail.com`), and `License: MIT + file LICENSE`. The full
archive/Bioconductor name check, package execution, cross-platform checks,
URL checks, Winbuilder result, and exact final R-devel check remain unverified.
Do not submit to CRAN or describe this candidate as release-ready until those
gates have actual passing evidence. A GitHub Actions workflow is prepared;
results are pending the initial source push.
