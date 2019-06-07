#!/bin/sh

if [ $# -ne 1 ]; then
		echo "Usage: sh test.sh /path/to/program" 1>&2
		exit 1
fi

PROGRAM="$1"

assert_run() {
	EXPECTED_EXIT="$1"
	shift
	OUTPUT="$("$PROGRAM" "$@")"
	EXIT="$?"
	if [ "$EXPECTED_EXIT" -ne "$EXIT" ]; then
		echo "$PROGRAM $@" 1>&2
		echo "expected exit: $EXPECTED_EXIT" 1>&2
		echo "got: $EXIT" 1>&2
		exit 1
	fi
}

assert_run 0 "3-598-21508-8"
assert_run 1 "3-598-21508-9"
assert_run 0 "3-598-21507-X"
assert_run 1 "3-598-21507-A"
assert_run 1 "3-598-P1581-X"
assert_run 1 "3-598-2X507-9"
assert_run 0 "3598215088"
assert_run 0 "359821507X"
assert_run 1 "359821507"
assert_run 1 "3598215078X"
assert_run 1 "00"
assert_run 1 "3-598-21507"
assert_run 1 "35982150881"
assert_run 1 '!@#%!@'
assert_run 1 "3-598-21515-X"
assert_run 1 ""
assert_run 1 "134456729"
assert_run 1 "3132P34035"
assert_run 1 "98245726788"
