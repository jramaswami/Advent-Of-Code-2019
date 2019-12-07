# Advent of Code 2019 :: Day 2 :: 1202 Program Alarm
# https://adventofcode.com/2019/day/2

# Include Intcode Computer
source "../../lib/tcl/intcode.tcl"

proc set_verb_and_noun {intcode noun verb} {
    lset intcode 1 $noun
    lset intcode 2 $verb
    return $intcode
}

proc solve_part1 {intcode} {
    Intcode::init [set_verb_and_noun $intcode 12 2] {}
    lassign [Intcode::run] intcode0 output
    return [lindex $intcode0 0]
}

proc solve_part2 {intcode} {
    for {set noun 0} {$noun < 100} {incr noun} {
        for {set verb 0} {$verb < 100} {incr verb} {
            Intcode::init [set_verb_and_noun $intcode $noun $verb] {}
            lassign [Intcode::run] intcode0 output
            set result [lindex $intcode0 0]
            if {$result == 19690720} {
                return [expr {100 * $noun + $verb}]
            }
        }
    }
}

if {$::argv0 == [info script]} {
    set input [string trimright [read stdin]]
    set intcode [split $input ","]
    set soln1 [solve_part1 $intcode]
    set soln2 [solve_part2 $intcode]
    puts "The solution to part 1 is $soln1."
    if {$soln1 != 2890696} {error "Solution to part 1 should be 2890696!"}
    puts "The solution to part 2 is $soln2."
    if {$soln2 != 8226} {error "Solution to part 2 should be 8226!"}
}
