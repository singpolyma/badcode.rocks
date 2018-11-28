It's time to announce the winner for [October's challenge](<%= @items['/articles/2018274 Pig Latin/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [November's challenge](<%= @items['/articles/2018305 Beer Song/index.*'].path %>), so get on that quick!

# Honourable Mentions

We're only picking one winner for this teardown, but that doesn't mean there weren't several wonderfully bad submissions to choose from.  Some of our favourites that didn't quite win include:

* [Ruby: Graham Cooper](https://snark.badcode.rocks/archives/2018-October/000003.html) — some terrible assumptions, mounds of flag variables, and filesystem abuse to boot!  Unfortunately, this submission was disqualified for not passing all tests.
* [Ruby: Zachary R.](https://snark.badcode.rocks/archives/2018-October/000006.html) — A good idea gone horribly wrong, this was the least time and space efficient submission we received.  Includes some last-minute special cases and thematic joke names for your reading pleasure.
* [Docker Node Bash: Sean Howard](https://snark.badcode.rocks/archives/2018-October/000007.html) — This submission chose the high road: using an existing pig latin library!  Just as a real programmer should.  For good measure, the chosen library does not actually implement the pig latin specified and so several fixups are done outside in bash.  Also, the library comes from npm so better stuff that in docker behind an HTTP service.

# Winner, in C: Finn Alexander O'Leary

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2018-October/000004.html) so you can follow along.

<section markdown="1">
# Whose Boolean is it Anyway?

This submission includes *three* different ways of handling boolean values, with one being the actually standard way supported by the language.  As you open the code the most obvious lines at the top are:

	#define True "true"
	#define False "false"

While it is unlikely anyone would ever *actually* write these lines, they serve as a humorous exaggeration of things people really *do* write.

The standard values for booleans in C have always been `1` and `0`.  C99 and up add `true` and `false` keywords as well.  Ignoring the standard idioms of your language to "improve readability" actually does the opposite.  Even if `1` and `0` are not obviously boolean values to a new programmer, or someone new to C, renaming them obscures meaning from anyone who knows how to read C code.  This will include you later.  That's not to say one must always blindly follow idioms, but departing from how the language is normally written needs a very good reason, or else you make it harder to understand what is going on.

Partly because of the nature of these constants, there are also a few related anti-patterns on display.  Including:

	if (ISVOWEL(S)) { return True; }
	else if (S == 'y' && !ISVOWEL(S1)) { return True; }
	else if (S == 'x' && S1 == 'r') { return True; }

	return False;

and:

	if (strcmp(True, isvowelay(S[0], S[1])) == 0)

Both of these common anti-patterns show a lack of understanding of what a boolean value *is*.  While both are actually necessary in this case, because the values are actually strings, they intentionally parallel unnecessary verbosity when using regular boolean values in any language.  A boolean value already holds the concept of "true" or "false", and so can be returned directly.  An `if` already evaluates based on a boolean value, and so comparison to a boolean constant is redundant.  The natural rewriting of the above would be:

	ISVOWEL(S) || (S == 'y' && !ISVOWEL(S1)) || (S == 'x' && S1 == 'r')

and:

	if (isvowelay(S[0], S[1]))

To make things even more confusing, in this submission since the custom boolean constants are actually strings, but normal C comparisons such as `S == 'x'` do not return those strings, there are two sets of conceptual booleans at play in these lines.  Even worse, later in the program there is a procedure that returns either `1` for "true" or `-1` for "false", requiring a programmer reading this code to understand three different ways of encoding the same information.
</section>

<section markdown="1">
# Types are for losers

	struct __attribute__((packed)) thingimajigie {
		char **start;
		char *end;
	} word_thingies[256];

This line contains a GNU C extension and thus the whole program is not actually standard C and may not compile or work as expected on some compilers.  So, what is the reason this extension is needed?

	void *S = &(word_thingies[i]);
	...
	S -= (sizeof(char**)+sizeof(char*));

Because pointers are so common in C, arithmetic on pointers is specifically defined to be type-dependant.  So the above is actually equivalent to this:

	struct thingimajigie *S = word_thingies + i;
	...
	S -= 1;

But in an amazingly bad way.  First of all, `sizeof(char**)+sizeof(char*)` assumes that the members of the struct will always have exactly these types.  To avoid this kind of brittle assumption, C code will normally use a pattern more like `sizeof(S->start)+sizeof(S->end)`.  That, however, still assumes that the struct will always have exactly those two members.  It further assumes that the size of the struct is *exactly* the sum of the sizes of its members, which C does not promise to us.  That is the reason for the use of the language extension.  This code has been rendered non-portable only so that a worse way of determining the struct size can be used.  Of course the right way would be to use `sizeof(*S)`, or better yet to use a variable with the correct type as above.

Using `void` here also requires many casts in the body:

	((struct thingimajigie *)S)->start = &(*A)[i];
	((struct thingimajigie *)S)->end = malloc(_strlen((*A)[i])+1);
	memset((((struct thingimajigie *)S)->end), 'A', _strlen((*A)[i]));
	*((char*)((struct thingimajigie *)S)->end+strlen((*A)[i])) = '\0';
</section>

<section markdown="1">
# Idioms!

	unsigned char i = ((2)<<6);
	do {
		...
	} while(i--);

Also known as:

	int i;
	for(i = 128; i > 0; i--) {
		...
	}

Using an obfuscating expression like `2 << 6` is hiding the fact that this is actually the *wrong number*.  The loop is iterating down over an array of size 256 (or `2 << 7`) and so an off-by-one bug in this expression is cutting off *half the array*.

Beyond the number being obfuscated and wrong, using a `do...while` loop for successive iteration of this type obscures the purpose of the loop.  A `for` loop doesn't exist because one cannot do something without it, but rather as an idiom to signal to the reader what kind of loop this is.  Once again, ignoring the idioms of the language may seem clever, but without very good reason make it harder for anyone familiar with the language to discern your intent.

Further, the code is actually:

	do {
		if(i < charie) {
			...

Meaning that the constant is not even necessary, and could be:

	for(i = charie - 1; i > 0; i--)

Related is this strange choice:

	int _strlen(char *s)
	{
		return (s ? strlen(s) : 0);
	}

The author introduces a small wrapper around a common standard library procedure to guard against `NULL` pointers with particular behaviour.  However, this is so uncommon that *even the author themself* often forgets to use this version, and calls the standard library directly instead, even on the same value that they later pass to this wrapper.  It seems that the pointers passed to this wrapper are, in fact, never `NULL` and so the wrapper only exists as a bad form of defensive programming.  If the pointer ever *were* to be `NULL` would the `0` return value here even be correct?  Any of the code in question would segfault in that case anyway, so it really doesn't matter.
</section>

<section markdown="1">
# Macros

	/* KITTEN <-> CAT <-> CONCATENATE... it's a bad joke don't @ me */
	#define KITTEN(a, b) a # b
	#define BALL_OF_STRING(a,b) a ## b
	#define DEFISCHARACTER(string) size_t BALL_OF_STRING(is, string) (int c) { return (c == KITTEN(, string)[0] || tolower(c) == KITTEN(, string)[0]) ? 1 : 0; }

This code is so bad that even in a submission to a bad code contest, it has a comment apologizing.

Besides the bad names, `KITTEN` is nonsense and is only ever used like `KITTEN(, x)` with no first argument at all.  If you did pass a first argument, the result would be a syntax error.

The author has gotten distracted by the idea of a certain pattern—`isa`, `ise`, etc procedures for case-insensitive checking—and turned to macros to make generating them easier without stopping to think what the actual problem they are solving requires.  Are they solving the problem of needing an `isa` procedure?  Or are they rather solving the problem of needing a way to case-insensitively check for character equality.

	int ischar_ci(char x, char y) {
		return tolower(x) == tolower(y);
	}

We use the generated procedures a bit lower down inside another macro:

	char *isvowelay(char S, char S1) /* REMOVE: USE LIKE: S = isvowelay(string[0], string[1]); strcmp(S, "true");  */
	{
		#define ISVOWEL(_) (isa(_) || ise(_) || isi(_) || iso(_) || isu(_))
		...
	}

	struct capture isconsonant(char *string)
	{
		...
		else if (!ISVOWEL(string[0]) && string[1] == 'q' && string[2] == 'u') { 
		...
	}

The author introduces a macro that *appears* like it is meant to only be part of the `isvowelay` procedure, but that's not how macros work, they operate before the C parser even runs, so cannot respect the C scopes.  That turns out to be handy, because later on the macro is used in a different procedure.  While any experienced C programmer who understands the preprocessor will know why this works, the way it's written at best puts the macro definition in an inexplicably weird place, and at worst confuses the reader into thinking it works differently than it does.

There is also no reason at all for this to be a macro.  It does not make use of any capability that a normal C procedure would not have.
</section>

<section markdown="1">
# What are pointers for, again?

	static char ***A;
	int main(int _, char **__)
	{
		A = &__;

and also:

	struct __attribute__((packed)) thingimajigie {
		char **start;
		char *end;
	} word_thingies[256];
	...
	((struct thingimajigie *)S)->start = &(*A)[i];
	((struct thingimajigie *)S)->end = malloc(_strlen((*A)[i])+1);


Glossing over the idiom-violation that is naming `argc` and `argv` as `_` and `__`, why `***A`?  If you look through the code, you will find that `A` is *always* immediately dereferenced.  So why the extra indirection?  Well, one reason to take a pointer to a value instead of the value itself is that it prevents needing to copy the value.  You can get at the value wherever it already exists in memory, and save the work of copying.  This is a case of just blindly applying that rule.  The same with `**start`, wouldn't want to copy whatever `(*A)[i]` is!

This is what comes of taking performance advice without understanding *why*.  Or really, doing anything in your code based only on a rule you heard and not understanding *why*.  Taking the address in `&__` is the same or more work as just copying its value, because the value of `__` is already a pointer, so the amount of data to be copied (if that even proves necessary) is exactly the same in either case.  The author even knows this, since they can clearly see the type `char **__` just above.
</section>

<section markdown="1">
# Assumptions

	void write_string(char *dest, char *src, struct capture c)
	{
		strncpy(dest, src+c.i, c.j);
	}

`strncpy` is one of those really dangerous library calls masquerading as a "safer one".  If the source string is longer than the given size, the result is not null-terminated, and thus is not a valid C string and all kinds of bad things are likely to happen.  This helper neither checks the length, nor forces a null termination manually.  It's an accident waiting to happen.

This is just the most devious of the many unchecked assumptions throughout the program, including: that there will be no more than 256 words passed in, that all the globals are initialized before any procedure is called, and that no word contains characters that might be interesting to a shell.
</section>

<section markdown="1">
# Last Minute Fix

	if (_ > 0 && people_gave_one_argument_with_the_words_rather_than_giving_them_as_separate_arguments() > 0) {
		/* I never designed for this shit, only noticed when it came to the tests, so instead let's design around it */
		char *command = calloc(strlen(__[0]) + strlen(__[1]) + 2, sizeof(char));
		strcpy(command, __[0]);
		command[strlen(__[0])] = ' ';
		strcpy(command+1+strlen(__[0]), __[1]);
		// printf("command: %s\n", command);
		FILE *f = popen(command, "r");
		int i;
		do {
			fputc((i = fgetc(f)), stdout);
		} while (!feof(f) && i != '\n');
		fclose(f);
		free(command);
		return 0;
	}

This is the true pride and glory of this submission.  Having not read the tests before beginning, the author was faced with a solution that passed all but the last test.  Rather than go back and design a solution that fits into the program, they thought of the cleverest way they could add the functionality for the new requirement as quickly as possible, so as to be done.  This is the most real-world tech debt you will ever encounter.  New requirement at the eleventh hour results in quick trip to the cleverness stores.

This code checks if the first argument is a phrase using the aptly named `people_gave_one_argument_with_the_words_rather_than_giving_them_as_separate_arguments` and then proceeds to shell out to run another copy of this same program, but with the words in the phrase each as a separate argument, essentially using the invocation semantics as a split-on-words parser.o

This is another place the code becomes gratuitously non-portable, choosing to use the POSIX-only `popen` instead of the C-standard `system` library call.  Using `popen` actually complicates the code, resulting in a quickly-written loop to read all output from the subprocess and output it again, rather than simply allowing the subprocess to inherit `STDOUT`.
</section>

<section markdown="1">
# Fun bits not worth writing paragraphs about

	indexer_for_the_word_thingies
	thingimajigie
	load_me_the_thingie_withie
	dologic
	people_gave_one_argument_with_the_words_rather_than_giving_them_as_separate_arguments


	/* REMOVE: USE LIKE: S = isvowelay(string[0], string[1]); strcmp(S, "true");  */
	/* printf("c.i: %d; c.j: %d\n", c.i, c.j); */
	// printf("command: %s\n", command);
	/* printf("%s %s %s\n", *word_thingies[i].start, isvowelay((*word_thingies[i].start)[0], (*word_thingies[i].start)[1]), word_thingies[i].end); */


	a.i = c.j;
	a.j = strlen(S)-c.j;

	b.i = 0;
	b.j = c.j;

	d.i = 0;
	d.j = 3;

</section>
