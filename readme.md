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

Here's an example of the output (as of commit 2bc351c)

```
$ dune exec cyberpunk_breach_protocol
Paths for matrix:    
 1C BD 55 E9 55
 1C BD 1C 55 E9
 55 E9 E9 BD BD
 55 FF FF 1C 1C
 FF E9 1C BD FF

For daemons:
datamine_v2 1C 1C 55 - score: 1
datamine_v3 55 FF 1C - score: 2
copy_malware BD E9 BD 55 - score: 3
crafting specs 55 1C FF BD - score: 4

given buffer of 7
num potential paths: 9169
top path: (1, 0) BD, (1, 2) E9, (3, 2) BD, (3, 1) 55, (0, 1) 1C, (0, 4) FF, (3, 4) BD

executes daemons:
copy_malware BD E9 BD 55 - score: 3
crafting specs 55 1C FF BD - score: 4
```
