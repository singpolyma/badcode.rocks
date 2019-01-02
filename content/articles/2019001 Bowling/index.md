Score a bowling game.

Bowling is a game where players roll a heavy ball to knock down pins
arranged in a triangle. Write code to keep track of the score
of a game of bowling.

## Scoring Bowling

The game consists of 10 frames. A frame is composed of one or two ball
throws with 10 pins standing at frame initialization. There are three
cases for the tabulation of a frame.

* An open frame is where a score of less than 10 is recorded for the
  frame. In this case the score for the frame is the number of pins
  knocked down.

* A spare is where all ten pins are knocked down by the second
  throw. The total value of a spare is 10 plus the number of pins
  knocked down in their next throw.

* A strike is where all ten pins are knocked down by the first
  throw. The total value of a strike is 10 plus the number of pins
  knocked down in the next two throws. If a strike is immediately
  followed by a second strike, then the value of the first strike
  cannot be determined until the ball is thrown one more time.

Here is a three frame example:

| Frame 1         | Frame 2       | Frame 3                |
| --------------- | ------------- | ---------------------- |
| X (strike)      | 5/ (spare)    | 9 0 (open frame)       |

Frame 1 is (10 + 5 + 5) = 20

Frame 2 is (5 + 5 + 9) = 19

Frame 3 is (9 + 0) = 9

This means the current running total is 48.

The tenth frame in the game is a special case. If someone throws a
strike or a spare then they get a fill ball. Fill balls exist to
calculate the total of the 10th frame. Scoring a strike or spare on
the fill ball does not give the player more fill balls. The total
value of the 10th frame is the total number of pins knocked down.

For a tenth frame of X1/ (strike and a spare), the total value is 20.

For a tenth frame of XXX (three strikes), the total value is 30.

# Testing

To ensure the correctness of your implementation, see [test.sh](test.sh) with usage:

    sh test.sh /path/to/program

It is expected that your program takes the number of pins knocked down per roll as command-line arguments.

Your program must either exit success and print the final score on STDOUT, or else exit with one of the following codes:

* `1`: One roll knocked down more pins than were standing
* `2`: More rolls were provided than would be present in a complete game
* `3`: Fewer rolls were provided tahn would be present in a complete game

# Submission

All submissions must contain a statement that the code is your own work (groups are ok!) and placing the code under either [CC0](https://creativecommons.org/publicdomain/zero/1.0/), [CC-BY](http://creativecommons.org/licenses/by/4.0/), or [CC-BY-SA](http://creativecommons.org/licenses/by-sa/4.0/).  Submissions are by email to <submissions@badcode.rocks>.  Attaching each source file is preferred, but tarballs or git URLs will also be accepted (especially when directory structure matters).  Submissions may be in any programming language that can be compiled or interpreted on a Debian Stable system.

If relevant, please make it clear what name, pseudonym, or group name you would like your submission attributed to.  This name (and the code content of your submission) will be made public.

Submissions are due by <time datetime="2019-01-31">2019-031 (January 31, 2019)</time> and the winning teardown post will be published the following month.

---

This excercise and its tests based on <https://github.com/exercism/rust/tree/master/exercises/bowling>, original license:

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
