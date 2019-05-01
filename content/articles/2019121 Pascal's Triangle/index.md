Compute [Pascal's triangle](https://en.wikipedia.org/wiki/Pascal%27s_triangle) up to a given number of rows.

In Pascal's Triangle each number is computed by adding the numbers to the right and left of the current position in the previous row.

<pre>
 &nbsp; &nbsp;1
 &nbsp; 1 1
 &nbsp;1 2 1
 1 3 3 1
1 4 6 4 1
# ... etc
</pre>

# Testing

To ensure the correctness of your implementation, see [test.sh](test.sh) with usage:

    sh test.sh /path/to/program

It is expected that your program takes as its only argument the number of rows, prints a correct triangle of that many rows to STDOUT, and exits successfully.

# Submission

All submissions must contain a statement that the code is your own work (groups are ok!) and placing the code under either [CC0](https://creativecommons.org/publicdomain/zero/1.0/), [CC-BY](http://creativecommons.org/licenses/by/4.0/), or [CC-BY-SA](http://creativecommons.org/licenses/by-sa/4.0/).  Submissions are by email to <submissions@badcode.rocks>.  Attaching each source file is preferred, but tarballs or git URLs will also be accepted (especially when directory structure matters).  Submissions may be in any programming language that can be compiled or interpreted on a Debian Stable system.

If relevant, please make it clear what name, pseudonym, or group name you would like your submission attributed to.  This name (and the code content of your submission) will be made public.

Submissions are due by <time datetime="2019-05-31">2019-151 (May 31, 2019)</time> and the winning teardown post will be published the following month.

---

This exercise and its tests based on <https://github.com/exercism/rust/tree/master/exercises/pascals-triangle>, original license:

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
