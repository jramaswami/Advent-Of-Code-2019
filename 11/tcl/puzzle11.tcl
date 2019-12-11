# Advent of Code 2019 :: Day 11 :: Space Police
# https://adventofcode.com/2019/day/11

proc memory_get {addr} {
    if {![info exists ::mnemosyne($addr)]} {
        memory_set $addr 0
    }
    return [set ::mnemosyne($addr)]
}

proc memory_set {addr val} {
    set ::mnemosyne($addr) $val
}

proc get_value {parameter posn} {
    set p [string index $parameter [expr {2 - $posn + 1}]]
    if {$p == 0} {
        # Position mode
        set i [memory_get [expr {$::instruction_pointer + $posn}]]
        set v [memory_get $i]
        return $v
    } elseif {$p == 1} {
        # Immediate mode
        return [memory_get [expr {$::instruction_pointer + $posn}]]
    } elseif {$p == 2} {
        # Relative mode
        set i [memory_get [expr {$::instruction_pointer + $posn}]]
        set v [memory_get [expr {$i + $::relative_base}]]
    } else {
        error "Invalid parameter $parameter"
    }
}

proc get_dest_index {parameter posn} {
    set p [string index $parameter [expr {2 - $posn + 1}]]
    if {$p == 0} {
        # Position mode
        set i [memory_get [expr {$::instruction_pointer + $posn}]]
        return $i
    } elseif {$p == 1} {
        # Immediate mode
        error "Write parameter should never be in immediate mode."
    } elseif {$p == 2} {
        # Relative mode
        set i [memory_get [expr {$::instruction_pointer + $posn}]]
        return [expr {$i + $::relative_base}]
    } else {
        error "Invalid parameter $parameter"
    }
}

proc op1 {parameter} {
    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [get_dest_index $parameter 3]
    set res [expr {$lhs + $rhs}]
    memory_set $dest_index $res
    incr ::instruction_pointer 4
}

proc op2 {parameter} {
    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [get_dest_index $parameter 3]
    set res [expr {$lhs * $rhs}]
    memory_set $dest_index $res
    incr ::instruction_pointer 4
}

proc op3 {parameter} {
    if {$::input_pointer >= [llength $::input_queue]} {
        set ::status blocking
        return
    }
    set input [lindex $::input_queue $::input_pointer]
    incr ::input_pointer

    set dest_index [get_dest_index $parameter 1]
    memory_set $dest_index $input
    incr ::instruction_pointer 2
}

# Opcode 4 outputs the value of its only parameter. For example, the
# instruction 4,50 would output the value at address 50.
proc op4 {parameter} {
    set value [get_value $parameter 1]
    lappend ::output_queue $value
    incr ::instruction_pointer 2
}

# Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the
# instruction pointer to the value from the second parameter. Otherwise, it
# does nothing.
proc op5  {parameter} {
    set lhs [get_value $parameter 1]
    if {$lhs != 0} {
        set rhs [get_value $parameter 2]
        set ::instruction_pointer $rhs
    } else {
        incr ::instruction_pointer 3
    }
}

# Opcode 6 is jump-if-false: if the first parameter is zero, it sets the
# instruction pointer to the value from the second parameter. Otherwise, it
# does nothing.
proc op6 {parameter} {
    set lhs [get_value $parameter 1]
    if {$lhs == 0} {
        set rhs [get_value $parameter 2]
        set ::instruction_pointer $rhs
    } else {
        incr ::instruction_pointer 3
    }
}

# Opcode 7 is less than: if the first parameter is less than the second
# parameter, it stores 1 in the position given by the third parameter.
# Otherwise, it stores 0.
proc op7 {parameter} {
    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [get_dest_index $parameter 3]
    if {$lhs < $rhs} {
        memory_set $dest_index 1
    } else {
        memory_set $dest_index 0
    }
    incr ::instruction_pointer 4
}

# Opcode 8 is equals: if the first parameter is equal to the second parameter,
# it stores 1 in the position given by the third parameter. Otherwise, it
# stores 0.
proc op8 {parameter} {
    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [get_dest_index $parameter 3]
    if {$lhs == $rhs} {
        memory_set $dest_index 1
    } else {
        memory_set $dest_index 0
    }
    incr ::instruction_pointer 4
}

# Opcode 9 adjusts the relative base by the value of its only parameter. The
# relative base increases (or decreases, if the value is negative) by the value
# of the parameter
proc op9 {parameter} {
    set i [get_value $parameter 1]
    incr ::relative_base $i
    incr ::instruction_pointer 2
}

proc init {intcode} {
    # Erase any previous memory
    array unset ::mnemosyne
    # Copy intcode into memory
    for {set i 0} {$i < [llength $intcode]} {incr i} {
        memory_set $i [lindex $intcode $i]
    }
    # Set global vars
    set ::instruction_pointer 0
    set ::input_queue {}
    set ::input_pointer 0
    set ::output_queue {}
    set ::relative_base 0
    set ::status ok
    set ::code_limit [llength $intcode]
}

proc run {} {
    # Run program
    set token [memory_get $::instruction_pointer]
    set opcode [expr {$token % 100}]
    set parameter [format %03d [expr {int($token / 100)}]]
    # puts "$opcode $parameter @ $::instruction_pointer"
    while {$opcode != 99} {
        set ::status ok
        op${opcode} $parameter
        if {$::status == "blocking"} {
            return
        }
        if {$::instruction_pointer >= $::code_limit} {
            error "We've wandered off the reservation ..."
        }
        set token [memory_get $::instruction_pointer]
        set opcode [expr {$token % 100}]
        set parameter [format %03d [expr {int($token / 100)}]]
        # puts "$opcode $parameter @ $::instruction_pointer"
    }
    set ::status "halted"
}

proc read_output_queue {} {
    set out $::output_queue
    set ::output_queue {}
    return $out
}

proc enqueue_input {value} {
    lappend ::input_queue $value
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
    init $intcode
    while {$::status != "halted"} {
        run
        if {$::status == "blocking"} {
            set output [read_output_queue]
            if {[llength $output] > 0} {
                lassign $output paint_color turn_code
                paint_panel $posn $paint_color
                # puts "painted panel $posn $paint_color"
                # puts "getting new dirn from $dirn and $turn_code"
                set dirn [turn_robot $dirn $turn_code]
                # puts "turned to $dirn"
                set posn [move $dirn $posn]
                # puts "moved $dirn to $posn"
            }
            enqueue_input [get_panel_color $posn]
        }
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
