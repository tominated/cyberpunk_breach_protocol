# Cyberpunk 2077 Breach Protocol Solver

After seeing
[this article about solving the Cyberpunk 2077 hacking minigame in python](https://nicolas-siplis.com/blog/cyberpwned),
I was inspired to try to build something similar in a more functional style. I
decided to not reference the article's implementation at all, as I wanted to see
if I could recall anything about dynamic programming from my university days.

I decided to implement it relatively naiively, and I'm pretty sure what I did is
very much NOT dynamic programming, but it runs pretty damn quickly in WSL on my
Ryzen 5800X machine (admittedly it's a brand new CPU).

Quick glossary:  
Matrix - the square 2D array of values the user can pick (i've called these
cells)  
Path - a list of values in the order that they are picked in game  
Daemon - the in-game name for a hack that a user can execute if they follow the
correct path  
Buffer - the in-game limit to the path length. This is upgradeable in-game by
getting a new cyberdeck

The current algorithm uses a lot of recursion - the possible paths form a tree
that can be collapsed down once a path executes all the daemons, or runs out of
buffer. The algorithm is supplied a matrix, buffer size, and a list of daemons,
with scores attached for preferences. I recurse through all possible paths,
potentially producing a 'result' value if there's any executed daemons for the
path. These are folded so only the top scoring path remains.

I think it's relatively efficient for a naiive algorithm - thanks to tail
recursion it shouldn't use much memory, and I try not to allocate where easily
avoidable.

Here's an example of the output (as of commit bbee821)

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

given buffer of 11
top path: (2, 4) 1C, (0, 4) FF, (0, 2) 55, (3, 2) BD, (3, 0) E9, (1, 0) BD, (1, 3) FF, (3, 3) 1C, (3, 1) 55, (0, 1) 1C, (0, 0) 1C

executes daemons:
datamine_v2 1C 1C 55 - score: 1
datamine_v3 55 FF 1C - score: 2
copy_malware BD E9 BD 55 - score: 3
crafting specs 55 1C FF BD - score: 4
```
