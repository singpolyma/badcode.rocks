Note: if you still want to submit for [the beer song challenge](<%= @items['/articles/2018305 Beer Song/index.*'].path %>), we're going to accept submissions there for awhile longer.

---

A robot factory's test facility needs a program to verify robot movements.

The robots have three possible movements:

* turn right
* turn left
* advance

Robots are placed on a hypothetical infinite grid, facing a particular direction (north, east, south, or west) at a set of `{x,y}` coordinates, e.g., `{3,8}`, with coordinates increasing to the north and east.

The robot then receives a number of instructions, at which point the testing facility verifies the robot's new position, and in which direction it is pointing.

The command string "RAALAL" means:

* Turn right
* Advance twice
* Turn left
* Advance once
* Turn left yet again

Say a robot starts at `{7,3}` facing north. Then running this stream of instructions should leave it at `{9,4}` facing west.

# Testing

To ensure the correctness of your implementation, see [test.sh](test.sh) with usage:

    sh test.sh /path/to/program

It is expected that your program takes four command line arguments: initial x position, initial y position, initial direction, and command string.

On STDOUT your program must print: final x position&lt;space&gt;final y position&lt;space&gt;final direction.

All positions are integers, and valid directions are: N, S, E, W.

# Submission

All submissions must contain a statement that the code is your own work (groups are ok!) and placing the code under either [CC0](https://creativecommons.org/publicdomain/zero/1.0/), [CC-BY](http://creativecommons.org/licenses/by/4.0/), or [CC-BY-SA](http://creativecommons.org/licenses/by-sa/4.0/).  Submissions are by email to <submissions@badcode.rocks>.  Attaching each source file is preferred, but tarballs or git URLs will also be accepted (especially when directory structure matters).  Submissions may be in any programming language that can be compiled or interpreted on a Debian Stable system.

If relevant, please make it clear what name, pseudonym, or group name you would like your submission attributed to.  This name (and the code content of your submission) will be made public.

Submissions are due by <time datetime="2018-12-31">2018-365 (December 31, 2018)</time> and the winning teardown post will be published the following month.

---

This excercise and its tests based on <https://github.com/exercism/rust/tree/master/exercises/robot-simulator>, original license:

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
