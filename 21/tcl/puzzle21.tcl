# Advent of Code 2019 :: Day 21 :: Springdroid Adventure
# https://adventofcode.com/2019/day/21

package require struct::prioqueue

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
        # set token [lindex $intcode $instruction_pointer]
        set token [my memory_get $instruction_pointer]
        set opcode [expr {$token % 100}]
        set parameter [format %03d [expr {int($token / 100)}]]
        while {$opcode != 99} {
			my op${opcode} $parameter
            # puts $token
            # puts "$opcode $parameter @ $instruction_pointer"
            # set token [lindex $intcode $instruction_pointer]
            set token [my memory_get $instruction_pointer]
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

################################## End Intcode ################################

proc format_command {s} {
    set ascii [lmap c [split $s {}] {scan $c %c}]
    lappend ascii 10
    return $ascii
}

proc read_springscript {filename} {
    set springscript {}
    set soln_file [open $filename r]
    foreach line [split [string trim [read $soln_file]] "\n"] {
        set comment_index [string first ";" $line]
        if {$comment_index >= 0} {
            set line [string trim [string range $line 0 [expr {$comment_index - 1}]]]
        }
        set command $line
        lappend springscript $command
    }
    close $soln_file
    return $springscript
}

proc decode_output {current} {
    # If ascii, convert to char
    if {[string is integer $current] && $current < 128} {
        set current [format %c $current]
    }
    # Otherwise leave it alone
    return $current
}

proc run_to_yield {computer_name current} {
    set output {}
    upvar $computer_name compute
    while {$current != "?" && $current != "halt"} {
        lappend output [decode_output $current]
        set current [compute]
    }
    if {$current == "halt"} {
        return [list 0 $current [join $output ""]]
    }
    return [list 1 $current [join $output ""]]
}

proc run_springscript {intcode springscript {verbose 0}} {
    set ss_pointer 0

    # Run intcode computer until it is ready for input.
    if {$verbose > 1} {puts "Running intcode VM ..."}
    set current [decode_output [coroutine compute run_computer $intcode]]
    lassign [run_to_yield compute $current] ok current output
    while {$ok} {
        if {$verbose > 1} {puts $output}

        # Convert springscript instruction to ascii
        # set command [lindex $all_commands [lindex $springscript $ss_pointer]]
        set command [lindex $springscript $ss_pointer]
        set ascii [format_command $command]
        if {$verbose > 1} {puts "Entering $command as $ascii"}
        incr ss_pointer

        # Input instruction in ascii up to the penultimate code
        for {set i 0} {$i < [expr {[llength $ascii] - 1}]} {incr i} {
            set cmd [lindex $ascii $i]
            set current [compute $cmd]
            lassign [run_to_yield compute $current] ok current output
            if {$verbose > 1} {puts $output}
            if {!$ok} {
                error "Cannot enter entire command $command."
            }
        }
        # Enter the last ascii code of command and read the output
        set cmd [lindex $ascii end]
        set current [compute $cmd]
        # puts "Command complete"
        lassign [run_to_yield compute $current] ok current output
        if {!$ok} {
            if {[string first "Didn't make it across" $output] >= 0} {
                if {$verbose > 0} {puts $output}
                return -1
            } else {
                return [lindex [split $output "\n"] end]
            }
        }
        # puts $output
    }
}

proc solve_part1 {intcode} {
    set ss {{OR A T} {AND B T} {AND C T} {NOT T J} {AND D J} {WALK}}
    return [run_springscript $intcode $ss 0]
}

proc solve_part2 {intcode} {
    set ss {{OR A J} {AND B J} {AND C J} {NOT J J} {AND D J} {OR E T} {OR H T} {AND T J} {RUN}}
    return [run_springscript $intcode $ss 0]
}

proc main {} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]
    set soln1 [solve_part1 $intcode]
    puts "The solution to part 1 is $soln1."
    if {$soln1 != 19355364} {error "The solution to part 1 should be 19355364."}
    set soln2 [solve_part2 $intcode]
    puts "The solution to part 2 is $soln2."
}

if {$::argv0 == [info script]} {
    main
}
