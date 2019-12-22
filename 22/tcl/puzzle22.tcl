# Advent of Code 2019 :: Day 21 :: Slam Shuffle
# https://adventofcode.com/2019/day/22

proc init_deck {n} {
    set ::deck_length $n
}

proc keep {card} {
    set ::keep $card
}

proc deal {a b c} {
    if {$a == "with"} {
        # Deal with increment
        set ::keep [expr {($::keep * $c) % $::deck_length}]
    } elseif {$a == "into"} {
        # Deal into new stack
        set ::keep [expr {$::deck_length - $::keep - 1}]
    }
}

proc cut {n} {
    if {$n > 0} {
        if {$::keep < $n} {
            set ::keep [expr {$::keep + $::deck_length - $n}]
        } else {
            set ::keep [expr {$::keep - $n}]
        }
    } elseif {$n < 0} {
        set p [expr {$::deck_length + $n}]
        if {$::keep < $p} {
            set ::keep [expr {$::keep - $n}]
        } else {
            set ::keep [expr {$::keep - $p}]
        }
    }
}

proc solve_part1 {lines} {
    init_deck 10007
    keep 2019
    foreach line $lines {
        eval $line
    }
    return $::keep
}

proc solve_part2 {lines} {

    # 70633553514591 is too high
    init_deck 119315717514047
    set keep_card 2020
    set shuffles 101741582076661

    init_deck 10007
    set keep_card 2019

    keep $keep_card
    for {set t 1} {$t <= $shuffles} {incr t} {
        foreach line $lines {
            eval $line
        }
        puts "$keep_card $::keep"
        if {$::keep == $keep_card} {
            puts "$keep_card repeat at $t"
            break
        }
    }
    return $::keep
}

proc main {} {
    set lines [split [string trim [read stdin]] "\n"]
    set soln1 [solve_part1 $lines]
    puts "The solution to part 1 is $soln1."
    set soln2 [solve_part2 $lines]
    puts "The solution to part2 is $soln2."
}

if {$::argv0 == [info script]} {
    main
}
