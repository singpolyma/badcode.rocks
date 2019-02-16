It's time to announce the winner for [January's challenge](<%= @items['/articles/2019001 Bowling/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [February's challenge](<%= @items['/articles/2019032 Circular Buffer/index.*'].path %>), so get on that quick!

# Winner, in Haskell, by Jonathan Lamothe

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2019-February/000027.html) so you can follow along.

<section markdown="1">
# Syntax that technically works

A lot of what makes this code bad is not being idiomatic for the language or problem, starting even with basic syntax choices.  The syntax for a Haskell conditional looks like:

	if condition then
		first expression
	else
		second expression

and a function application looks like:

	function arg1 arg2

The submission author choose to write:

	if (length (args) == 0)
		then
			first expression
		else
			second expression

The extra parentheses just add visual noise, and in this case it *feels* like they were added to make the syntax more resemble a "C family" if statement and procedure call.  This "can it look slightly more like C" continues with other functions:

	check_loop (1, length (args), args)

This code first constructs a tuple and then passes only one argument, consisting of that tuple, to the function.  There is no benefit (in this code) to constructing a data structure that is then immediately destructured again, and again this appears to be done in order to move the syntax in an unhelpful way towards a different family's syntax.  If enough of these changes were present (using braces instead of layout, using `check_loop(1, length(args), args)` instead of spaces everywhere, etc) one *might* argue that this could be useful if the target audience were C-family programmers.  But here it is just enough to make the Haskell harder for Haskellers to read, but no easier for a C-family programmer to read.
</section>

<section markdown="1">
# When all you have is a hammer...

Every single line of code in this program (except the import statements and top-level function names, I suppose) is inside a do notation block.  "Do notation" is a syntactic sugar that Haskell provides for building operations that rely heavily on data dependencies or evaluation order in a way that will feel more natural to those familiar with imperative code.  Due to another design flaw discussed below, every function in this submission also returns an `IO` action that can instruct the runtime to do some side-effecting actions, despite the only externally visible effects of the whole program being a single print statement (found in `main`) and the final exit code.

This extreme over-use of a particular syntactic mode leads to several strange patterns.  The most classic of this is the "single line do", like so:

	if (length (args) == 0)
		then do
			exitWith (ExitFailure 3)

This is exactly equivalent to:

	if (length (args) == 0)
		then
			exitWith (ExitFailure 3)

The submission also frequently introduces variables thus:

	next_i <- return (i + 1)

Which is equivalent to the more idiomatic:

	let next_i = i + 1

Combining this pattern of using do notation blindly with structuring the whole program using `if...then...else` results in this:

	check_loop (i, len, args) = do
		if (length (args) >= i)
			then do
				make_num (args !! (i - 1))
				next_i <- return (i + 1)
				check_loop (next_i, length (args), args)
			else do
				return ()

Which is equivalent to:

	check_loop (i, len, args) =
		when (length args >= i) $ do
			make_num (args !! (i - 1))
			check_loop (i + 1, length (args), args)
</section>

<section markdown="1">
# The pointless step

That `check_loop` function is short, but chock-full of bad code.  Code doesn't have to be plentiful to be terrible!  First of all, if you look at it you'll see that the `len` pseudo-argument is *never* used.  Instead, the function re-computes `length args` whenever it needs it, including for the recursive call to set `len` again!

This function is also trying *very* hard to have the semantics of a C-style for loop over an array.  However, `args` is *not* an array but a linked list, making the indexing operator (`!!`) quite inefficient and not recommended for common use.  Furthermore, the index operator will terminate the program with an error if the index is out-of-bounds.  The function checks for that, but a mistake in that check could result in a crashing program.

While it wants the semantics of a C-style for loop, this function also wants `i` to start at 1 instead of 0.  `!!` expects indexes to start at 0, so the function has to adjust for that reality -- a reality that would actually be *more expected* by most readers.

The main purpose of this pseudo-loop seems to be to call `make_num` on every element.  It does not use or return the values from `make_num` however, so what could be the purpose of calling it?

	make_num (string) = do
		case (string) of
			"0" -> return (0)
			"1" -> return (1)
			"2" -> return (2)
			"3" -> return (3)
			"4" -> return (4)
			"5" -> return (5)
			"6" -> return (6)
			"7" -> return (7)
			"8" -> return (8)
			"9" -> return (9)
			"10" -> return (10)
			_ -> exitWith (ExitFailure 1)

