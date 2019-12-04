# Advent of Code 2019 :: Day 4 :: Secure Container
# https://adventofcode.com/2019/day/4

#################################################################
# 
# Solution method 1: brute force
# Takes about 5 seconds to get both solutions.
#
#################################################################
package require struct::stack

proc valid_passcode {passcode {part2 0}} {
    set passcode0 [split $passcode {}]
    set search_limit [expr {[llength $passcode0] - 1}]
    set st [::struct::stack]
    $st push [list [lindex $passcode0 0] 1]
    for {set i 0} {$i < $search_limit} {incr i} {
        set a [lindex $passcode0 $i]
        set b [lindex $passcode0 [expr {$i + 1}]]
        if {$b < $a} {
            return 0
        }
        if {$a == $b} {
            set item [$st pop]
            set freq [lindex $item 1]
            $st push [list $b [expr {$freq + 1}]]
        } else {
            $st push [list $b 1]
        }
    }

    set ok 0
    foreach item [$st get] {
        set freq [lindex $item 1]
        if {$part2} {
            if {$freq == 2} {
                set ok 1
            }
        } elseif {$freq >= 2} {
            set ok 1
        }
    }
    return $ok
}

proc solve {{min_passcode 111111} {max_passcode 999999} {part2 0}} {
    set soln 0
    for {set passcode $min_passcode} {$passcode <= $max_passcode} {incr passcode} {
        if {[valid_passcode $passcode $part2]} {
            incr soln
        }
    }
    return $soln
}

#################################################################
#
# Solution method 2: build valid passcodes and count them.
# This is much faster, takes less than 1 second to get both
# solutions.
#
#################################################################
proc solve_part1 {{min_passcode 111111} {max_passcode 999999}} {
    set soln 0
    set min_start [expr {$min_passcode / 100000}]
    set max_start [expr {$max_passcode / 100000}]
    set queue {}
    for {set n $min_start} {$n <= $max_start} {incr n} {
        lappend queue [list $n 0]
    }

    set new_queue {}
    while {[llength $queue] > 0} {
        foreach item $queue {
            set passcode [lindex $item 0]
            set pair_found [lindex $item 1]
            if {[expr {$passcode >= $min_passcode && $passcode <= $max_passcode && $pair_found}]} {
                incr soln
            } else {
                set lastdigit [expr {$passcode % 10}]
                for {set p $lastdigit} {$p < 10} {incr p} {
                    set passcode0 [expr {(10 * $passcode) + $p}]
                    if {$passcode0 <= $max_passcode} {
                        set pair_found0 [expr {$pair_found || ($p == $lastdigit)}]
                        lappend new_queue [list $passcode0 $pair_found0]
                    }
                }
            }
        }
        set queue $new_queue
        set new_queue {}
    }
    return $soln
}

proc solve_part2 {{min_passcode 111111} {max_passcode 999999}} {
    set soln 0
    set min_start [expr {$min_passcode / 100000}]
    set max_start [expr {$max_passcode / 100000}]
    set queue {}
    for {set n $min_start} {$n <= $max_start} {incr n} {
        lappend queue [list $n 1 0]
    }

    set new_queue {}
    while {[llength $queue] > 0} {
        foreach item $queue {
            set passcode [lindex $item 0]
            set current_run [lindex $item 1]
            set pair_found [lindex $item 2]
            if {[expr {$passcode >= $min_passcode && $passcode <= $max_passcode && ($pair_found || ($current_run == 2))}]} {
                incr soln
            } else {
                set lastdigit [expr {$passcode % 10}]
                for {set p $lastdigit} {$p < 10} {incr p} {
                    set passcode0 [expr {(10 * $passcode) + $p}]
                    if {$passcode0 <= $max_passcode} {
                        if {$p == $lastdigit} {
                            set pair_found0 $pair_found
                            set current_run0 [expr {$current_run + 1}]
                        } else {
                            if {$current_run == 2} { 
                                set pair_found0 1
                            } else {
                                set pair_found0 $pair_found
                            }
                            set current_run0 1
                        }
                        lappend new_queue [list $passcode0 $current_run0 $pair_found0]
                    }
                }
            }
        }
        set queue $new_queue
        set new_queue {}
    }
    return $soln
}

#################################################################
#
# Main
#
#################################################################
if {$::argv0 == [info script]} {
    set min_passcode 206938
    set max_passcode 679128
    # puts "The solution to part 1 is [solve $min_passcode $max_passcode]."
    # puts "The solution to part 2 is [solve $min_passcode $max_passcode 1]."
    puts "The solution to part 1 is [solve_part1 $min_passcode $max_passcode]."
    puts "The solution to part 2 is [solve_part2 $min_passcode $max_passcode]."
}
