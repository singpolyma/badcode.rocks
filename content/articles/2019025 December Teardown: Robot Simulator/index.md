It's time to announce the winner for [December's challenge](<%= @items['/articles/2018337 Robot Simulator/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [January's challenge](<%= @items['/articles/2019001 Bowling/index.*'].path %>), so get on that quick!

# Honourable Mentions

It was a close race this time, so we'll take more time than usual to talk about our runner-up.  [In Ruby, from Rory O’Kane](https://snark.badcode.rocks/archives/2019-January/000026.html), this submission had some basic stuff: inconsistently formatted magic comments (though the presence of those comments in Ruby is almost a *good* practise, for shame!), use of `eval` to parse numbers, many global variables, useless assignments, and changing the input to another format for no good reason.

The really impenetrable, truly bad part of this submission though, is the final algorithm to determine the robot's position.  Combining a global variable with an algorithm that re-processes already-handled instructions over and over in a loop, it took our judges *several* read-throughs to understand why this code worked at all.  Impossible to understand without being hard to read, this is exactly the kind of bad code this competition is all about.

# Winner, in Javascript, C, Shell, Make, LISP, Forth, and Python, by group `__1EC7__`

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2018-December/000025.html) so you can follow along.

<section markdown="1">
# One simple job, so many tools

While not strictly "bad code", it is impossible to talk about this submission without talking about the sheer *number* of languages and tools involved.  The entrypoint is Javascript meant to be run with nodejs, which executes a Makefile, some shell scripts, and some programs compiled from C to create XML which is read by a Python script and manipulated using still more scripts and binaries.

Now, combining many small parts and using the "right tool for the job" can be a part of an elegant solution.  In this case, however, many of the scripts serve either no purpose, or are decidedly *not* better suited to the job than other tools in the stack.  For example:

    function run(){
        a=$(gforth -e "s\" $1\"" ./forths/translate.forth -e "move-to-number bye")
        case $a in
            "10"*) return 10;;
            "20"*) return 20;;
            "30"*) return 30;;
            "40"*) return 40;;
        esac
    }

    run $1
    exit $?

Here a Forth script is invoked for the purpose of converting N/S/E/W to the numbers 10/20/30/40.  Is Forth a better choice for such a simple map lookup / case statement operation than other tools in the stack?  Certainly not, since the very next thing this program does is an equivalent case statement right here in the shell script than invoked the Forth.  Assuming this conversion is even a reasonable thing to do, and assuming shell is going to be involved anyway, this could easily have been written as:

	case "$1" in
		N) exit 10;;
		S) exit 20;;
		E) exit 30;;
		W) exit 40;;
	esac

This is actually less (and clearer) code than even the above script *and* includes all the functionality of the Forth script as well.