Since the return value is ignored, only the last line matters.  `check_loop`'s whole purpose is to exit the program with the "input tried to knock down too many pins" exit code if any argument is anything other than a number 0-10.  However, the rest of the program *also* uses `make_num` on arguments as it goes, so even that is not a useful result!  Removing `check_loop` from this program would not change the behaviour of the program at all, and might even make it slightly faster.  At very least it should have been:

	rolls <- mapM make_num args

With `rolls` used to prevent needing to call `make_num` again in the future.
</section>

<section markdown="1">
# When in doubt, exit

The problem of scoring bowling has many cases in which input is considered invalid for one reason or another, and Haskell has many useful tools for expressing this.  What tool does the author use?

			exitWith (ExitFailure 1)

The main reason this whole program produces `IO` actions is so that at any moment, failure can be represented by an immediate call to exit the process with the correct error code.  Even the codes themselves aren't DRY!  Magic numbers, hard-coded into a side-effecting statement among otherwise pure computation, are littered throughout this submission.  For example, the rewrite of `check_loop` done above can be re-done to move the possible side effect to `main` thus:

	case mapM readMaybe args of
		Just rolls | all (<= 10) rolls -> ...
		_ -> exitWith (ExitFailure 1)

This rewrite also allows us to re-use parts of the ecosystem and get rid of `make_num` entirely.
</section>

<section markdown="1">
# The terrible variable names

	x_string <- return (args !! (i - 1))
	x <- make_num (x_string)
	...
	y_string <- return (args !! (i - 2))
	y <- make_num (y_string)
	z <- return (x + y)

The main body of the problem solution is full of variables named `x`, `y`, and `z` -- sometimes name shadowing earlier variable with the same terrible name, and not always even using the same letter for the same purpose!

Haskellers sometimes get accused of this generally, but it usually comes from writing a function that is so generic that nothing useful is known about the contents of the variable, such as:

	mymap _ [] = []
	mymap f (x:xs) = f x : mymap xs

One could write:

	mymap _ [] = []
	mymap a_function (element_of_list : rest_of_list) = a_function element_of_list : mymap rest_of_list

But since nothing useful is known about the function, elements, or list, the longer names actually obscure the shape.

In the submission code, much is known about the contents of these values!  For example, the `x` above is the number of pins knocked down by this throw.  `pinsKnockedDown` is infinitely better than `x`!
</section>

<section markdown="1">
# The cascade

	if (i > length (args))
		then do
			exitWith (ExitFailure 3)
		else do
			if (x > 10)
				then do
					exitWith (ExitFailure 1)
				else do
					if (second_throw)
						then do
							if (z > 10)
								then do
									exitWith (ExitFailure 1)
								else do
									if (z == 10)
										then do
											if (length (args) < i + 1)
												then do
													exitWith (ExitFailure 3)

As our judge with the least Haskell experience said: "You don't have to know anything about Haskell to know this code is bad."

The most obvious way to avoid this mess is so obvious the author couldn't help but hint at it in the code itself:

	if second_throw
		...
	else -- 1st throw

	if (x == 10)
		...
	else -- not strike

One could keep the thoughtless spine of conditionals intact and improve readability *immensely* simply by breaking this up into multiple functions:

	if second_throw then the_second_throw else the_first_throw
	where
	the_first_throw = ... if (x == 10) then strike else ...
	the_second_throw = ... if (x == 10) then strike else ...
	strike = ...

Many of the conditions also simply check an edge case and exit.  While this is not a good way to model the problem, even leaving that alone it could be cleaner as:

	when (i > length args) $ exit (ExitFailure 3)
	...
	when (x > 10) $ exit (ExitFailure 1)

This function also has to duplicate many checks because it is written with many cases that look ahead.  Instead of evaluating the current throw or frame, and passing any context about bonus point or bonus throw conditions forward to the next recursive call, a frame with a bonus on the next throw will include the points from that throw right away.  This means the code could not easily be repurposed to score incomplete games, and also requires checking that some or all of the *next* frame is valid in order to score *this* one.  When recursing, of course, the next frame also validates itself, so the program validates many throws multiple times.
</section>

<section markdown="1">
# Conclusion

While the cascade is the most striking thing when first opening this code, it manages to pack examples of many other bad practises as well.  Think you can do worse?  Submissions for [February's challenge](<%= @items['/articles/2019032 Circular Buffer/index.*'].path %>) are still open, and a March challenge will be going up soon!
</section>
