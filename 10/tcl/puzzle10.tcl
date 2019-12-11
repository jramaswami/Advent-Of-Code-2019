# Advent of Code 2019 :: Day 10 :: Monitoring Station
# https://adventofcode.com/2019/day/10

proc collinear {posn1 posn2 posn3} {
    lassign $posn1 x1 y1
    lassign $posn2 x2 y2
    lassign $posn3 x3 y3

    set slope1 [expr {($y3 - $y2) * ($x2 - $x1)}]
    set slope2 [expr {($y2 - $y1) * ($x3 - $x2)}]
    return [expr {$slope1 == $slope2}]
}

proc distance {posn1 posn2} {
    lassign $posn1 x1 y1
    lassign $posn2 x2 y2
    return [expr {sqrt((($x1 - $x2) * ($x1 - $x2)) + ($y1 - $y2) * ($y1 - $y2))}]
}

proc parse_map {map} {
    set rows [llength $map]
    set cols [string length [lindex $map 0]]

    set asteroids {}
    for {set x 0} {$x < $cols} {incr x} {
        for {set y 0} {$y < $rows} {incr y} {
            set space [string index [lindex $map $y] $x]
            if {$space == "#"} {
                lappend asteroids [list $x -$y]
            }
        }
    }
    return $asteroids
}

proc compare {lhs rhs} {
    if {[lindex $lhs 0] < [lindex $rhs 0]} {
        return 1
    } elseif {[lindex $lhs 0] > [lindex $rhs 0]} {
        return -1
    } else {
        if {[lindex $lhs 1] < [lindex $rhs 1]} {
            return -1
        } elseif {[lindex $lhs 1] > [lindex $rhs 1]} {
            return 1
        }
    }
    return 0
}

proc solve_part1 {asteroids} {
    foreach asteroid $asteroids {
        set hidden($asteroid) {}
    }

    set asteroid_count [llength $asteroids]
    for {set i0 0} {$i0 < $asteroid_count} {incr i0} {
        for {set i1 [expr {$i0 + 1}]} {$i1 < $asteroid_count} {incr i1} {
            for {set i2 [expr {$i1 + 1}]} {$i2 < $asteroid_count} {incr i2} {
                set asteroid0 [lindex $asteroids $i0]
                set asteroid1 [lindex $asteroids $i1]
                set asteroid2 [lindex $asteroids $i2]
                if {[collinear $asteroid0 $asteroid1 $asteroid2]} {
                    set dist1 [distance $asteroid0 $asteroid1]
                    set dist2 [distance $asteroid0 $asteroid2]
                    if {$dist1 > $dist2} {
                        set far $asteroid1
                        set near $asteroid2
                    } else {
                        set far $asteroid2
                        set near $asteroid1
                    }

                    if {[lsearch [set hidden($asteroid0)] $far] < 0} {
                        lappend hidden($asteroid0) $far
                    }

                    if {[lsearch [set hidden($far)] $asteroid0] < 0} {
                        lappend hidden($far) $asteroid0
                    }
                }
            }
        }
    }

    set best_asteroid {}
    set max_visible 0
    foreach asteroid $asteroids {
        set visible [expr {$asteroid_count - [llength [set hidden($asteroid)]] - 1}]
        if {$visible > $max_visible} {
            set max_visible $visible
            set best_asteroid $asteroid
        }
    }

    return [list $best_asteroid $max_visible]
}

proc solve_part2 {asteroids base nth} {

    set up 1.5707963267948966
    lassign $base x_off y_off

    set asteroids0 {}
    foreach asteroid $asteroids {
        # Shift origin 
        lassign $asteroid x y
        set x0 [expr {$x - $x_off}] 
        set y0 [expr {$y - $y_off}]
        if {$x0 == 0 && $y0 == 0} {
            continue
        }

        # Convert to polar coordinates
        set angle [expr { atan2($y0, $x0) }]
        set radius [expr { hypot($y0, $x0) }]
        lappend asteroids0 [list $angle $radius $x0 $y0 $x $y]
    }

    set asteroids0 [lsort -command compare $asteroids0]
    set up_index -1
    for {set i 0} {$i < [llength $asteroids0]} {incr i} {
        set asteroid [lindex $asteroids0 $i]
        if {$up_index < 0 && [lindex $asteroid 0] <= $up} {
            set up_index $i
            break
        }
    }

    set asteroids0 [concat [lrange $asteroids0 $up_index end] [lrange $asteroids0 0 [expr {$up_index - 1}]]]
    
    set asteroids1 {}
    set index 1
    while {[llength $asteroids0] > 0} {
        set prev none
        foreach asteroid $asteroids0 {
            lassign $asteroid angle radius x y
            if {$angle == $prev} {
                # puts "Cannot target $asteroid yet ..."
                lappend asteroids1 $asteroid
            } else {
                # puts "$index Vaporizing $asteroid ..."
                if {$index == $nth} {
                    set lucky $asteroid
                }
                set prev $angle
                incr index
            }
        }
        set asteroids0 $asteroids1
        set asteroids1 {}
    }
    # puts "Should have destroyed [expr [llength $asteroids] - 1] asteroids!"

    lassign $lucky angle radius x0 y0 x y
    return [list $x [expr {-1 * $y}]]

}

if {$::argv0 == [info script]} {
    set input [string trim [read stdin]]
    set map [split $input "\n"]
    set asteroids [parse_map $map]
    set soln1 [solve_part1 $asteroids]
    puts "The solution to part 1 is [lindex $soln1 1]."
    set lucky [solve_part2 $asteroids [lindex $soln1 0] 200]
    set soln2 [expr {(100 * [lindex $lucky 0]) + [lindex $lucky 1]}]
    puts "The solution to part 2 is $soln2."

    if {[lindex $soln1 1] != 276} { error "The solution to part 1 should be 276." }
    if {$soln2 != 1321} { error "The solution to part 1 should be 1321." }
}