It is also highly debatable whether placing the main (and here, only) return value of a script in the exit code is a good idea.  Especially since the only place to call this script immediately turns that exit code bad into STDOUT:

    .exec("cd scripts ;bash ../scripts/translate.bash " + RobotDirectionFace + " && echo $?".split('&').join('|')

Oh, there is also some SQL present in this submission.  It is never used, but present twice in duplicate.  Just to have another technology at least present.

This submission feels like a small-size replica of what happens with sprawling legacy codebases.  No one wants to understand or edit what already exists, and only new code (in whatever the "current" stack is) gets added.  Instead of understanding or replacing the Forth, wrap it in shell!  Right down to exaggerations like the one above:

    "&& echo $?".split('&').join('|')

instead of:

    "|| echo $?"
</section>

<section markdown="1">
# The incredible, if unused, SQL

Near the start of the entrypoint is code to generate a SQL `CREATE TABLE` statement.  This is never used, but even so the code to generate it is glorious:

    const S = ' ' // store space to save space
    const TABLE_NAME = "table"
    const cordinate_tpyeof='VARCHAR(20)'
    // ^ use varchar to handle <0
    const direction_typeof = 'INT'
    
    r = "CREATE"
    r = r + S + TABLE_NAME
    r = r + S + TABLE_NAME
    r = r + "("
    r = r + "field" + 1 + S + cordinate_tpyeof + ','
    r = r + "field" + 2 + S + cordinate_tpyeof + ','
    r = r + "field" + 3 + S + cordinate_tpyeof + ','
    //print('DON'T USE THAT!! 3 is not used more')
    r = r + "field" + 4 + S + direction_typeof + ','
    
    // change last
    newr=""
    for (i = 0; i<r.length; i++)
        if (i + 1 < r.length)
            newr = newr + r[i];
      else newr = newr + ")";
    
    // fs.writeFileSync('file.sql', String(newr))

Every line of this disaster is a gem.  First, the developers wish to ensure that they... store a string containing only the space character in a constant to "save space".  What kind of space do they think is being saved?  It will not save visual space, or memory, and will if anything provide opportunities for an *increase* in memory used (for example "blah" + S + "blah" will, if not optimized, have to allocate space for the concatenation to be written into).

Next, the table name must be in a constant.  This is not a terrible idea, but the value is only used once.  Or... twice, but only once as the name of a table.  It just so happens that the developers have chosen one of the least descriptive names they could for this table... "table".  Since the beginning of the statement the want will read `CREATE table` they use the `TABLE_NAME` constant to get the word "table" in both for the name of the statement and the name of the table, resulting in `CREATE table table` being written as `"CREATE" + S + TABLE_NAME + S + TABLE_NAME`.

Next, a constant for the type of coordinate columns.  Or, the, tpyeof, since apparently our developers were in too much of a rush to even read their own identifiers back for obvious typos.  This constant is used three times in the code that follows, but still smells of over-DRYing since it renders that code much harder to read and doesn't increase the ease of changing it by much.  The comment says this type is VARCHAR to "handle <0"... even though INT can handle negatives just fine.  Since none of this is ever used, it is unclear what this comment ever meant.

Next follows an unreadable set of concatenations to produce the SQL statement.  All but the first line starting with `r = r +` for no reason except to add line noise, since at very least `r +=` is available, and other ways of wrapping the lines are available.  These concatenations also contain a useless trick that recurs later in the program: that of refusing to place numbers in string literals but instead insisting upon concatenating string literals with numeric literals such as in `"field" + 1`, which happens to work but gains absolutely nothing.

Oh, this block also has a commented out print.  It is curious for several reasons.  One is that `print` is not even a defined function here (the nodejs function to print a line to the console being `console.log`).  Also this print does not seem to be old debugging code, but actually is phrased as a reminder to the programmers, so it is actually just a normal code comment formatted as function call?

Almost done, except that the string the program has now created ends in a comma when it should end in a close-paren.  No problem!  Simply create a new variable with an empty string, loop over the entire string previously created, and copy each character in turn to the new variable until reaching the end, at which point ignore the comma that is there and add a close-paren instead.  It is as if the programmers believed that they could not possibly edit the code which produced `r` after having written it (perhaps fearing that some later code relied on the closing comma?) and so could only solve the bug by writing new code, and not by editing anything present.  This pattern of fixing bad code by writing more bad code instead of editing to fix a bug persists throughout the submission.

And ending with a commented-out line to write the final SQL statement to a file.  A file which, coincidentally, was also part of the submission.  So, not only is this commented out code (bad) coming after dead code (bad), the whole operation could at most produce a static file which is itself included, making this a very egregious form of code duplication.  Duplicated dead code.
</section>

<section markdown="1">
# sleep and all will be well

Nodejs is, in many cases, built on the idea of asynchronous I/O and callbacks.  This means that the dependencies between operations can be directly expressed, and the runtime can schedule them accordingly.  It's a powerful model that this code chooses to get wrong as much as possible.

    require('child_process').exec("make build"+2)
    direction_facing_to = require('child_process').exec(
        "cd scripts ;bash ../scripts/translate.bash " + RobotDirectionFace + " && echo $?".split('&').join('|'),
        null,
        function(error, stdout, sterr) { direction_facing_to = stdout; }
    )
    
    require('child_process').exec('sleep' + S + 2/4, null, ()=>{
        require('child_process').exec('bin/genxml' + S + robotCordinateXaxis + S + robotCordinateYaxis + S + direction_facing_to)
    })
    
    require('child_process').exec(
        [MAKE, 'ROBOT', arguments[5]].join(S).replace(/T /, 'T DO=')
    ).stdout.on('data', console.log)

The program first kicks off `make build2` and returns immediately, not waiting for that to finish.  Next, `translate.bash` is run, possibly at the same time as the make job is still running.  The result is placed in `direction_facing_to`... wait, what result?  Well, first the result of the `exec` call, which is a handle to the process or similar.  However, once the script finishes, the callback will overwrite the variable with the contents of STDOUT, which seems like the actually desired effect.  So the first assignment is a bug.

The next operation runs `bin/genxml`, something that `make build2` causes to exist.  It also uses `direction_facing_to`, desiring to have it contain the STDOUT result from `translate.bash`.  However, the callback dependencies are *not* set up to have *either* of these things be available.  So, how does this work?  The programmers have decided that rather than use the callbacks, they can just sleep "enough" time and both of the other operations will be done.  This is perhaps a rookie sort of mistake, except that the programmers are *clearly* aware of the callback mechanism, since they not only used it above but also use it here to make the sleep work!

Just a blocking sleep right in nodejs will not do, since that would block the whole thread and prevent the required callback above from running.  So, our clever programmers have worked around that by running the `sleep` program present on the system, which will run outside of this thread (and outside of this process).  Once that sleep command has finished running, then the program blindly assumes that the required operations are complete.

The program ends by calling `MAKE ROBOT` as though it were not dependent on anything that came before.  There's no sleep here, is there?  Oh, yes there is.  In the Makefile:

    ROBOT:
    	@sleep 1 # wait for callbacks
</section>

<section markdown="1">
# Commented out code everywhere

Most programmers have, at one time or another, been guilty of using their editor as a makeshift version control system.  When the programmer doesn't trust the undo function, they may even resort to commenting out code.  These programmers have done so and left it behind as extra visual noise that makes following what is happening that much harder.  The most egregious case of this is `genxml.c`, which contains both a mostly-straightforward implementation in C++ (entirely commented out) and an obfuscated implementation in C and CPP.
</section>

<section markdown="1">
# How to turn a robot

So N/S/E/W becomes 10/20/30/40... why?  There are two parts to this answer... both are different kinds of clever, but always the kind of clever that just makes things worse.

The robot can turn left or right, but there only needs to be an implementation for right because helpfully:

    if [ $1 = "LEFT" ]; then
        $0 RIGHT; $0 RIGHT; $0 RIGHT;
    fi

The most obvious way to turn right, then, is:

    : turn-right ( n -- )
        20 + 50 mod dup 0=
        if
            drop 20 .
        else
            .
        then ;

For those who have trouble reading Forth:

	let d = argument1 + 20
	if(d % 50 == 0) {
		20
	} else {
		d
	}

This is neat once you understand it, but not really any easier or faster or less code (and certainly less clear!) than a map lookup or case statement.  This works because the numbers 10/20/30/40 have not been arranged around the circle N/E/S/W, but rather across the points N/S/E/W and so adding 20 (mod 50 rolling over to 20...) brings the value around the circle.

Assuming you got that, you will now wonder why 10/20/30/40 + 20 % 50 when 1/2/3/4 + 2 % 5 would have worked just as well?  Are you sure you want to know?

    class Const:
        MAGIC='THIS IS A NOT SERIOUS THING PLEASE STOP WORRYING'
        MAGICS={str(k):v for k,v in enumerate(MAGIC)}
    ...
    print(Const.MAGICS[l.split('>')[1][:2]], end='')

To spell it out:

	MAGIC[10] == MAGICS["10"] == "N"
	MAGIC[20] == MAGICS["20"] == "S"
	MAGIC[30] == MAGICS["30"] == "E"
	MAGIC[40] == MAGICS["40"] == "W"

This is incredibly clever, and it surely took quite some time and effort to get right, but is so unhelpful to an understanding of how the code works that the judges did *not* understand this until creating this write up.

While the first clever "add 20" bit is the sort of thing one might be proud of until seeing that it makes the code harder to understand, this one smacks of straight-up obfuscation.  It's unlikely this really falls under something that is even realistic anymore, but it sure is impressive.
</section>

<section markdown="1">
# The worst use of the preprocessor

After the terrible CPP code that won for November, this may not seem possible, but here is a much worse use:

	#define cpy copy
	...
	char *copy;
	wnum(&cpy, 000, x);

And also an incredible-that-it-works use:

	void main(int argc, char *argv[]) {
        ...
        #include "unistd.h";
        execv("./bin/genxml", argv);

This includes a standard header file (using the syntax meant for local headers...) and pastes whatever happens to be in there on this system into the body of `main`.
</section>

<section markdown="1">
# Presented without comment

    // advance the robot forward in front of it
    int *axis; /* the movement axis //
    int quantity /* the movement speeed */
    int sign=0 /* the movement direction */;
    if (d<0x18) // if d is underage (hex) don't have X with it
    axis = &y; // don't ask Y
    if (d>0x18) axis=&x; // if d is over 18 can do x
    if (d/BASE%2) sign++;
    if (d/BASE%2) sign++;
    // I f'd up something here but it works
    *axis = *axis+--sign;
</section>

<section markdown="1">
# Conclusion

There are so many more things wrong with this submission, but this post is already quite long and there is so much that is bad in a big way that calling out smaller things hardly seems worth it.  Think you can do worse?  Submissions for [January's challenge](<%= @items['/articles/2019001 Bowling/index.*'].path %>) are still open, and a February challenge will be going up soon!
</section>
