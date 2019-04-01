To try and encourage more sales of different books from a popular 5 book
series, a bookshop has decided to offer discounts on multiple book purchases.

One copy of any of the five books costs $8.

If, however, you buy two different books, you get a 5%
discount on those two books.

If you buy 3 different books, you get a 10% discount.

If you buy 4 different books, you get a 20% discount.

If you buy all 5, you get a 25% discount.

Note: that if you buy four books, of which 3 are
different titles, you get a 10% discount on the 3 that
form part of a set, but the fourth book still costs $8.

Your mission is to write a piece of code to calculate the
price of any conceivable shopping basket (containing only
books of the same series), giving as big a discount as
possible.

For example, how much does this basket of books cost?

- 2 copies of the first book
- 2 copies of the second book
- 2 copies of the third book
- 1 copy of the fourth book
- 1 copy of the fifth book

One way of grouping these 8 books is:

- 1 group of 5 --> 25% discount (1st,2nd,3rd,4th,5th)
- +1 group of 3 --> 10% discount (1st,2nd,3rd)

This would give a total of:

- 5 books at a 25% discount
- +3 books at a 10% discount

Resulting in:

- 5 x (8 - 2.00) == 5 x 6.00 == $30.00
- +3 x (8 - 0.80) == 3 x 7.20 == $21.60

For a total of $51.60

However, a different way to group these 8 books is:

- 1 group of 4 books --> 20% discount  (1st,2nd,3rd,4th)
- +1 group of 4 books --> 20% discount  (1st,2nd,3rd,5th)

This would give a total of:

- 4 books at a 20% discount
- +4 books at a 20% discount

Resulting in:

- 4 x (8 - 1.60) == 4 x 6.40 == $25.60
- +4 x (8 - 1.60) == 4 x 6.40 == $25.60

For a total of $51.20

And $51.20 is the price with the biggest discount.

# Testing

To ensure the correctness of your implementation, see [test.sh](test.sh) with usage:

    sh test.sh /path/to/program

It is expected that your program takes as arguments the items in the cart, prints the total cost in cents to STDOUT, and exits successfully.

# Submission

All submissions must contain a statement that the code is your own work (groups are ok!) and placing the code under either [CC0](https://creativecommons.org/publicdomain/zero/1.0/), [CC-BY](http://creativecommons.org/licenses/by/4.0/), or [CC-BY-SA](http://creativecommons.org/licenses/by-sa/4.0/).  Submissions are by email to <submissions@badcode.rocks>.  Attaching each source file is preferred, but tarballs or git URLs will also be accepted (especially when directory structure matters).  Submissions may be in any programming language that can be compiled or interpreted on a Debian Stable system.

If relevant, please make it clear what name, pseudonym, or group name you would like your submission attributed to.  This name (and the code content of your submission) will be made public.

Submissions are due by <time datetime="2019-04-30">2019-120 (April 30, 2019)</time> and the winning teardown post will be published the following month.

---

This exercise and its tests based on <https://github.com/exercism/rust/tree/master/exercises/book-store>, original license:

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
