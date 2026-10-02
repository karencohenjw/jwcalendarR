#!/usr/bin/env Rscript

# Development-only check for case-insensitive package-name conflicts across
# active CRAN, the complete CRAN Archive index, and current Bioconductor repos.
# Run from the package root: Rscript tools/check-name-availability.R

candidate <- "jwcalendarR"
key <- tolower(candidate)
cran_url <- "https://cloud.r-project.org"
archive_url <- "https://cran.r-project.org/src/contrib/Archive/"

cran <- available.packages(repos = cran_url, filters = list())
active_names <- rownames(cran)
active_match <- active_names[tolower(active_names) == key]

archive_lines <- readLines(archive_url, warn = FALSE)
hrefs <- unlist(regmatches(
  archive_lines,
  gregexpr("href=[\"'][^\"']+[\"']", archive_lines, perl = TRUE)
), use.names = FALSE)
hrefs <- sub("^href=[\"']", "", hrefs)
hrefs <- sub("[\"']$", "", hrefs)
archive_names <- sub("/$", "", hrefs[grepl("/$", hrefs)])
archive_names <- archive_names[!archive_names %in% c("", ".", "..")]
archive_match <- archive_names[tolower(archive_names) == key]

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = cran_url)
}
bioc_repos <- BiocManager::repositories()
bioc_repos <- bioc_repos[grepl("bioconductor.org", bioc_repos, fixed = TRUE)]
if (!length(bioc_repos)) {
  stop("BiocManager::repositories() returned no Bioconductor repositories.")
}
bioc <- available.packages(repos = bioc_repos, filters = list())
bioc_names <- rownames(bioc)
bioc_match <- bioc_names[tolower(bioc_names) == key]

checked_on <- format(Sys.Date(), "%Y-%m-%d")
to_result <- function(x) {
  if (length(x)) paste0("CONFLICT: ", paste(unique(x), collapse = ", ")) else "No case-insensitive match found"
}
repo_list <- paste0("- `", names(bioc_repos), "`: ", unname(bioc_repos), collapse = "\n")
report <- c(
  "# Package-name availability evidence",
  "",
  paste0("Checked on: **", checked_on, "** (R `", getRversion(), "`)."),
  "",
  paste0("Candidate: **`", candidate, "`** (case-insensitive comparison)."),
  "",
  "| Registry | Source | Result |",
  "|---|---|---|",
  paste0("| Active CRAN | [", cran_url, "](", cran_url, ") | ", to_result(active_match), " |"),
  paste0("| Complete CRAN Archive index | [", archive_url, "](", archive_url, ") | ", to_result(archive_match), " |"),
  paste0("| Current Bioconductor repositories | `BiocManager::repositories()` | ", to_result(bioc_match), " |"),
  "",
  "Bioconductor repositories queried:",
  repo_list,
  "",
  "This is an automated availability snapshot, not a reservation or guarantee of acceptance. Re-run immediately before any public release or CRAN submission. Any conflict must be resolved by choosing a different package name.",
  ""
)
writeLines(report, "docs/NAME-AVAILABILITY.md")

if (length(active_match) || length(archive_match) || length(bioc_match)) {
  stop("Package name conflict detected; do not publish or submit this package name.")
}
message("No case-insensitive match found in active CRAN, CRAN Archive, or current Bioconductor repositories.")
