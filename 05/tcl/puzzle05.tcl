# Advent of Code 2019 :: Day 5 :: Sunny with a Chance of Asteroids
# https://adventofcode.com/2019/day/5

# Include Intcode Computer
source "../../lib/tcl/intcode.tcl"

if {$::argv0 == [info script]} {
    set input [string trimright [read stdin]]
    set intcode [split $input ","]

    Intcode::init $intcode [list 1]
    lassign [Intcode::run] intcode0 output
    puts "The solution to part 1 is [lindex $output end]."
    if {[lindex $output end] != 9025675} {error "Solution to part 1 should be 9025675!"}

    Intcode::init $intcode [list 5]
    lassign [Intcode::run] intcode0 output
    puts "The solution to part 2 is [lindex $output end]."
    if {[lindex $output end] != 11981754} {error "Solution to part 2 should be 11981754!"}
}
