# Advent of Code 2019 :: Day 21 :: Slam Shuffle
# https://adventofcode.com/2019/day/22

# From Rosetta Code
proc gcdExt {a b} {
    if {$b == 0} {
	return [list 1 0 $a]
    }
    set q [expr {$a / $b}]
    set r [expr {$a % $b}]
    lassign [gcdExt $b $r] s t g
    return [list $t [expr {$s - $q*$t}] $g]
}

proc modInv {a m} {
    lassign [gcdExt $a $m] i -> g
    if {$g != 1} {
	return -code error "no inverse exists of $a %! $m"
    }
    while {$i < 0} {incr i $m}
    return $i
}


proc deal {a b c deck_length_var keep_var {reverse 0}} {
    upvar $deck_length_var deck_length
    upvar $keep_var keep
    if {$a == "with"} {
        # Deal with increment
        if {$reverse} {
            set s [expr {[modInv $c $deck_length]}]
            set keep [expr {($keep * $s) % $deck_length}]
        } else {
            # increment * index (mod deck length)
            set keep [expr {($keep * $c)}]
        }
    } elseif {$a == "into"} {
        # Deal into new stack
        # deck length - 1 - index (mod deck length)
        set keep [expr {$deck_length - $keep - 1}]
    }
}

proc cut {n deck_length_var keep_var {reverse 0}} {
    upvar $deck_length_var deck_length
    upvar $keep_var keep
    if {$reverse} {
        set n [expr {-1 * $n}]
    } else {
        # index - n (mod deck length)
        set keep [expr {$keep - $n}]
    }
}


proc solve_part1 {lines} {
    set deck_length 10007
    set keep 2019
    foreach line $lines {
        set line [concat $line {deck_length keep}]
        eval $line
    }
    return [expr {$keep % $deck_length}]
}

proc verify_reversal {lines} {
    set start 2020
    set keep $start
    set ticks 2
    for {set t 0} {$t < $ticks} {incr t} {
        set deck_length 10007
        for {set limit 1} {$limit < [llength $lines]} {incr limit} {
            for {set i 0} {$i < $limit} {incr i} {
                set line [lindex $lines $i]
                set line [concat $line {deck_length keep}]
                # puts $line
                eval $line
            }
        }
        puts "********* 2019 is @ $keep"
    }

    set deck_length 10007
    set addr $keep
    for {set t 0} {$t < $ticks} {incr t} {
        for {set i [expr {$limit - 1}]} {$i >= 0} {incr i -1} {
            set line [lindex $lines $i]
            set line [concat $line {deck_length keep 1}]
            # puts $line
            eval $line
        }
        puts "********* $addr holds $keep"
        set addr $keep
    }
    puts "$start $keep"
    if {$start != $keep} {
        puts "OUCH"
        break
    }
}

proc solve_part2 {lines} {

    # 70633553514591 is too high
    # init_deck 119315717514047
    # set shuffles 101741582076661


    set deck_length 10007
    set keep 2019
    for {set i 0} {$i < 100} {incr i} {
        foreach line $lines {
            set line [concat $line {deck_length keep}]
            eval $line
        }
        puts "$keep"
    }
    return $keep
}

proc main {} {
    set lines [split [string trim [read stdin]] "\n"]
    set soln1 [solve_part1 $lines]
    puts "The solution to part 1 is $soln1."
    # verify_reversal $lines
    # set soln2 [solve_part2 $lines]
    # puts "The solution to part2 is $soln2."
}

if {$::argv0 == [info script]} {
    main
}
