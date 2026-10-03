#' @export
print.jwc_compiled_calendar <- function(x, ...) {
  cat("<jwcalendarR compiled calendar>\n")
  cat("Domain:", as.character(x$start), "through", as.character(x$end), "\n")
  cat("Selected dates:", length(x$dates), "of", unclass(x$end) - unclass(x$start) + 1L, "\n")
  if (length(x$dates)) {
    shown <- x$dates[seq_len(min(6L, length(x$dates)))]
    cat("First dates:", paste(as.character(shown), collapse = ", "))
    if (length(x$dates) > length(shown)) cat(", \u2026")
    cat("\n")
  }
  invisible(x)
}

#' @export
as.data.frame.jwc_compiled_calendar <- function(x, row.names = NULL, optional = FALSE, ...) {
  out <- data.frame(date = x$dates)
  if (!is.null(row.names)) rownames(out) <- row.names
  out
}

#' @export
print.jwc_signature <- function(x, ...) {
  cat("<jwcalendarR structural signature>")
  cat("\nYear:", x$year, "  Algorithm:", x$algorithm)
  cat("\nLeap year:", x$leap, "  January 1 weekday:", .jwc_weekday_names[x$january_first_weekday], "\n")
  invisible(x)
}

#' @export
as.data.frame.jwc_signature <- function(x, row.names = NULL, optional = FALSE, ...) {
  out <- data.frame(year = x$year, leap = x$leap,
    january_first_weekday = x$january_first_weekday,
    fingerprint = calendar_fingerprint(x$year, week_start = x$week_start), stringsAsFactors = FALSE)
  if (!is.null(row.names)) rownames(out) <- row.names
  out
}
