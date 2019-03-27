It's time to announce the winner for [February's challenge](<%= @items['/articles/2019032 Circular Buffer/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [March's challenge](<%= @items['/articles/2019060 Diamond/index.*'].path %>), so get on that quick!

# Winner, in Tcl and Bash, by 1EC7

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2019-March/000028.html) so you can follow along.

<section markdown="1">
# magic 8-wrap to pass the tests

That comment is the first thing you'll encounter in this submission's code, with a Bash script named 8wrap.sh that acts as the entry point for the rest of the code.  Here's what that comment describes:

	eval tclsh b*l $(echo $@ | sed s\\A\\8\\g) | sed 's 8 A g'
	exit ${PIPESTATUS[0]} 1>&2

wat

There is a lot that is bad here, but the main code smell is that this code exists at all.  It transforms all A's in the input into 8's and then reverses that transformation in the output.  A quick glance at the automated tests shows that the only non-digit the tests ever push into the circular buffer is the letter "A", so is this a submission that is coded to the tests and not the spec?

Yes and no.  The rest of the submission correctly implements a working circular buffer interface, it just fails on non-number inputs due to bugs.  This wrapper hides the bugs from the tests.  This kind of thinking, that if the code works and the tests don't pass the problem is obviously with the tests, is an unfortunately common anti-pattern.

So, why does the rest of this submission fail on non-numbers?  Are they using an array of integers?  No, much dumber than that:

	[ $2 -gt 0 ] && echo $2 > $(name $1) # if arg is ok write it

The "$2" here is an item to be pushed into the circular buffer.  This code only writes it if the item is "greater than 0".  Is A greater than 0?

	$ [ A -gt 0 ]
	bash: [: A: integer expression expected
	$ echo $?
	2

So, no.  This rather unfortunate way of checking that an item is "valid" is the entire source of the bug which requires the 8wrap script, but why is there any checking at all?  The spec does not say that any items are invalid.  The amazing answer is this line in `read.sh`:

	. write.sh # load lib

This submission has a "library" of bash functions in `lib.sh`, but instead of finding out where that was and sourcing it properly, the authors have chosen to simply source any other script they know happens to contain the functions they want.  However, doing so without a check would cause `read.sh` to also write garbage, so `write.sh` must be *aware that it is being abused in this way* and perform some sort of check.
</section>

<section markdown="1">
# How does this language work, again?

Aside from the above magic, all of the Bash (all but one script contain Bashisms) code exists simply to create a directory and then read or write the specified file in that directory.  Does Tcl support reading and writing files?  <a href="https://www.tcl.tk/man/tcl8.5/tutorial/Tcl24.html">Of course</a>.  How about creating a directory?  <a href="https://www.tcl.tk/man/tcl8.4/TclCmd/file.htm#M22">Still yes</a>.  The Bash code doesn't even abstract over the operation in any meaningful way (other than to know the name of the directory) and serves only to show that the authors already knew how to shell out, and did not want to search "how to read file Tcl".

Similarly, the boolean flags in the Tcl are set like so:

	set first yes
	set OW no

Are "yes" and "no" the preferred Tcl boolean values?  Not really, but they *are* supported by the language.  The authors must have found this style of boolean somewhere and picked it up.  Fine.  Except that we then see:

	if {$first == no} {
	...
	if {$OW == "no"} {

Two *different* ways of checking the flags, *neither* of which use the fact that this is actually a supported style.  Which leaves one wondering if the authors actually knew this was a supported style at all.  To be clear, the above could be written as:

	if {$first} {
	...
	if {$OW} {

with no other changes to the code.
</section>

<section markdown="1">
# All the globbing

One cannot read this code without head-scratching over strange choices:

	eval tclsh b*l
	...
	switch -glob $arg RE?D {
	...
	} CL**R {

This abuse of globbing to match what the author should know will always be an exact string is borderline obfuscation, and did not contribute to the submission winning.  It sure does make it harder to understand at first reading what the inputs of the code (or even the purpose of 8wrap.sh) are.
</section>

<section markdown="1">
# Or else what?

The Tcl code contains some hilarious patterns:

	exit 1
	break
	...
	exit 2
	break

... in case the exit failed to happen?

	foreach arg $argv {
		if {$first == no} {
			...
		}
		set first no
		continue
	}

... in case the loop forgets to keep going?

These can obscure one of the most egregious parts of this codebase:

	if {$rindx < $windx} {
		puts [exec ./read.sh $rindx]
		incr rindx
		continue
	}
	else {
		exit 1
		break
	}

That `continue` seems, on reading the whole loop, like just another no-op `continue`, until coming across this in `utils.tcl`:

	# stuff to make coding eaiser for new people on project
	...
	proc else {body} {uplevel $body}

Uhm.

So head to your tclsh terminal and type:

	if {1} {
		puts "hai"
	}

As soon as you put in the newline after that `}` it will execute.  `else` in Tcl *must* go on the same line as the brace or it does not work.  So this formatting error:

	}
	else {

Is more than just dumb looking.  It renders that `else` *non-functional*.  It is now a call to a function named `else`, not the else-clause of this if-statement.

Instead of realizing this and fixing it, the author said "no problem" and **wrote a function named `else`**.  Does this function interact with the `if` in some way to at least provide the same functionality?  No.  It just executes the code passed in the argument unconditionally.  So how does this work at all?

	if {$rindx < $windx} {
		...
		continue
	}

Because that "useless" `continue` is actually implementing the control flow.  The `else` is just confusing line noise.
</section>

<section markdown="1">
# No one said to delete anything

	variable size [lget $argv 0]
	variable rindx 0
	variable windx 0
	...
	incr rindx
	...
	incr rindx [expr $windx-$rindx]
	...
	if {$windx-$rindx-$size>=0} {
	...
	incr windx

Wait, what was that?

	if {$windx-$rindx-$size>=0} {

What is this doing?  Well, of course it's just a way of writing:

	if {$windx-$rindx < $size} {

in a way that makes it look like there's an important `0` when there isn't.  But why compare to size at all?  And is it safe to subtract like that?  What if $rindex is bigger?  Well, it won't be.  If you look at the snippets that started this section, that is all of the operations on these variables.  The numbers only ever go up.

Only up.

You can get a sense for what is happening if you read the implementation of overwriting an element in the buffer:

	if {$OW == "no"} {
		exit 2
		break
	}
	incr rindex

When overwriting... increment the read index.  Don't check if it needs to wrap around.  Don't touch the write index.  Just increment the read index and move on.  Remember earlier when we discovered that the Bash scripts only existed to read and write files?

There is no script to delete a file.

This "circular" buffer has the *interface* of a circular buffer, and thus all its limitations, but is implemented as an ordered data set that grows when you add an element, and **leaks** when you read or overwrite an element.  Because our elements are small and especially because the storage is on disk you may not notice... for a long time, anyway.
</section>

<section markdown="1">
# Conclusion

There are a few other gems in the full source, but that's the highlights.  This group has won before, and they managed to impress us by being bad in several different ways with this submission.  Think you can do worse?  Submissions for [March's challenge](<%= @items['/articles/2019060 Diamond/index.*'].path %>) are still open, and an April challenge will be going up soon!
</section>
