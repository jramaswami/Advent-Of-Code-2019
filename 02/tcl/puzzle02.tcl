# Advent of Code 2019 :: Day 2 :: 1202 Program Alarm
# https://adventofcode.com/2019/day/2

oo::class create IntcodeComputer {
    variable intcode instruction_pointer

    constructor {intcode0} {
        my variable intcode
        set intcode $intcode0
    }

    method op1 {instruction_pointer_var intcode_var} {
        my variable instruction_pointer intcode

        set lhs_index [lindex $intcode [expr {$instruction_pointer + 1}]]
        set rhs_index [lindex $intcode [expr {$instruction_pointer + 2}]]
        set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]

        set lhs [lindex $intcode $lhs_index]
        set rhs [lindex $intcode $rhs_index]
        set res [expr {$lhs + $rhs}]
        lset intcode $dest_index $res

        incr instruction_pointer 4
    }

	method op2 {instruction_pointer_var intcode_var} {
        my variable instruction_pointer intcode

		set lhs_index [lindex $intcode [expr {$instruction_pointer + 1}]]
		set rhs_index [lindex $intcode [expr {$instruction_pointer + 2}]]
		set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]

		set lhs [lindex $intcode $lhs_index]
		set rhs [lindex $intcode $rhs_index]
		set res [expr {$lhs * $rhs}]
		lset intcode $dest_index $res

		incr instruction_pointer 4
	}

	method run {noun verb} {
        my variable instruction_pointer intcode
        set instruction_pointer 0

		lset intcode 1 $noun
		lset intcode 2 $verb

        set opcode [lindex $intcode $instruction_pointer]
        while {$opcode != 99} {
			my op${opcode} instruction_pointer intcode
            set opcode [lindex $intcode $instruction_pointer]
		}
        return [lindex $intcode 0]
	}

}

proc solve_part1 {intcode} {
    set computer [IntcodeComputer new $intcode]
    return [$computer run 12 2]
}

proc solve_part2 {intcode} {
    for {set noun 0} {$noun < 100} {incr noun} {
        for {set verb 0} {$verb < 100} {incr verb} {
            set computer [IntcodeComputer new $intcode]
            set result [$computer run $noun $verb]
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
