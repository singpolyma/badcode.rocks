A circular buffer, cyclic buffer or ring buffer is a data structure that
uses a single, fixed-size buffer as if it were connected end-to-end.

A circular buffer first starts empty and of some predefined length. For
example, this is a 7-element buffer:

    [ ][ ][ ][ ][ ][ ][ ]

Assume that a 1 is written into the middle of the buffer (exact starting
location does not matter in a circular buffer):

    [ ][ ][ ][1][ ][ ][ ]

Then assume that two more elements are added — 2 & 3 — which get
appended after the 1:

    [ ][ ][ ][1][2][3][ ]

If two elements are then removed from the buffer, the oldest values
inside the buffer are removed. The two elements removed, in this case,
are 1 & 2, leaving the buffer with just a 3:

    [ ][ ][ ][ ][ ][3][ ]

If the buffer has 7 elements then it is completely full:

    [6][7][8][9][3][4][5]

When the buffer is full an error will be raised, alerting the client
that further writes are blocked until a slot becomes free.

When the buffer is full, the client can opt to overwrite the oldest
data with a forced write. In this case, two more elements — A & B —
are added and they overwrite the 3 & 4:

    [6][7][8][9][A][B][5]

3 & 4 have been replaced by A & B making 5 now the oldest data in the
buffer. Finally, if two elements are removed then what would be
returned is 5 & 6 yielding the buffer:

    [ ][7][8][9][A][B][ ]

Because there is space available, if the client again uses overwrite
to store C & D then the space where 5 & 6 were stored previously will
be used not the location of 7 & 8. 7 is still the oldest element and
the buffer is once again full.

    [D][7][8][9][A][B][C]

# Testing

To ensure the correctness of your implementation, see [test.sh](test.sh) with usage:

    sh test.sh /path/to/program

It is expected that your program takes as its first argument the size of the buffer, followed by arguments to be written into the buffer in order.  Certain arguments are special and should not be written to the buffer but interpreted as commands instead:

* `READ`: Read the next item from the buffer and print to a line on STDOUT
* `CLEAR`: Make the buffer empty
* `OVERWRITE`: The next write should overwrite the first element if the buffer is full, instead of erroring as below

Your program must either print all requested items to STDOUT. It must then exit success, or else exit with one of the following codes:

* `1`: Tried to read an empty buffer
* `2`: Tried to write to full buffer

# Submission

All submissions must contain a statement that the code is your own work (groups are ok!) and placing the code under either [CC0](https://creativecommons.org/publicdomain/zero/1.0/), [CC-BY](http://creativecommons.org/licenses/by/4.0/), or [CC-BY-SA](http://creativecommons.org/licenses/by-sa/4.0/).  Submissions are by email to <submissions@badcode.rocks>.  Attaching each source file is preferred, but tarballs or git URLs will also be accepted (especially when directory structure matters).  Submissions may be in any programming language that can be compiled or interpreted on a Debian Stable system.

If relevant, please make it clear what name, pseudonym, or group name you would like your submission attributed to.  This name (and the code content of your submission) will be made public.

Submissions are due by <time datetime="2019-02-28">2019-059 (February 28, 2019)</time> and the winning teardown post will be published the following month.

---

This excercise and its tests based on <https://github.com/exercism/rust/tree/master/exercises/circular-buffer>, original license:

Copyright (c) 2017 Exercism, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
