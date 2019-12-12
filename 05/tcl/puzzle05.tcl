# Advent of Code 2019 :: Day 5 :: Sunny with a Chance of Asteroids
# https://adventofcode.com/2019/day/5

oo::class create IntcodeComputer {
    variable intcode instruction_pointer

    constructor {intcode0} {
        my variable intcode
        set intcode $intcode0
    }

    method get_value {parameter posn} {
        my variable instruction_pointer intcode
        set p [string index $parameter [expr {2 - $posn + 1}]]
        switch $p {
            0 {
                # Postion mode
                set i [lindex $intcode [expr {$instruction_pointer + $posn}]]
                set v [lindex $intcode $i]
                return $v
            }
            1 {
                # Immediate mode
                return [lindex $intcode [expr {$instruction_pointer + $posn}]]
            }
        }
    }

    method op1 {parameter} {
        my variable instruction_pointer intcode
        set lhs [my get_value $parameter 1]
        set rhs [my get_value $parameter 2]
        set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
        set res [expr {$lhs + $rhs}]
        lset intcode $dest_index $res
        incr instruction_pointer 4
    }

	method op2 {parameter} {
        my variable instruction_pointer intcode
        set lhs [my get_value $parameter 1]
        set rhs [my get_value $parameter 2]
        set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
		set res [expr {$lhs * $rhs}]
		lset intcode $dest_index $res
		incr instruction_pointer 4
	}

    method op3 {parameter} {
        my variable instruction_poiner intcode
        set value [yield]
        set dest_index [lindex $intcode [expr {$instruction_pointer + 1}]]

        lset intcode $dest_index $value
        incr instruction_pointer 2
    }

    # Opcode 4 outputs the value of its only parameter. For example, the
    # instruction 4,50 would output the value at address 50.
    method op4 {parameter} {
        my variable instruction_pointer intcode
        set value [my get_value $parameter 1]
        yield $value
        incr instruction_pointer 2
    }

    
    # Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the
    # instruction pointer to the value from the second parameter. Otherwise, it
    # does nothing.
    method op5  {parameter} {
        my variable instruction_pointer intcode
        set lhs [my get_value $parameter 1]
        if {$lhs != 0} {
            set rhs [my get_value $parameter 2]
            set instruction_pointer $rhs
        } else {
            incr instruction_pointer 3
        }
    }

    # Opcode 6 is jump-if-false: if the first parameter is zero, it sets the
    # instruction pointer to the value from the second parameter. Otherwise, it
    # does nothing.
    method op6 {parameter} {
        my variable instruction_pointer intcode
        set lhs [my get_value $parameter 1]
        if {$lhs == 0} {
            set rhs [my get_value $parameter 2]
            set instruction_pointer $rhs
        } else {
            incr instruction_pointer 3
        }
    }

    # Opcode 7 is less than: if the first parameter is less than the second
    # parameter, it stores 1 in the position given by the third parameter.
    # Otherwise, it stores 0.
    method op7 {parameter} {
        my variable instruction_pointer intcode
        set lhs [my get_value $parameter 1]
        set rhs [my get_value $parameter 2]
        set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
        if {$lhs < $rhs} {
            lset intcode $dest_index 1
        } else {
            lset intcode $dest_index 0
        }
        incr instruction_pointer 4
    }

    # Opcode 8 is equals: if the first parameter is equal to the second
    # parameter, it stores 1 in the position given by the third parameter.
    # Otherwise, it stores 0.
    method op8 {parameter} {
        my variable instruction_pointer intcode
        set lhs [my get_value $parameter 1]
        set rhs [my get_value $parameter 2]
        set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
        if {$lhs == $rhs} {
            lset intcode $dest_index 1
        } else {
            lset intcode $dest_index 0
        }
        incr instruction_pointer 4
    }

	method run {} {
        my variable instruction_pointer intcode
        set instruction_pointer 0
        set token [lindex $intcode $instruction_pointer]
        set opcode [expr {$token % 100}]
        set parameter [format %03d [expr {int($token / 100)}]]
        while {$opcode != 99} {
			my op${opcode} $parameter
            set token [lindex $intcode $instruction_pointer]
            set opcode [expr {$token % 100}]
            set parameter [format %03d [expr {int($token / 100)}]]
		}
	}
}

proc run_computer {intcode} {
    set computer [IntcodeComputer new $intcode]
    $computer run
}

proc solve {intcode init_input} {
    coroutine compute run_computer $intcode
    set soln ""
    while {[llength [info commands compute]] > 0} {
        set output [compute $init_input]
        if {$output != ""} {
            set soln $output
        }
    }
    return $soln
}

if {$::argv0 == [info script]} {
    set input [string trimright [read stdin]]
    set intcode [split $input ","]

    set soln1 [solve $intcode 1]
    puts "The solution to part 1 is $soln1."
    if {$soln1 != 9025675} {error "Solution to part 1 should be 9025675!"}

    set soln2 [solve $intcode 5]
    puts "The solution to part 2 is $soln2."
    if {$soln2 != 11981754} {error "Solution to part 2 should be 11981754!"}
}
