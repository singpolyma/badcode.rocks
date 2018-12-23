It's time to announce the winner for [November's challenge](<%= @items['/articles/2018305 Beer Song/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [December's challenge](<%= @items['/articles/2018337 Robot Simulator/index.*'].path %>), so get on that quick!

# Honourable Mentions

We're only picking one winner for this teardown, but that doesn't mean there weren't any other wonderfully bad submissions to choose from. One of our favourites that didn't quite win:

* [C: Jeff Walter](https://snark.badcode.rocks/archives/2018-November/000008.html) — bad constants, incredibly un-idiomatic loops, and strings that should have been numbers, with two memory leaks for good measure.

# Winner, in CPP: sac_boy

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2018-December/000024.html) so you can follow along.

<section markdown="1">
# More power than required

> It didn't have to be C++ of course as there are no C++ specifics in there bar the use of the standard library for output.

This submission is primarily written in the C Preprocessor, but ultimately generates a C++ program.  Why include all the extra complexity of C++?  As is often the case, for no reason.  While language and tool selection generally can be more faith that science in many communities, it is useful to think about what one is getting for the extra power, and if it might confuse a future reader.

	#define HIGHEST_BEER_FUNC() CBRMFP(beer, BEER_MAX)
	...
	HIGHEST_BEER_FUNC()();
	...
	#define FUNCNAME() CBRMFP(beer, __INCLUDE_LEVEL__)
	...
	void FUNCNAME()() {

These are defined as function-like macros taking an empty list of arguments, instead of as simple macros.  Again, this implies the use of something more powerful than is required for the intent of the code, and additionally leads to the delightfully confusing `FUNCNAME()()` syntax.  Consider that this works the same for the case in question:

	#define HIGHEST_BEER_FUNC CBRMFP(beer, BEER_MAX)
	HIGHEST_BEER_FUNC();
</section>

<section markdown="1">
# Obscure name for common operation

	#ifndef CONCAT
	  // Concatenate two tokens.
	  #define CONCAT(x, y) x ## y
	  // Concatenate two tokens, but resolve macro params first.
	  // Stands for Concat, But Resolve Macros First Please
	  #define CBRMFP(x, y) CONCAT(x, y)
	#endif

Using a made-up-on-the-spot initialism is usually a bad naming practise, but in this case it is especially egregious.  `CONCAT` is *only ever used* in the definition of `CBRMFP` and nowhere else.  This means the common-looking name has been reserved for what is effectively a private operation, and the initialism has been given to an operation that is used throughout the following code.
</section>

<section markdown="1">
# Making assumtions about the environment

	#define FUNCNAME() CBRMFP(beer, __INCLUDE_LEVEL__)
	...
	#if __INCLUDE_LEVEL__ == 1
	...
	#define BEER_REMAINING __INCLUDE_LEVEL__ - 1
	...
	std::cout << __INCLUDE_LEVEL__
	...
	#if __INCLUDE_LEVEL__ != BEER_MAX

`__INCLUDE_LEVEL__` is not a standard part of the CPP language, but rather a language extension.  It will exist under many preprocessors, but not all.  When defined, it is a magic macro C Preprocessor exposes to indicate how many `#include` directives the preprocessor is in the midst of processing to get to this point.  So if file A includes file B includes file C, then in A the macro expands to `0`, in B to `1`, and in C to `2`.

This code assumes throughout that `__INCLUDE_LEVEL__` will be `1` when the file is first included.  While this is true in the context of the given program, it means that if the file were ever to be included from another context, it would simply not produce the expected code.  This usage also requires the reader to *know* that `__INCLUDE_LEVEL__` is being used as the verse number counter, instead of providing a nice alias at no cost:

	#define BEER_VERSE __INCLUDE_LEVEL__

The program make another assumption about the environment so egregious that the author felt compelled to comment about it:

	// We also want to know the 'next' function to call, which is
	// __INCLUDE_LEVEL__ - 1...so use __COUNTER__ instead.
	// Let's hope nobody else uses __COUNTER__! 
	#undef NEXTFUNCNAME
	#define NEXTFUNCNAME CBRMFP(beer, __COUNTER__)

Always a good sign when you have code comments that say "Let's hope".  `__COUNTER__` here is assumed to always expand to a value one lower than `__INCLUDE_LEVEL__` which is *only* true if this is the *only* line in the whole of the source that uses it.  And, of course, `__COUNTER__` is also not a standard part of CPP, but yet another language extension.
</section>

<section markdown="1">
# DRY as a desert

	// We reuse these patterns quite a lot so let's DRY them up
	#define STRINGIFY(x...) #x
	#define SLASHN std::endl
	#define SPACE ' '
	#define PERIOD STRINGIFY(.)
	#define BOB STRINGIFY(bottles of beer)
	#define SPACE_BOB SPACE << BOB
	#define SPACE_BOB_SPACE SPACE_BOB << SPACE
	#define SPACE_BOB_PERIOD SPACE_BOB << PERIOD
	#define OTW STRINGIFY(on the wall)
	#define OTW_COMMA_SPACE OTW << STRINGIFY(,) << SPACE
	#define OTW_PERIOD OTW << PERIOD
	#define O_MORE STRINGIFY(o more)

	void beer0() {
	  std::cout << "N" << O_MORE << SPACE_BOB_SPACE << OTW_COMMA_SPACE
					<< "n" << O_MORE << SPACE_BOB_PERIOD << SLASHN
					<< "Go to the store and buy some more," << SPACE
					<< BEER_MAX
					<< SPACE_BOB_SPACE << OTW_PERIOD << SLASHN;
	}

The above code manages to perfectly demonstrate the glory of a principle applied so blindly that it wraps around and becomes an anti-pattern.  With the principle of DRY (Don't Repeat Yourself) this is, unfortunately, not even that uncommon.  The simple implementation of the above reads thusly:

	void beer0() {
		std::cout << "No more bottles of beer on the wall, "
		          << "no more bottles of beer." << std::endl
		          << "Go to the store and buy some more, "
		          << "99 bottles of beer on the wall." << std::endl;
	}

The author has seen that this implementation contains some duplicate code, and instictively begun to "fix" it.  The resulting mess is not only significantly more code, but code which no one on a simple reading can deduce the purpose of.  It has gone from code with an obvious purpose (output the final verse to the song) to code with an obscured purpose (output... something... can't tell what).

Removing code duplication is of course a good thing, but one removes duplication *for a purpose*.  The simple code has all duplication within four lines, and is not that difficult to maintain.  Given the nature of the song and the purpose of the code, it is unlikely that "bottles of beer" as a phrase would change without other major surgery that would topple the tower of DRY'd out segments that has been built anyway.

Some other fun here includes:

	#define STRINGIFY(x...) #x

Which is only ever used with inline tokens, such as:

	#define BOB STRINGIFY(bottles of beer)

aka

	#define BOB "bottles of beer"

This is an abstraction that does nothing but make the code slightly longer and less idiomatic.

	#define SLASHN std::endl
	#define SPACE ' '
	#define PERIOD STRINGIFY(.)

Giving less-obvious names to single characters, but even more so not using a consistent type.  Why is `SPACE` a character but `PERIOD` is a string literal?  It will all happen to work out because of how the C++ `std::cout <<` operator is defined, but is there any reason for these to differ?  Or exist?  Clearly not all spaces in every string are DRY'd out with this, since even the author could not stomache *that* level of insanity.
</section>

<section markdown="1">
# Re-use, Recycle

	#undef BOB
	#undef BEER_PRONOUN
	#undef BEER_REMAINING
	#if __INCLUDE_LEVEL__ == 1
	  #define BOB STRINGIFY(bottle of beer)
	  #define BEER_PRONOUN STRINGIFY(it)
	  #define BEER_REMAINING STRINGIFY(n) << O_MORE
	#else
	  #define BOB STRINGIFY(bottles of beer)
	  #define BEER_PRONOUN STRINGIFY(one)
	  #define BEER_REMAINING __INCLUDE_LEVEL__ - 1
	#endif
	...
	#undef BOB
	if __INCLUDE_LEVEL__ == 2
	  #define BOB STRINGIFY(bottle of beer)
	else
	  #define BOB STRINGIFY(bottles of beer)
	endif

Since the author already defined a symbol named `BOB`, obviously they must use it for every place where they say "bottle(s) of beer".  But sometimes there is that pesky s, and in two cases there is not.  No problem!  Just undefine the symbol and re-define it... *every single time*, just to handle that special case.  This mutation also requires inlining the special cases into the body of the printing logic, making the whole thing mostly just noise to the eye.

Here the author also re-uses some symbols from above, such as `STRINGIFY` and `O_MORE`.  What's wrong with that?  Well, the definitions above are inside a `#if __INCLUDE_LEVEL__ == 1` directive, so one might be tricked into assuming they are only defined at that level.  However, since all lower levels are included into a copy of the file that was included at level one, the all in fact exist at all levels.
</section>

<section markdown="1">
# Bonus round: the generated C++

	void beer98() {
	  std::cout << 98
		  << ' ' << "bottles of beer" << ' ' << "on the wall" << "," << ' '
		  << 98
		  << ' ' << "bottles of beer" << "." << std::endl
		  << "Take" << ' ' << "one" << ' ' << "down and pass it around,"
		  << ' ' << 98 - 1
		  << ' ' << "bottles of beer" << ' ' << "on the wall" << "." << std::endl << std::endl;
	  beer97();
	}

	void beer99() {
	  std::cout << 99
		  << ' ' << "bottles of beer" << ' ' << "on the wall" << "," << ' '
		  << 99
		  << ' ' << "bottles of beer" << "." << std::endl
		  << "Take" << ' ' << "one" << ' ' << "down and pass it around,"
		  << ' ' << 99 - 1
		  << ' ' << "bottles of beer" << ' ' << "on the wall" << "." << std::endl << std::endl;
	  beer98();
	}

	int main()
	{
	  beer99();
	}

To be fair, the generated code is probably better than the code generator itself in overall readability.  Besides the strange way the strings are formatted, which is mostly an artifact of the DRY malpractise already highlighted, there is another thing here: this code is *intensely* duplicated.  One may fairly argue that generating duplicate code in a sane way is often the *purpose* of a code generation system such as is being employed here, and that is true, but that usually is to facilitate some sort of performance-inlining improvement or similar.  Here, we find code that acts exactly like a tail-recursive version would (quite possibly building a high call stack) but with full duplication instead of recursion!  So it falls short of actually improving on the structure from a runtime point of view, but still has terrible source-time structure.

This points to a "wrong tool for the job" abuse scenario: code generation capabilities can be very useful, but one should be sure they are using them for a purpose.  If they generated code just takes longer to compile but has the same shape at runtime as a direct implementation would have, with no source-readability improvements, that's a pretty strong smell.
</section>

<section markdown="1">
# Conclusion

That's the highlights from November.  Think you can do worse?  Submissions for [December's challenge](<%= @items['/articles/2018337 Robot Simulator/index.*'].path %>) are still open, and a January challenge will be going up soon!
</section>
