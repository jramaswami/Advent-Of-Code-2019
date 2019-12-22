# Advent of Code 2019 :: Day 21 :: Slam Shuffle
# https://adventofcode.com/2019/day/22

package require struct::list

proc init_deck {n} {
    set ::deck [::struct::list iota $n]
}

# From https://wiki.tcl-lang.org/page/lrotate (lrotate6)
proc lrotate {xs {n 1}} {
    if {$n == 0 || [llength $xs] == 0 } {return $xs}
    set n [expr {$n % [llength $xs]}]
    return [concat [lrange $xs $n end] [lrange $xs 0 [expr {$n-1}]]]
}

proc deal {a b c} {
    if {$a == "with"} {
        set index 0
        set limit [llength $::deck]
        set new_deck [lrepeat $limit x]
        for {set card 0} {$card < $limit} {incr card} {
            set card_value [lindex $::deck $card]
            lset new_deck $index $card_value
            set index [expr {($index + $c) % $limit}]
        }
        set ::deck $new_deck
    } elseif {$a == "into"} {
        set ::deck [lreverse $::deck]
    }
}

proc cut {n} {
    set ::deck [lrotate $::deck $n]
}

proc Result: {args} {
    if {$::deck != $args} {
        error "$::deck != $args"
    } else {
        puts "* ok!"
    }
}

proc solve {lines} {
    foreach line $lines {
        puts $line
        eval $line
    }
    return [lsearch $::deck 2019]
}

proc main {} {
    set lines [split [string trim [read stdin]] "\n"]
    set soln1 [solve $lines]
    puts "The solution to part 1 is $soln1."
}

if {$::argv0 == [info script]} {
    main
}
