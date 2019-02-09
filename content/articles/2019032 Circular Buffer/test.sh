#!/bin/sh

if [ $# -ne 1 ]; then
		echo "Usage: sh test.sh /path/to/program" 1>&2
		exit 1
fi

PROGRAM="$1"

assert_run() {
	EXPECTED_EXIT="$1"
	shift
	EXPECTED_OUTPUT="$1"
	shift
	OUTPUT="$("$PROGRAM" "$@")"
	EXIT="$?"
	if [ "$EXPECTED_EXIT" -ne "$EXIT" ]; then
		echo "$PROGRAM $@" 1>&2
		echo "expected exit: $EXPECTED_EXIT" 1>&2
		echo "got: $EXIT" 1>&2
		exit 1
	fi

	if [ "$EXPECTED_EXIT" -eq 0 -a "$EXPECTED_OUTPUT" != "$OUTPUT" ]; then
		echo "$PROGRAM $@" 1>&2
		echo "expected: $EXPECTED_OUTPUT" 1>&2
		echo "got: $OUTPUT" 1>&2
		exit 1
	fi
}

assert_run 1 "" 1 READ
assert_run 0 "1" 1 1 READ
assert_run 1 "1" 1 1 READ READ
assert_run 1 "1
2" 2 1 2 READ READ READ
assert_run 2 "" 1 1 2
assert_run 0 "1
2" 1 1 READ 2 READ
assert_run 0 "1
2
3" 3 1 2 READ 3 READ READ
assert_run 1 "" 1 1 CLEAR READ
assert_run 0 "2" 1 1 CLEAR 2 READ
assert_run 0 "1" 1 CLEAR 1 READ
assert_run 1 "1
2" 2 1 OVERWRITE 2 READ READ READ
assert_run 0 "2
A" 2 1 2 OVERWRITE A READ READ
assert_run 0 "1
3
4
5" 3 1 2 3 READ 4 OVERWRITE 5 READ READ READ
