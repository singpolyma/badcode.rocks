#!/bin/sh

if [ $# -ne 1 ]; then
		echo "Usage: sh test.sh /path/to/program" 1>&2
		exit 1
fi

PROGRAM="$1"

assert_run() {
	EXPECTED_EXIT="0"
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

assert_run 800 1
assert_run 1600 2 2
assert_run 0
assert_run 1520 1 2
assert_run 2160 1 2 3
assert_run 2560 1 2 3 4
assert_run 3000 1 2 3 4 5
assert_run 5120 1 1 2 2 3 3 4 5
assert_run 4080 1 1 2 2 3 4
assert_run 5560 1 1 2 2 3 3 4 4 5
assert_run 6000 1 1 2 2 3 3 4 4 5 5
assert_run 6800 1 1 2 2 3 3 4 4 5 5 1
assert_run 7520 1 1 2 2 3 3 4 4 5 5 1 2
assert_run 10240 1 1 2 2 3 3 4 5 1 1 2 2 3 3 4 5
