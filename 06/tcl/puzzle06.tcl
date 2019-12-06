# Advent of Code 2019 :: Day 6 :: Universal Orbit Map
# https://adventofcode.com/2019/day/6

proc solve1 {orbits} {
    # Build Graph
    foreach orbit $orbits {
        set tokens [split $orbit ")"]
        set orbitee [lindex $tokens 0]
        set orbiter [lindex $tokens 1]
        lappend $orbitee $orbiter
    }

    # Solve Part 1
    set csum 0
    set queue $COM
    set new_queue {}
    set level 1
    while {[llength $queue] > 0} {
        foreach planet $queue {
            incr csum $level
            # Add satellites to new queue.
            if {[info exists $planet]} {
                foreach orbiter [set $planet] {
                    lappend new_queue $orbiter
                }
            }
        }
        set queue $new_queue
        set new_queue {}
        incr level
    }
    return $csum
}

proc solve2 {orbits} {
    # Build Graph
    foreach orbit $orbits {
        set tokens [split $orbit ")"]
        set orbitee [lindex $tokens 0]
        set orbiter [lindex $tokens 1]
        lappend $orbiter $orbitee
        lappend $orbitee $orbiter
    }

    set tfrs 0
    set queue $YOU
    set new_queue {}
    lappend visited YOU
    while {[llength $queue] > 0} {
        foreach planet $queue {
            if {[string equal $planet "SAN"]} {
                return [expr {$tfrs - 1}]
            }
            # Add satellites to new queue.
            if {[info exists $planet]} {
                foreach orbiter [set $planet] {
                    if {[lsearch $visited $orbiter] >= 0} {
                        continue
                    }
                    lappend visited $orbiter
                    lappend new_queue $orbiter
                }
            }
        }
        set queue $new_queue
        set new_queue {}
        incr tfrs
    }
}

if {$::argv0 == [info script]} {
    set input [string trimright [read stdin]]
    set orbits [split $input "\n"]
    puts "The answer to part 1 is [solve1 $orbits]."
    puts "The answer to part 2 is [solve2 $orbits]."
}
