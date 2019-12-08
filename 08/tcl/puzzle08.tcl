# Advent of Code 2019 :: Day 8 :: Space Image Format
# https://adventofcode.com/2019/day/8

# Returns a 3d matrix of layers-rows-cols
proc parse_layers {input} {
    set i 0
    set layers {}
    while {$i < [string length $input]} {
        set layer {}
        for {set row 0} {$row < 6} {incr row} {
            set row_data {}
            for {set col 0} {$col < 25} {incr col} {
                set c [string index $input $i]
                lappend row_data $c
                incr i
            }
            lappend layer $row_data
        }
        lappend layers $layer
    }
    return $layers
}

proc solve_part2 {layers} {
    set msg {}
    for {set row 0} {$row < 6} {incr row} {
        set row_data {}
        for {set col 0} {$col < 25} {incr col} {
            set pixel 2
            for {set layer 0} {$layer < 100} {incr layer} {
                set p [lindex [lindex [lindex $layers $layer] $row] $col]
                if {$p < $pixel} {
                    set pixel $p
                    break
                }
            }
            if {$pixel == 0} {
                lappend row_data " "
            } else {
                lappend row_data "#"
            }
        }
        lappend msg $row_data
    }

    foreach row $msg {
        puts "[join $row {}]"
    }
}

proc solve_part1 {layers} {
    set soln 0
    set min_zeros 999999999
    foreach layer $layers {
        set zeros 0
        set ones 0
        set twos 0
        foreach row $layer {
            foreach c $row {
                switch $c {
                    1 { incr ones }
                    2 { incr twos }
                    0 { incr zeros }
                }
            }
        }

        if {$zeros < $min_zeros} {
            set min_zeros $zeros
            set soln [expr {$ones * $twos}]
        }
    }
    return $soln
}

if {$::argv0 == [info script]} {
    set input [string trim [read stdin]]
    set layers [parse_layers $input]
    puts "The solution to part 1 is [solve_part1 $layers]."
    puts "The solution to part 2 is:"
    solve_part2 $layers
}
