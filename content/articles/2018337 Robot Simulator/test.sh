#!/bin/sh

if [ $# -ne 1 ]; then
		echo "Usage: sh test.sh /path/to/program" 1>&2
		exit 1
fi

PROGRAM="$1"

assert_run() {
	OUTPUT="$("$PROGRAM" "$1" "$2" "$3" "$4")"
	if [ "$5" != "$OUTPUT" ]; then
		echo "$PROGRAM $1 $2 $3 '$4'" 1>&2
		echo "expected: $5" 1>&2
		echo "got: $OUTPUT" 1>&2
		exit 1
	fi
}

assert_run 0 0 N "" "0 0 N"
assert_run -1 -1 S "" "-1 -1 S"
assert_run 0 0 N "R" "0 0 E"
assert_run 0 0 E "R" "0 0 S"
assert_run 0 0 S "R" "0 0 W"
assert_run 0 0 W "R" "0 0 N"
assert_run 0 0 N "L" "0 0 W"
assert_run 0 0 W "L" "0 0 S"
assert_run 0 0 S "L" "0 0 E"
assert_run 0 0 E "L" "0 0 N"
assert_run 0 0 N "A" "0 1 N"
assert_run 0 0 S "A" "0 -1 S"
assert_run 0 0 E "A" "1 0 E"
assert_run 0 0 W "A" "-1 0 W"
assert_run 0 0 N "LAAARALA" "-4 1 W"
assert_run 2 -7 E "RRAAAAALA" "-3 -8 S"
assert_run 8 4 S "LAAARRRALLLL" "11 5 N"
