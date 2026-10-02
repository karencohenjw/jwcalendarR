# Technical conventions and invariants

## Civil-day kernel

The package accepts Gregorian years 1 through 9999 and stores day 1 as
0001-01-01 (Rata Die numbering). Gregorian fields are validated before an
absolute day is created. No POSIX timestamp, timezone, locale, or midnight
conversion is used. Base `Date` interoperability treats each `Date` value as a
whole number of days from 1970-01-01 and rejects fractional days.

The Gregorian day-before-year count for year `y` is

`365 * (y - 1) + floor((y - 1) / 4) - floor((y - 1) / 100) + floor((y - 1) / 400)`.

The proleptic Julian calendar uses a four-year leap cycle. Its conversion shares
integer Julian Day Number arithmetic, while Julian civil year/month/day fields
remain distinct from ordinal day-of-year and JDN. JDN is integer and uses the
standard noon-based day boundary; fractional astronomical Julian Date is not
implemented.

## ISO week dates

Weekdays are ISO numbered Monday=1 through Sunday=7. The Thursday in each
Monday-based week determines the ISO week-year. Week 1 is the week containing
January 4. Construction validates the resulting week-year and rejects week 53
when it is not present. Inputs are vectorized with length-one recycling only.

## Structural signatures

The signature algorithm identifier is `jwcalendar-structure-v1`. Month-grid
signatures encode a natural grid in row order, including its row count, empty
leading/trailing cells, and in-month day positions. The year fingerprint
concatenates those month signatures with normalized ISO-year boundary offsets;
it omits the calendar year itself so equivalent years share a fingerprint.
Changing signature semantics requires a new algorithm identifier.

## Rule evaluation and limits

Rule constructors produce data, not executable expressions. The compiler
enumerates every civil day in the inclusive domain, evaluates predicates, and
stores selected absolute-day integers in sorted unique order. This provides
simple deterministic semantics; runtime and storage are proportional to the
domain length. It does not provide symbolic SAT solving, bitsets, a complete
RFC 5545 recurrence implementation, holiday jurisdictions, or general
interval-vector operations.

All operations are offline. Tests and examples do not make network requests or
write files. The heavy 400-year validation script is separate from routine
package tests.
