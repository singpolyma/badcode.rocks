It's time to announce the winner for [April's challenge](<%= @items['/articles/2019091 Book Store/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [May's challenge](<%= @items['/articles/2019121 Pascal\'s Triangle/index.*'].path %>), so get on that quick!

# Winner, in Fortran 77, by CYRILLE LAVIGNE

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2019-April/000035.html) so you can follow along.

<section markdown="1">
# Makefile

The included Makefile is much too verbose.  Besides using unneeded GNU Make extensions, it also defines several things which are already built-in to even POSIX Make and can be more simply written this way:

    FFLAGS = -ffixed-form -fmax-identifier-length=7 -std=legacy -DMXSTCK=200000000 -DMXGRPS=200 -DICST=800

    LIBR: LIBR.F

    .PHONY: clean

    clean:
       $(RM) LIBR

This is because Make has, for example, a default variable `RM` containing a local `rm -f` equivalent, and the original `clean` rule was written to possibly delete all sorts of files the Makefile cannot generate.  Make also has a default rule for compiling any `*.F` file using the default system Fortran compiler, which matches exactly the command that was previously included.
</section>

<section markdown="1">
# Variable Names

Fortran 77 has fairly short length requirements on identifiers, but even so, many of the chosen identifiers are not great:

    DIMENSION IBSKT(5),
    +     ISTCK(MXSTCK),
    +     IDSCNT(5),
    +     IGRPS(5*MXGRPS)
    CHARACTER OUTP*20
    NGRPS  =  0
    IP1  =  1

Within the 7-character limit these can be named more helpfully:

    DIMENSION BASKET(5),
    +     STACK(MXSTCK),
    +     DISCNTS(5),
    +     GROUPS(5*MXGRPS)
    CHARACTER OUTPUT*20
    NGROUPS =  0
    SP      =  1

The `I` prefix that was on many of these is not only traditional, but also meaningful in Fortran 77 to indicate that the type should be inferred to be `INTEGER` if not specified otherwise.  However, explicitly declaring the variables is not only possible, but preferred, and neither tradition nor laziness is a great excuse for sticking to this bad kind of naming.  *Especially* when identifier length is at a premium one cannot be wasting an entire character.
</section>

<section markdown="1">
# Subroutines

From reading this code, you would be forgiven for thinking that Fortran 77 lacked any kind of named procedures.  However, despite everything in this program being done using a GOTO or repetitive inlined code, even Fortran 66 had both `SUBROUTINE` and `FUNCTION` facilities.  Using this for even something as simple as the inline stack manipulation can make it much clearer what is going on:

    - STACK(IP1:IP1+4) = (/1, I, J, NGROUPS, IP2 /)
    - IP2 = IP1
    - IP1 = IP1 + 5
    + CALL PUSH(1)
    + CALL PUSH(I)
    + CALL PUSH(J)
    + CALL PUSH(NGROUPS)
    ...
    - IF (IP2<0) THEN
    + IF (SP<5) THEN
        GOTO 50
      ELSE
    - ICMFRM  = STACK(IP2)
    - I       = STACK(IP2+1)
    - J       = STACK(IP2+2)
    - NGROUPS = STACK(IP2+3)
    - IP2     = STACK(IP2+4)
    + NGROUPS = POP()
    + J       = POP()
    + I       = POP()
    + ICMFRM  = POP()

In fact, once this refactor is fully complete it becomes clear, as you can see even with the snippet above, that the entire `IP2` variable in the original is unneeded.
</section>

<section markdown="1">
# Bogus GOTOs

There are also complete abuses of `GOTO` to implement other kinds of control flow that Fortran 77 is perfectly capable of.  The most egregious is:

         DO WHILE (.TRUE.)
    C      ...
           IF (I>5) THEN
             GOTO 40
           END IF
         END DO
     40 CONTINUE

This `GOTO 40` can very cleanly be replaced by `EXIT` to stop the loop.  There is also this incredibly confusing snippet:

    DO II=1,5
      IF (IBSKT(II) > 0) THEN
        GOTO 11
      END IF
    END DO

The code labelled `11` then jumps back to this code, but full analysis of the algorithm reveals that this can be replaced by something more like:

         JJ = 0
         DO II=1,5
           JJ = JJ + BASKET(II)
         END DO

         IF (JJ == 0) THEN
    C      Code to run when BASKET is empty, no longer needs to GOTO 40
         ELSE
    C      Code previously labelled 11, no longer needs a label
         END IF
</section>

<section markdown="1">
# GOTO Recursion: Affordances

Possibly one of the most surprising features of this submission, is that there is a `GOTO` which jumps to two different places *inside* of a loop.  If you read this code as you might be used to reading other languages, it will take some time to unravel what this could even mean to be doing.  However, the author has left a helpful clue in the form of pushes onto a stack data structure just before the point that is jumped to, and pops from that same data structure before the `GOTO` happens.  If you've done much assembly programming (well, except for some microcontrollers) you are likely to recognize this pattern as a call stack for procedure (or similar) calls: push, goto, pop, go back.

So this code is just simulating a subroutine with `GOTO`, we've already established this as a bad pattern in the program.  However, there is actually a reason this code cannot be trivially rewritten to use Fortran 77's built-in subroutines: the code is implementing a recursive call.  Fortran 77 does not allow functions or subroutines to call themselves, even indirectly, which means that for this algorithm to work the way it does some form of trickery is *going* to be needed.  Sure, it could be cleaned up to use a stack+trampoline sort of construct outside properly isolated subroutines, but the machinery would remain, and would affect where in the program the subroutines could be cut out, instead of allowing them to be cut however makes the most logical sense for readability.

At first, this seems like a harsh reality: Fortran 77 does not support the needed language feature, and so the code is necessarily more complex as a result.  We cannot judge code as bad unless it could have been written better.

However, this could *absolutely* could have been written better.  There is nothing inherently recursive about the given problem, in fact no other submission used recursion to solve it!  Even if the problem was naturally best solved using a recursive way of thinking, there are ways to implement a recursive *algorithm* without dropping down to simulate recursive *procedure calls*.  For example, depth-first search is a recursive algorithm which is frequently implemented using a loop and a stack in many programming languages.

The author has here fell into the classic anti-pattern of ignoring the affordances of their language.  A programming language is a language, after all, and different ones lend themselves to expressing solutions in different ways.  Rather than asking themselves "what is the way Fortran 77 *wants* to express this" the author has brought in baggage from another environment and failed to imagine an alternate implementation.  This lack of imagination has led them to implement (poorly, especially given the massive fixed-size preallocated stack) a language feature they miss simply so the problem can be expressed in a mechanically similar way to what they imagine they might otherwise have written.  While the result is very similar to the CPU, it is *very* different to a human reader.
</section>

<section markdown="1">
# Conclusion

Think you can do worse?  Submissions for [May's challenge](<%= @items['/articles/2019121 Pascal\'s Triangle/index.*'].path %>) are still open, and a June challenge will be going up soon!
</section>
