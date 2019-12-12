# Advent of Code 2019 :: Day 7 :: Amplification Circuit
# https://adventofcode.com/2019/day/7

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

proc next_permutation {lst} {
    # Find the largest index k such that a[k] < a[k + 1]. 
    # If no such index exists, the permutation is the last permutation.
    set list_length [llength $lst]
    set search_limit [expr {$list_length - 1}]
    set k -1
    set i 0
    for {set i 0} {$i < $search_limit} {incr i} {
        set a [lindex $lst $i]
        set b [lindex $lst [expr {$i+1}]]
        if {[string compare $a $b] < 0} {
            set k $i
        }
    }

    if {$k == -1} {
        return {}
    }

    # Find the largest index l greater than k such that a[k] < a[l].
    set ak [lindex $lst $k]
    set l -1
    for {set i [expr {$k+1}]} {$i < $list_length} {incr i} {
        set al [lindex $lst $i]
        if {[string compare $ak $al] < 0} {
            set l $i
        }
    }

    # Swap the value of a[k] with that of a[l].
    set t [lindex $lst $k]
    lset lst $k [lindex $lst $l]
    lset lst $l $t

    # Reverse the sequence from a[k + 1] up to and including the 
    # final element a[n].
    set lst0 [lrange $lst 0 $k]
    set tail [lreverse [lrange $lst [expr {$k+1}] end]]
    lappend lst0 {*}$tail
    return $lst0
}

proc solve_part1 {intcode} {
    set phase_settings [list 0 1 2 3 4]
    set max_output_signal 0
    while {$phase_settings != {}} {
        set input_signal 0
        coroutine computerA run_computer $intcode
        coroutine computerB run_computer $intcode
        coroutine computerC run_computer $intcode
        coroutine computerD run_computer $intcode
        coroutine computerE run_computer $intcode
        set computers [list A B C D E]
        set output_signal 0
        for {set i 0} {$i < 5} {incr i} {
            set phase_setting [lindex $phase_settings $i]
            set id [lindex $computers $i]
            computer${id} $phase_setting
            set output_signal [computer${id} $output_signal]
        }
        set max_output_signal [::tcl::mathfunc::max $max_output_signal $output_signal]
        set phase_settings [next_permutation $phase_settings]
    }
    return $max_output_signal
}

proc solve_part2 {intcode} {
    set phase_settings [list 5 6 7 8 9]
    set max_output_signal 0
    while {$phase_settings != {}} {
        set input_signal 0
        coroutine computerA run_computer $intcode
        coroutine computerB run_computer $intcode
        coroutine computerC run_computer $intcode
        coroutine computerD run_computer $intcode
        coroutine computerE run_computer $intcode
        set computers [list A B C D E]
        set output_signal 0
        set ok 1
        while {$ok} {
            for {set i 0} {$i < 5} {incr i} {
                set phase_setting [lindex $phase_settings $i]
                set id [lindex $computers $i]
                computer${id} $phase_setting
                if {[llength [info commands computer${id}]] == 0} {
                    set ok 0
                    break
                }
                set output [computer${id} $output_signal]
                if {$output != ""} {
                    set output_signal $output
                }
            }
        }
        set max_output_signal [::tcl::mathfunc::max $max_output_signal $output_signal]
        set phase_settings [next_permutation $phase_settings]
    }
    return $max_output_signal
}

if {$::argv0 == [info script]} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]
    set soln1 [solve_part1 $intcode]
    puts "The solution to part 1 is $soln1."
    set soln2 [solve_part2 $intcode]
    puts "The solution to part 2 is $soln2."
    if {$soln1 != 18812} {error "Solution to part 1 should be 18812."}
    if {$soln2 != 25534964} {error "Solution to part 2 should be 25534964."}
}
