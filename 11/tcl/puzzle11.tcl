# Advent of Code 2019 :: Day 11 :: Space Police
# https://adventofcode.com/2019/day/11

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
        set value [yield]
        set dest_index [my get_dest_index $parameter 1]
        my memory_set $dest_index $value
        incr instruction_pointer 2
    }

    # Opcode 4 outputs the value of its only parameter. For example, the
    # instruction 4,50 would output the value at address 50.
    method op4 {parameter} {
        my variable instruction_pointer
        set value [my get_value $parameter 1]
        set ignore [yield $value]
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
	}
}

proc run_computer {intcode} {
    set computer [IntcodeComputer new $intcode]
    $computer run
}

# Returns new direction based on current direction and turn
proc turn_left {dirn} {
    switch $dirn {
        U { return L }
        L { return D }
        D { return R }
        R { return U }
    }
}

# Returns new direction based on current direction and turn
proc turn_right {dirn} {
    switch $dirn {
        U { return R }
        L { return U }
        D { return L }
        R { return D }
    }
}

# Returns new position, given previous position and direction
proc move {dirn posn} {
    lassign $posn x y
    switch $dirn {
        U { return [list $x [expr {$y + 1}]] }
        L { return [list [expr {$x - 1}] $y] }
        D { return [list $x [expr {$y - 1}]] }
        R { return [list [expr {$x + 1}] $y] }
    }
}

proc turn_robot {dirn code} {
    if {$code == 0} {
        return [turn_left $dirn]
    } else {
        return [turn_right $dirn]
    }
}

proc get_panel_color {posn} {
    if [info exists ::panels($posn)] {
        return [set ::panels($posn)]
    } else {
        set ::panels($posn) 0
        return 0
    }
}

proc paint_panel {posn paint_color} {
    set ::panels($posn) $paint_color
    if {[lsearch $::painted_panels $posn] < 0} {
        lappend ::painted_panels $posn
    }
}

proc solve {intcode {part_2 0}} {
    # Init panel memory
    set ::painted_panels {}
    array unset ::panels

    set posn [list 0 0]
    if {$part_2} {
        set ::panels($posn) 1
    }
    set dirn U

    # Start computer, which will run until it needs input.
    coroutine computer run_computer $intcode
    while {[llength [info commands computer]] > 0} {
        # Give panel color as input and get paint color as output.
        set current_panel_color [get_panel_color $posn]
        set paint_color [computer $current_panel_color]

        # Run computer again until it gives the turn code as output.
        set turn_code [computer]

        # Then run the computer again until it needs input.
        computer

        # Paint panel
        paint_panel $posn $paint_color
        # Turn robot
        set dirn [turn_robot $dirn $turn_code]
        # Move robot
        set posn [move $dirn $posn]
    }
        
    if {$part_2} {
        set min_x 999999
        set min_y 999999
        set max_x -999999
        set max_y -999999
        foreach panel $::painted_panels {
            lassign $panel x y
            set min_x [::tcl::mathfunc::min $min_x $x]
            set min_y [::tcl::mathfunc::min $min_y $y]
            set max_x [::tcl::mathfunc::max $max_x $x]
            set max_y [::tcl::mathfunc::max $max_y $y]
        }

        set reg_id {}
        for {set y $max_y} {$y >= $min_y} {incr y -1} {
            set row_data {}
            for {set x $min_x} {$x <= $max_x} {incr x 1} {
                set posn [list $x $y]
                set color [get_panel_color $posn]
                if {$color} {
                    lappend row_data "#"
                } else {
                    lappend row_data " "
                }
            }
            lappend reg_id [join $row_data {}]
        }
        return $reg_id
    } else {
        return [llength $::painted_panels]
    }
}

if {$::argv0 == [info script]} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]
    set ::painted_panels {}
    set soln1 [solve $intcode]
    puts "The solution to part 1 is $soln1."
    if { $soln1 != 2093 } { error "The solution to part 1 should be 2093." }
    puts "The solution to part 2 is BJRKLJUP:"
    puts [join [solve $intcode 1] "\n"]
}
