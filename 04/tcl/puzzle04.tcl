# Advent of Code 2019 :: Day 4 :: Secure Container
# https://adventofcode.com/2019/day/4

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

# Brute force method
proc solve {{min_passcode 111111} {max_passcode 999999} {part2 0}} {
    set soln 0
    for {set passcode $min_passcode} {$passcode <= $max_passcode} {incr passcode} {
        if {[valid_passcode $passcode $part2]} {
            incr soln
        }
    }
    return $soln
}

if {$::argv0 == [info script]} {
    set min_passcode 206938
    set max_passcode 679128
    puts "The solution to part 1 is [solve $min_passcode $max_passcode]."
    puts "The solution to part 2 is [solve $min_passcode $max_passcode 1]."
}
