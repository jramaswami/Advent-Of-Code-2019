OR A T
AND B T
AND C T  ;# T is 1 if there are no holes in ABC and 0 if there are
NOT T T
AND D T  ;# T Now holds if we jump b/c of first set of holes
OR E J
AND F J
AND G J  ;# J is 1 if there are no holds in EFG and 0 if there are
NOT J J
AND H J  ;# J now holds if we jump b/c of second set of holes
AND T J
AND D J
RUN
