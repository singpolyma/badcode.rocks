It's time to announce the winner for [March's challenge](<%= @items['/articles/2019060 Diamond/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [April's challenge](<%= @items['/articles/2019091 Book Store/index.*'].path %>), so get on that quick!

# Honourable Mentions

We're only picking one winner for this teardown, but that doesn't mean there weren't several wonderfully bad submissions to choose from.  Our favourite runner up:

* [Pascal: The Discombobulator](https://snark.badcode.rocks/archives/2019-March/000030.html) — bugs papered over with extra conditional checks, a search function that is not as it seems, confusingly written bounds checks, and other gems.

# Winner, in Python, by Anand Sundaram

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2019-March/000029.html) so you can follow along.

<section markdown="1">
# Shell wrapper

    #!/bin/bash

    letter=$1
    python3 ./diamond.py "$letter"

The judges are honestly unsure why this was included.  We could make fun of the `#!/bin/bash` shebang line, or the unquoted variable assignment, but perhaps it suffices to clarify that not *every* submission needs a useless shell script in it.
</section>

<section markdown="1">
# Commented out syntax

Half-way down the script you'll see this:

    # from __future__ import braces

This import is an easter-egg in the Python interpreter.  It does not enable braces-based syntax, but instead insults you for wanting that.  The code after this line is all written like this:

    def __str__(self): #{
        return '\n'.join((str(row) for row in self.rows))
    #}

There are two different possible anti-patterns here.  One is the persistent habit of some developers to over-comment trivialities, such as in:

    if(cond) {
        // ...
    } // endif

However, this particular example fails to even convey such trivial extra information.  At most it allows the eye to find the end of a block.  Instead this seems more like another issue.  The author wrote `from __future__ import braces` believing (or hoping) that this would enable a brace-based syntax for Python, and proceeded to write the rest of the file as though that would work.  When it turned out *not* to work, the author simply commented-out the braces to get rid of the error *and then never removed the comments*.  The import itself must also be commented out, but lives on in the final source code as a monument to not knowing editors have a "delete" function.

To insult the reader further, this whole disaster is only applied to half of the file.  The author learned not to add these braces and so did not for further added code, leaving an inconsistent mess.
</section>

<section markdown="1">
# What language is this?

    def main():
        diamond = DiamondSquare(sys.argv[1])
        print(str(diamond))
    # ...
    if (__name__ == '__main__'): #{
        main()
    #}

This short segment contains such an amazingly cargo-culted lack of critical thinking it had to be called out.  The author defines a procedure named `main`, presumable having experience with a language where that is how entry points are defined.  Upon discovering that this is not how Python works, the author does not remove the procedure but simply calls it from the true entry point.

The true entry point is wrapped in an if statement.  This if is a pattern sometimes found in Python code that needs to both be importable as a library, and also executed as a script.  This script is only ever executed, so the if adds nothing and was presumably copied as a pattern from somewhere.  However, it was not blindly copied!  Besides the already-mentioned braces, this if also parenthesizes the condition, which is not common Python syntax at all, and is not done anywhere else in this same script.
</section>

<section markdown="1">
# The worst way to exit a program

    for x in range(A,ord(letter) +1):
        letters.append(x)
        # if not A<=chr(x) <= 'z':
        if not 65 <= x<=122:
            break # Forces crash and exits program with helpful error at this line
    else:
        self.letters = letters

    self.letters.extend(...)

Forces crash with "helpful error".  And here is that helpful error:

    Traceback (most recent call last):
      File "diamond.py", line 75, in <module>
        main()
      File "diamond.py", line 35, in main
        diamond = DiamondSquare(sys.argv[1])
      File "diamond.py", line 55, in __init__
        self.letters.extend(letters[:-1][::-1])
    AttributeError: DiamondSquare instance has no attribute 'letters'

... very helpful.  So what is happening here?

    A = 65 # Explicit is better than impl
    # ...
    for x in range(A,ord(letter) +1):
        # ...
    else:
        self.letters = letters

Sets up a loop from 65 to the ASCII code of the letter argument.  When the loop terminates normally, the `self.letters` attribute is assigned.  When the `break` is issued, the attribute never gets assigned, but further code assumes it has been.  So the program crashes with the "helpful error".

There is also a bug here: the code is obviously meant to crash for letter input outside of the alpha range, but for ASCII codes below `'A'` the range will be empty and the loop will terminate normally without ever evaluating the condition.  Additionally, the non-alpha codes between `'Z'` and `'a'` are accidentally considered valid letters, and also the whole rest of the program is not actually able to handle lower-case input anyway.  This is not a violation of the challenge spec, but in practise almost none of the cases this condition hopes to "force crash" on will not be caught by the code as written.
</section>

<section markdown="1">
# Memoize for the sick speedups

The meat of this program is a supposedly "memoized" implementation of the diamond solution.  Not only is the code bad, but it fails to accomplish the one thing it sets out to do: this implementation *never* serves a result from the cache, and only wastes memory keeping one around.  The main source of this problem comes about here:

    letters = []
    # ...
    self.letters = letters
    self.letters.extend(letters[:-1][::-1])
    self.num_rows = len(letters)

`self.letters.extend` mutates the list pointed to by `self.letters`.  In this case adding a reversed (... because `list[::-1]` reverses the list) copy of the letters minus the last one to the list.  This seems sensible, but crucially `self.letters` and `letters` point to the *same* list.  So `self.num_rows` will be assigned the length of the extended list.

This may not seem like a bug, just a confusingly-written chunk of code.  After all, isn't the length of the extended list equal to the number of rows in the diamond?  Yes, but the code continues:

    self.rows = ( self.get_row(row, letter= l) for (row, l) in enumerate(self.letters ))
    # ...
    @with_lookup
    def get_row(self, row, **vals): #{
        letter = vals['letter']
        if row not in range(self.num_rows):
            return
        else:
            row = Diamond_Square_Row(letter, row, len(self.letters))
            charToRow[letter] = row

When is `row not in range(self.num_rows)` ever going to be true?  Never.  It will never be true.  If the author believes that `self.num_rows` contains the length of the non-extended list, the code makes sense and the condition will be true for the second half of the diamond.  As written, however, this condition never passes and the return never happens.  To even understand what this code does, one must also read the decorator:

    def with_lookup(op):
        def lookUp(*vals, **key_Vals):
            op(    *vals, **key_Vals)
            letter = key_Vals['letter']
            return charToRow.get(letter, chr(letter))
        return lookUp

Normally a decorator should compose nicely with the method it decorates, and knowledge of the internals should not be needed to understand the method alone.  Here, however, the decorator and the method both depend on the internals of the other, and on the same global variable `charToRow`.  So what this does is call the method implementation which *always* falls to the else, get a `Diamond_Square_Row` instance for the requested row, add this instance to a global cache for the letter, then immediately look up in the global cache to get the instance again and finally return it from the decorator.

The implementation of `Diamond_Square_Row` yields one more tidbit in this calamity:

    def __str__(self):
        s = ''.join([str(cell) for cell in self.columns])
        self.__init__(self.letter, self.row + self.num_rows, self.num_rows)
        return s

What does that call to `__init__` do?  As it turns out, what it does is waste cycles.  Besides a call to `__init__` being a non-idiomatic choice, and besides mutating `self` from inside `__str__` being incredibly ill-advised, what this code *wants* to do is set up this object in the cache to render a later row next time it is called upon.  But it will never be called again, since a new instance in generated for every row and the cache is never used.  Additionally, this `__init__` call passes the wrong argument for row number, since adding the total number of rows to the current row certainly does not produce the index of the second-half row... it would, if this `num_rows` were only a count of half the rows *but* even without the extended-list confusion that is not what this number is because it is separately computed from the extended list explicitly.  This wrong row number doesn't matter in the end, not only because this instance is never used again, but also because nothing in the object ever uses the row number at all.
</section>

<section markdown="1">
# Conclusion

There are a few other gems in the full source, but that's the highlights.  Think you can do worse?  Submissions for [April's challenge](<%= @items['/articles/2019091 Book Store/index.*'].path %>) are still open, and a May challenge will be going up soon!
</section>
