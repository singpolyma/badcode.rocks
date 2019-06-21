It's time to announce the winner for [May's challenge](<%= @items['/articles/2019121 Pascal\'s Triangle/index.*'].path %>) and do some teardown!

There's still a short amount of time left to send in your submissions for [June's challenge](<%= @items['/articles/2019152 ISBN Verifier/index.*'].path %>), so get on that quick!

# Winner, in Haskell, by Tim Makarios

You may want to [pull up the full source](https://snark.badcode.rocks/archives/2019-June/000036.html) so you can follow along.

<section markdown="1">
# Start at the end

If we take the main body of this submission from the end and tweak it just slightly to use Haskell's built-in Ints with no other changes, we get this:

    main = do
    	[textn] <- getArgs
    	let n = read textn
    	forM_ [0..n-1] $ \m -> do
    		putStrLn
    			$ replicate (n - m - if 5 < n && m < 5 then 0 else 1) ' '
    			++ (concat
    				$ intersperse " "
    				$ map (show . \n ->
    						(2 ^ m + 2) ^ m `div` (2 ^ m + 1) ^ n
    							`rem` (2 ^ m + 1)) $ [0..m]
    					)
    			++ if n == 6 && m == 0 then "      " else ""

This code passes the tests for the challenge, which means that *the entire rest of the submission* is effectively just taking up space.

The given reason for this is:

    -- Since this exercise involves only natural numbers, we can get the compiler
    -- to ensure that we don't accidentally use any negative numbers by defining a
    -- type for the natural numbers.

This is... not necessarily a bad reason.  Except that there is *exactly one line* where a negative number even has a change to be produced:

    	$ replicate (n - m - if 5 < n && m < 5 then 0 else 1) ' '

Adding more than twice as much code as is needed for the complete solution just to avoid a possible mistake in a single expression is... very much doing things the wrong way.  Compile-time checks and type safety are wonderful things, but every line of code added in service of protecting this expression is a change to introduce some *other* bug.  To help the compiler catch a single typo, the author gives themselves the chance to create many, many other typos.

On top of this, once they have created the large code to allow the compiler to check for a single kind of error, the author then leads with: 

    	[textn] <- getArgs
    	let n = read textn

Two lines of code, each of which makes very specific assumptions about the input and will panic the whole process at runtime if those assumptions do not hold.  And these are the lines dealing with user input!  So it is apparently worth it to write huge amounts of code to protect a single expression from oneself, but not at all worth the time to verify that user input is sane.  Got it.

After building the (not so, as we shall see) glorious tower of purity that is a compiler-checked Natural number system, the actual body of the Pascal's Triangle algorithm is incredibly imperative in design.  First of all, it looks a bit hairy with the ball of nested math in there -- some readers might find that scary.  It doesn't really matter to understanding the program, though, unless the closed-form of a cell in Pascal's triangle is being changed, so it would benefit very much from being given a name:

    triangleCellFor row column =
    	(2 ^ row + 2) ^ row `div` (2 ^ row + 1) ^ column `rem` (2 ^ row + 1)

Then a whole bunch of the code is only there to build strings and print them, something Haskell is designed to make it easy to separate out.
</section>

<section markdown="1">
# All the best Haskellers use language extensions

    {- LANGUAGE	GADTs
    	,	Arrows
    	,	FlexibleContexts
    	,	OverloadedStrings
    	,	RankNTypes
    	,	PolymorphicComponents
    -}

This seems, at first glance, to be an *awful* lot of language extensions to enable for such a simple problem (more out-of-proportion activity?), but on a second reading it's even dumber: this is *not* the syntax for a pragma (`{-# #-}`) but only the syntax for a multiline comment.  This is a comment even worse than one which tells a false story about the code: it appears to *be* code, but is not.

Of course, actually using all of these extensions in implementing such a simple problem may have been even worse... but this is pretty bad.
</section>

<section markdown="1">
# Here's what I wish this code did

    --data ℕ = Ø | I𐊛 ℕ deriving Eq
    data ℕ = Ø | I𐊛IIIх ℕ | II𐊛IIIх ℕ | III𐊛IIIх ℕ deriving Eq

The author begins with some comments explaining that the classic definition of Natural numbers is too hard to write efficient operations for, and so a different representation had to be used.  The author then proceeds to *leave the entire too-inefficient implementation* in the codebase, just commented out wherever it happened to fall.  You know, to document what the actual implementation is doing by showing a *complete implementation* the author wishes they were using instead.

The use of Unicode above wouldn't be *so* bad if it weren't for the cute 𐊛.  It's meant to look like a "plus" sign, and depending on your font maybe it does.  For the judges, it took quite some time to even realise that's what it is meant to represent.  So instead of the classic:

    data Natural = Z | S Natural

The author chooses to use `I` to mean `1` and `𐊛 ` to mean `+`, so `0 | 1 + N`.  When that turns out to be too slow, does the author fall back on the numbers and arithmetic that CPUs already know how to do at the speed of hardware?  No, rather they fall into the classic optimization trap of improving that which is causing a specific part of the problem instead of imagining what would suit the entire application best.  One reason the "nice" definition of Natural numbers is so slow is the deeply-nested recursion and pattern matching needed to perform most operations on larger numbers.  So the author chooses to hyper-focus on that particular bottleneck, never realizing that a much more obvious solution is available, flattening the representation just slightly with the comical `0 | 1 + 3x | 2 + 3x | 3 + 3x` representation used throughout.
</section>

<section markdown="1">
# Idioms, idioms, idioms, idioms

Where to begin with this?  Ah, here:

    import Prelude hiding ((+), (-), (/), (^), (<), read, replicate)

Hiding operators that form a core part of a language is rarely a good sign, but in this case it's so much worse.  Every function here (except for `replicate`) is part of a typeclass and already designed to be overloaded for new numeric types.  So the correct way to use them, if implementing a new numeric type as is being done here, is to implement those typeclasses.  Instead the author chooses to hide them away so that the operators will work *only* with the new numeric type.

The operators are all defined with explicit precedence rules, overriding their default precedence in the language.  In the best case, this is just useless visual noise, in the worst case the author may accidentally change the semantics of arithmetic expressions in the program and wonder why that pretty closed-form expression isn't outputting the right numbers.

Because ignoring the extensible numeric typeclass idioms wasn't enough, the author *also* does not hide `*` but instead introduces a new operator `⨉` for multiplication -- because we're in the first grade apparently.  Then for good measure the extensible typeclass idioms for parsing strings and producing strings are ignored also, though just in case you wanted to defend the author and claim that maybe they are new to Haskell and simply didn't know about all this, there is this line:

    --instance Show ℕ where show = write

Showing that they *thought* about doing it right, ish, maybe, and then decided against it.

Because of the way the Natural type is defined, and the way that helper constants are defined also:

    i = I𐊛IIIх Ø
    ii = II𐊛IIIх Ø
    iii = III𐊛IIIх Ø
    iiii = I𐊛IIIх i
    iiiii = II𐊛IIIх i
    iiiiii = III𐊛IIIх i
    iiiiiii = I𐊛IIIх ii
    iiiiiiii = II𐊛IIIх ii
    iiiiiiiii = III𐊛IIIх ii
    iiiiiiiiii = I𐊛IIIх iii

a full *one fifth* of the source code in this submission is either an uppercase or lowercase `I`.  However, had the correct `Num`, `Integral`, `Enum`, `Read`, and `Show` typeclasses been defined, normal numeric literals such as `1` and `5` would have been treated correctly as the ℕ type desired, the `listLessThan` could have been replaced with range syntax, and the custom `replicate` would not have been necessary.

That is to say, that *even sticking to this hilarious representation* the code would have been much simpler and clearer (and possibly barely worth considering "bad" for the purposes of this contest) had basic idioms for code structure been followed.
</section>

<section markdown="1">
# Conclusion

Think you can do worse?  Submissions for [June's challenge](<%= @items['/articles/2019152 ISBN Verifier/index.*'].path %>) are still open, and a July challenge will be going up soon!
</section>
