# Advent of Code 2019 :: Day 5 :: Sunny with a Chance of Asteroids
# https://adventofcode.com/2019/day/5

# Include Intcode Computer
source "../../lib/tcl/intcode.tcl"

if {$::argv0 == [info script]} {
    puts "\tBooting ....."
    set filename [lindex $::argv 0]
    puts "\tLoading code ...."
    set filep [open $filename r]
    set input [string trimright [read $filep]]
    close $filep
    set intcode [split $input ","]
    puts "\tRunning ....."
    run_intcode $intcode
    puts "\tDone!"
}
