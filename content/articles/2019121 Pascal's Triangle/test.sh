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

assert_run "" 0
assert_run "1" 1
assert_run " 1
1 1" 2
assert_run "  1
 1 1
1 2 1" 3
assert_run "   1
  1 1
 1 2 1
1 3 3 1" 4
assert_run "    1
   1 1
  1 2 1
 1 3 3 1
1 4 6 4 1" 5
assert_run "      1      
     1 1
    1 2 1
   1 3 3 1
  1 4 6 4 1
1 5 10 10 5 1" 6
assert_run "       1
      1 1
     1 2 1
    1 3 3 1
   1 4 6 4 1
 1 5 10 10 5 1
1 6 15 20 15 6 1" 7
assert_run "         1
        1 1
       1 2 1
      1 3 3 1
     1 4 6 4 1
   1 5 10 10 5 1
  1 6 15 20 15 6 1
 1 7 21 35 35 21 7 1
1 8 28 56 70 56 28 8 1" 9
