# Notes for Day 17 :: Set and Forget

When I solved the puzzle the first time, I broke the path down into 
subroutines by hand.  Looking through the solution thread indicated
that this is how most people solved the puzzle.  However, was there
a way to do it automatically?

On the solution thread, distrattoperscelta[1] suggested "binary pair 
encoding."  I think this is byte pair encoding[2].  This produces the
correct subroutines.  However, I did have to fiddle with it to make
it work.  When selecting the pair with the greatest frequency, you 
must compare using `<=` and not just `<`.  When I used just `<` the
three subroutines produced included one that overlapped with a previous
subroutine.  Changing to `<=` fixed this problem, I think because
it tends to substitute later pairs instead of earlier pairs, thus
creating a more even tree of substitutions.

[1] https://www.reddit.com/r/adventofcode/comments/ebr7dg/2019_day_17_solutions/fb755q0/
[2] https://en.wikipedia.org/wiki/Byte_pair_encoding
