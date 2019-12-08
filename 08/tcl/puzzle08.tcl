# Advent of Code 2019 :: Day 8 :: Space Image Format
# https://adventofcode.com/2019/day/8

if {$::argv0 == [info script]} {
    set input [string trim [read stdin]]
    puts "Input is [string length $input] long."
    set i 0
    set layer 0
    while {$i < [string length $input]} {
        for {set row 0} {$row < 6} {incr row} {
            set row_data {}
            for {set col 0} {$col < 25} {incr col} {
                set c [string index $input $i]
                lappend row_data $c
                switch $c {
                    1 { incr layer${layer}(1) }
                    2 { incr layer${layer}(2) }
                    0 { incr layer${layer}(0) }
                }
                incr i
            }
            lappend layer${layer}(data) $row_data
        }
        incr layer
    }

    set soln 0
    set min_zeros 999999999
    for {set l 0} {$l < $layer} {incr l} {
        # puts "layer $l: [set layer${l}(data)]"
        if {[set layer${l}(0)] < $min_zeros} {
            puts "layer $l has [set layer${l}(0)] which is more than $min_zeros."
            set min_zeros [set layer${l}(0)]
            set soln [expr {[set layer${l}(1)] * [set layer${l}(2)]}]
            puts "[set layer${l}(1)] * [set layer${l}(2)] is $soln."
        }
        puts "$l 0:[set layer${l}(0)] 1:[set layer${l}(1)] 2:[set layer${l}(2)]."
    }
    puts "The solution to part 1 is $soln."
}
