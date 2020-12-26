# Cyberpunk 2077 Breach Protocol Solver

After seeing
[this article about solving the Cyberpunk 2077 hacking minigame in python](https://nicolas-siplis.com/blog/cyberpwned),
I was inspired to try to build something similar in a more functional style. I
decided to not reference the article's implementation at all, as I wanted to see
if I could recall anything about dynamic programming from my university days.

I decided that for my first attempt, I'll do it relatively naiively, and I'm
pretty sure what I did is very much NOT dynamic programming, but it runs pretty
damn quickly in WSL on my Ryzen 5800X machine (admittedly it's a brand new CPU).

I basically map out each possible path that a user could take through a matrix,
and keep tally of how much progress is made on each daemon (the in-game name for
a hack you will execute). If there's not enough buffer left (your in-game
'cyberdeck' has a maximum sequence length - you can upgrade it as you progress),
or if the path executes every daemon specified, the path is stopped early.

I then do a regular old list filter for any paths that have executed every
daemon. It's certainly far from optimal, and probably allocates WAY more than
necessary, but that's probably what I'll work on next.

Here's an example of the output (as of commit c4aa242)

```
$ dune exec cyberpunk_breach_protocol
Paths for matrix:    
 1C BD 55 E9 55
 1C BD 1C 55 E9
 55 E9 E9 BD BD
 55 FF FF 1C 1C
 FF E9 1C BD FF

For daemons:
datamine_v2 1C 1C 55
datamine_v3 55 FF 1C
copy_malware BD E9 BD 55
crafting specs 55 1C FF BD

given buffer of 11
num paths: 909061
num complete paths: 6
((0, 0)) 1C, ((0, 1)) 1C, ((3, 1)) 55, ((3, 3)) 1C, ((1, 3)) FF, ((1, 0)) BD, ((3, 0)) E9, ((3, 2)) BD, ((0, 2)) 55, ((0, 4)) FF, ((2, 4)) 1C
((0, 0)) 1C, ((0, 1)) 1C, ((3, 1)) 55, ((3, 3)) 1C, ((1, 3)) FF, ((1, 1)) BD, ((4, 1)) E9, ((4, 2)) BD, ((0, 2)) 55, ((0, 4)) FF, ((2, 4)) 1C
((4, 0)) 55, ((4, 3)) 1C, ((1, 3)) FF, ((1, 0)) BD, ((3, 0)) E9, ((3, 2)) BD, ((0, 2)) 55, ((0, 4)) FF, ((2, 4)) 1C, ((2, 1)) 1C, ((3, 1)) 55
((4, 0)) 55, ((4, 3)) 1C, ((1, 3)) FF, ((1, 1)) BD, ((4, 1)) E9, ((4, 2)) BD, ((0, 2)) 55, ((0, 4)) FF, ((2, 4)) 1C, ((2, 1)) 1C, ((3, 1)) 55
((4, 0)) 55, ((4, 4)) FF, ((2, 4)) 1C, ((2, 1)) 1C, ((3, 1)) 55, ((3, 3)) 1C, ((1, 3)) FF, ((1, 0)) BD, ((3, 0)) E9, ((3, 2)) BD, ((0, 2)) 55
((4, 0)) 55, ((4, 4)) FF, ((2, 4)) 1C, ((2, 1)) 1C, ((3, 1)) 55, ((3, 3)) 1C, ((1, 3)) FF, ((1, 1)) BD, ((4, 1)) E9, ((4, 2)) BD, ((0, 2)) 55
```
