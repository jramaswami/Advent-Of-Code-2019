# Advent of Code 2019 :: Day 5 :: Sunny with a Chance of Asteroids
# https://adventofcode.com/2019/day/5

# Include Intcode Computer
source "../../lib/tcl/intcode.tcl"

if {$::argv0 == [info script]} {
    puts [string repeat "*" 80]
    puts "For part 1, enter 1 when asked for input."
    puts "The answer will be the last output."
    puts "\tBooting intcode computer ....."
    set filename [lindex $::argv 0]
    puts "\tLoading code from $filename ...."
    set filep [open $filename r]
    set input [string trimright [read $filep]]
    close $filep
    set intcode [split $input ","]
    puts "\tRunning code from $filename ....."
    run_intcode $intcode
    puts "\tDone!"
    puts [string repeat "*" 80]
    puts "For part 2, enter 5 when asked for input."
    puts "The answer will be the last output."
    puts "\tBooting intcode computer ....."
    set filename [lindex $::argv 0]
    puts "\tLoading code from $filename ...."
    set filep [open $filename r]
    set input [string trimright [read $filep]]
    close $filep
    set intcode [split $input ","]
    puts "\tRunning code from $filename ....."
    run_intcode $intcode
    puts "\tDone!"

}
