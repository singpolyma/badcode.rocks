#!/bin/sh

if [ $# -ne 1 ]; then
		echo "Usage: sh test.sh /path/to/program" 1>&2
		exit 1
fi

PROGRAM="$1"

assert_run() {
	EXPECTED_EXIT="$1"
	shift
	EXPECTED_SCORE="$1"
	shift
	OUTPUT="$("$PROGRAM" "$@")"
	EXIT="$?"
	if [ "$EXPECTED_EXIT" -ne "$EXIT" ]; then
		echo "$PROGRAM $@" 1>&2
		echo "expected exit: $EXPECTED_EXIT" 1>&2
		echo "got: $EXIT" 1>&2
		exit 1
	fi

	if [ "$EXPECTED_EXIT" -eq 0 -a "$EXPECTED_SCORE" != "$OUTPUT" ]; then
		echo "$PROGRAM $@" 1>&2
		echo "expected: $EXPECTED_SCORE" 1>&2
		echo "got: $OUTPUT" 1>&2
		exit 1
	fi
}

assert_run 1 "" 11
assert_run 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 3 ""
assert_run 3 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 2 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 0 90 3 6 3 6 3 6 3 6 3 6 3 6 3 6 3 6 3 6 3 6
assert_run 0 10 6 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 0 16 6 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 0 31 5 5 3 7 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 0 17 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 5 7
assert_run 0 10 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 0 26 10 5 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 0 81 10 10 10 5 3 0 0 0 0 0 0 0 0 0 0 0 0
assert_run 0 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 7 1
assert_run 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 7 3
assert_run 0 30 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 10 10
assert_run 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 3 10
assert_run 0 300 10 10 10 10 10 10 10 10 10 10 10 10
assert_run 1 "" 5 6
assert_run 1 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 11
assert_run 1 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 5 6
assert_run 1 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 6 10
assert_run 3 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10
assert_run 3 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 10
assert_run 3 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 5
assert_run 2 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 3 2 2
assert_run 2 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10 3 2 2
