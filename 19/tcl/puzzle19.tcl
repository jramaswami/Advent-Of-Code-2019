# Advent of Code 2019 :: Day 19 :: Tractor Beam
# https://adventofcode.com/2019/day/19

oo::class create IntcodeComputer {
    variable intcode instruction_pointer memory relative_base

    constructor {intcode0} {
        my variable intcode memory relative_base
        set intcode $intcode0
        set memory [dict create]
        for {set i 0} {$i < [llength $intcode0]} {incr i} {
            my memory_set $i [lindex $intcode0 $i]
        }
        set relative_base 0
    }

    method memory_get {addr} {
        my variable memory
        if {![dict exists $memory $addr]} {
            my memory_set $addr 0
        }
        return [dict get $memory $addr]
    }

    method memory_set {addr val} {
        my variable memory
        dict set memory $addr $val
    }

    method get_value {parameter posn} {
        my variable instruction_pointer intcode relative_base
        set p [string index $parameter [expr {2 - $posn + 1}]]
        switch $p {
            0 {
                # Postion mode
                set i [my memory_get [expr {$instruction_pointer + $posn}]]
                set v [my memory_get $i]
                return $v
            }
            1 {
                # Immediate mode
                return [my memory_get [expr {$instruction_pointer + $posn}]]
            }
            2 {
                # Relative mode
                set i [my memory_get [expr {$instruction_pointer + $posn}]]
                set v [my memory_get [expr {$i + $relative_base}]]
                return $v
            }
            default {
                set s "Invalid parameter $parameter: $p -- [my memory_get $instruction_pointer] @ $instruction_pointer"
                error $s
            }
        }
    }

    method get_dest_index {parameter posn} {
        my variable instruction_pointer relative_base
        set p [string index $parameter [expr {2 - $posn + 1}]]
        switch $p {
            0 {
                # Position mode
                set i [my memory_get [expr {$instruction_pointer + $posn}]]
                return $i
            }
            1 {
                error "Write parameter should never be in immediate mode."
            }
            2 {
                # Relative mode
                set i [my memory_get [expr {$instruction_pointer + $posn}]]
                return [expr {$i + $relative_base}]
            }
            default {
                error "Invalid parameter $parameter"
            }
        }
    }

    method op1 {parameter} {
        my variable instruction_pointer
        set lhs [my get_value $parameter 1]
        set rhs [my get_value $parameter 2]
        set dest_index [my get_dest_index $parameter 3]
        set res [expr {$lhs + $rhs}]
        my memory_set $dest_index $res
        incr instruction_pointer 4
    }

	method op2 {parameter} {
        my variable instruction_pointer
        set lhs [my get_value $parameter 1]
        set rhs [my get_value $parameter 2]
        set dest_index [my get_dest_index $parameter 3]
		set res [expr {$lhs * $rhs}]
		my memory_set $dest_index $res
		incr instruction_pointer 4
	}

    method op3 {parameter} {
        my variable instruction_poiner intcode
        set value [yield ?]
        set dest_index [my get_dest_index $parameter 1]
        my memory_set $dest_index $value
        incr instruction_pointer 2
    }

    # Opcode 4 outputs the value of its only parameter. For example, the
    # instruction 4,50 would output the value at address 50.
    method op4 {parameter} {
        my variable instruction_pointer
        set value [my get_value $parameter 1]
        yield $value
        incr instruction_pointer 2
    }
    
    # Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the
    # instruction pointer to the value from the second parameter. Otherwise, it
    # does nothing.
    method op5  {parameter} {
        my variable instruction_pointer
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
        my variable instruction_pointer
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
        my variable instruction_pointer
        set lhs [my get_value $parameter 1]
        set rhs [my get_value $parameter 2]
        set dest_index [my get_dest_index $parameter 3]
        if {$lhs < $rhs} {
            my memory_set $dest_index 1
        } else {
            my memory_set $dest_index 0
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
        set dest_index [my get_dest_index $parameter 3]
        if {$lhs == $rhs} {
            my memory_set $dest_index 1
        } else {
            my memory_set $dest_index 0
        }
        incr instruction_pointer 4
    }

    # Opcode 9 adjusts the relative base by the value of its only parameter.
    # The relative base increases (or decreases, if the value is negative) by
    # the value of the parameter.
    method op9 {parameter} {
        my variable instruction_pointer relative_base
        set i [my get_value $parameter 1]
        incr relative_base $i
        incr instruction_pointer 2
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
        return "halt"
	}
}

# Procedure for producing coroutine
proc run_computer {intcode} {
    set computer [IntcodeComputer new $intcode]
    $computer run
}

proc get_drone_status {intcode x y} {
    set status 0
    # Run intcode computer until it is ready for input.
    set c [coroutine compute run_computer $intcode]
    while {$c != "?"} {
        set c [compute]
    }
    # Input x coordinate
    set c [compute $x]
    # Run until input needed
    while {$c != "?"} {
        set c [compute]
    }
    # Input y coordinate and get result
    set c [compute $y]
    if {$c == 1} {
        set status 1
    }
    # Run until input halted
    while {$c != "halt"} {
        set c [compute]
    }
    return $status
}

proc solve_part1 {intcode} {
    set pulled_count 0
    set x_start 0
    for {set y 0} {$y < 50} {incr y} {
        set flag 0
        for {set x $x_start} {$x < 50} {incr x} {
            set status [get_drone_status $intcode $x $y]
            if {$status} {
                incr pulled_count
                if {!$flag} {
                    set flag $x
                }
            } else {
                if {$flag > 0} {
                    break
                }
            }
            set x_start $flag
        }
    }
    return $pulled_count
}

proc check_corners {intcode x y} {
    set x1 [expr {$x + 100}]
    set y1 [expr {$y + 100}]
    # Check bottom left
    if {[get_drone_status $intcode $x $y1] == 0} {
        return 0
    }
    # Check top right
    if {[get_drone_status $intcode $x1 $y] == 0} {
        return 0
    }
    return 1
}

proc dist {x y} {
    return [expr {sqrt(($x * $x) + ($y * $y))}]
}

proc solve_part2 {intcode} {
    # 9340756 is too high
    # 9310753 is too high
    set min_dist 999999
    set min_x 0
    set min_y 0
    set x_start 0
    # Previous runs show that the anwer is north of 740 ...
    for {set y 740} {$y < 800} {incr y} {
        set flag 0
        set width 0
        for {set x 0} {$x < 10000} {incr x} {
            set status [get_drone_status $intcode $x $y]
            if {$status} {
                if {!$flag} {
                    set flag $x
                }

                # Check corners
                set x1 [expr {$x + 99}]
                set y1 [expr {$y + 99}]
                # Check bottom left
                if {[get_drone_status $intcode $x $y1] == 0} {
                    continue
                }
                # Check top right
                if {[get_drone_status $intcode $x1 $y] == 0} {
                    continue
                }
                lassign [closest_point_in_square $x $y] sq_d sq_x sq_y
                return [expr {(10000 * $sq_x) + $sq_y}]
            } else {
                if {$flag > 0} {
                    break
                }
            }
            set x_start $flag
        }
    }
    return [list $min_x $min_y]
}

proc closest_point_in_square {x0 y0} {
    set min_dist 9999999
    set min_x 0
    set min_y 0
    for {set y_off 0} {$y_off < 100} {incr y_off} {
        for {set x_off 0} {$x_off < 100} {incr x_off} {
            set x [expr {$x0 + $x_off}]
            set y [expr {$y0 + $y_off}]
            set d [dist $x $y]
            if {$d < $min_dist} {
                set min_dist $d
                set min_x $x
                set min_y $y
            }
        }
    }
    return [list $min_dist $min_x $min_y]
}

proc main {} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]
    set soln1 [solve_part1 $intcode]
    puts "The solution to part 1 is $soln1."
    if {$soln1 != 231} {error "The solution to part 1 should be 231."}
    set soln2 [solve_part2 $intcode]
    puts "The solution to part 2 is $soln2."
    if {$soln2 != 9210745} {error "The solution to part 2 should be 9210745."}
}

if {$::argv0 == [info script]} {
    main
}
