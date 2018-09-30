#!/bin/sh

if [ $# -ne 1 ]; then
		echo "Usage: sh test.sh /path/to/program" 1>&2
		exit 1
fi

PROGRAM="$1"

assert_run() {
	OUTPUT="$("$PROGRAM" "$1")"
	if [ "$2" != "$("$PROGRAM" "$1")" ]; then
		echo "$PROGRAM '$1'" 1>&2
		echo "expected: $2" 1>&2
		echo "got: $OUTPUT" 1>&2
		exit 1
	fi
}

assert_run "apple"   "appleay"
assert_run "ear"     "earay"
assert_run "igloo"   "iglooay"
assert_run "object"  "objectay"
assert_run "under"   "underay"
assert_run "equal"   "equalay"
assert_run "pig"     "igpay"
assert_run "koala"   "oalakay"
assert_run "yellow"  "ellowyay"
assert_run "xenon"   "enonxay"
assert_run "qat"     "atqay"
assert_run "chair"   "airchay"
assert_run "queen"   "eenquay"
assert_run "square"  "aresquay"
assert_run "therapy" "erapythay"
assert_run "thrush"  "ushthray"
assert_run "school"  "oolschay"
assert_run "yttria"  "yttriaay"
assert_run "xray"    "xrayay"

assert_run "quick fast run" "ickquay astfay unray"
