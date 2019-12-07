# Advent of Code :: Intcode Computer used in days 2, 5

namespace eval Intcode {

    namespace export init run

    variable intcode
    variable instruction_pointer
    variable input_queue
    variable input_pointer
    variable ouput_queue
    variable blocking
    variable looped 0
}

proc ::Intcode::get_value {parameter posn} {
    variable intcode
    variable instruction_pointer
    set p [string index $parameter [expr {2 - $posn + 1}]]
    if {$p == 0} {
        # Position mode
        set i [lindex $intcode [expr {$instruction_pointer + $posn}]]
        set v [lindex $intcode $i]
        return $v
    } elseif {$p == 1} {
        # Immediate mode
        return [lindex $intcode [expr {$instruction_pointer + $posn}]]
    }
}

proc ::Intcode::op1 {parameter} {
    variable intcode
    variable instruction_pointer

    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
    set res [expr {$lhs + $rhs}]

    lset intcode $dest_index $res

    incr instruction_pointer 4
}

proc ::Intcode::op2 {parameter} {
    variable intcode
    variable instruction_pointer

    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
    set res [expr {$lhs * $rhs}]

    lset intcode $dest_index $res
    incr instruction_pointer 4
}

proc ::Intcode::op3 {parameter} {
    variable intcode
    variable instruction_pointer
    variable input_queue
    variable input_pointer
    variable blocking
    set input [lindex $input_queue $input_pointer]
    incr input_pointer

    set dest_index [lindex $intcode [expr {$instruction_pointer + 1}]]
    lset intcode $dest_index $input
    incr instruction_pointer 2
}

# Opcode 4 outputs the value of its only parameter. For example, the
# instruction 4,50 would output the value at address 50.
proc ::Intcode::op4 {parameter} {
    variable intcode
    variable instruction_pointer
    variable output_queue
    variable looped
    variable blocking
    # set index [lindex $intcode [expr {$instruction_pointer + 1}]]
    # set value [lindex $intcode $index]
    # puts "output $index $value @ $instruction_pointer parameter $parameter"
    set value [get_value $parameter 1]
    # puts "output $value @ $instruction_pointer parameter $parameter"
    lappend output_queue $value
    incr instruction_pointer 2

    if {$looped} {
        set blocking 1
    }

}

# Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the
# instruction pointer to the value from the second parameter. Otherwise, it
# does nothing.
proc ::Intcode::op5  {parameter} {
    variable intcode
    variable instruction_pointer
    set lhs [get_value $parameter 1]
    if {$lhs != 0} {
        set rhs [get_value $parameter 2]
        set instruction_pointer $rhs
    } else {
        incr instruction_pointer 3
    }
}

# Opcode 6 is jump-if-false: if the first parameter is zero, it sets the
# instruction pointer to the value from the second parameter. Otherwise, it
# does nothing.
proc ::Intcode::op6 {parameter} {
    variable intcode
    variable instruction_pointer
    set lhs [get_value $parameter 1]
    if {$lhs == 0} {
        set rhs [get_value $parameter 2]
        set instruction_pointer $rhs
    } else {
        incr instruction_pointer 3
    }
}

# Opcode 7 is less than: if the first parameter is less than the second
# parameter, it stores 1 in the position given by the third parameter.
# Otherwise, it stores 0.
proc ::Intcode::op7 {parameter} {
    variable intcode
    variable instruction_pointer
    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
    if {$lhs < $rhs} {
        lset intcode $dest_index 1
    } else {
        lset intcode $dest_index 0
    }
    incr instruction_pointer 4
}

# Opcode 8 is equals: if the first parameter is equal to the second parameter,
# it stores 1 in the position given by the third parameter. Otherwise, it
# stores 0.
proc ::Intcode::op8 {parameter} {
    variable intcode
    variable instruction_pointer
    set lhs [get_value $parameter 1]
    set rhs [get_value $parameter 2]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
    if {$lhs == $rhs} {
        lset intcode $dest_index 1
    } else {
        lset intcode $dest_index 0
    }
    incr instruction_pointer 4
}

proc ::Intcode::init {intcode0 inputs {ip 0} {looped0 0}} {
    variable intcode 
    set intcode $intcode0
    variable instruction_pointer 
    set instruction_pointer $ip
    variable input_queue
    set input_queue $inputs
    variable input_pointer 
    set input_pointer 0
    variable output_queue 
    set output_queue {}
    variable halted 
    set halted 0
    variable blocking
    set blocking 0

    variable looped
    if {$looped0} {
        set looped $looped0
    }
}

proc ::Intcode::run {} {
    variable intcode 
    variable instruction_pointer 
    variable blocking
    variable intcode
    variable output_queue
    variable halted

    set token [lindex $intcode $instruction_pointer]
    set opcode [expr {$token % 100}]
    set parameter [format %03d [expr {int($token / 100)}]]
    while {$opcode != 99} {
        op${opcode} $parameter

        if {$blocking} {
            return [list $intcode $output_queue $instruction_pointer]
        }

        set token [lindex $intcode $instruction_pointer]
        set opcode [expr {$token % 100}]
        set parameter [format %03d [expr {int($token / 100)}]]
        # puts "$opcode $parameter @ $instruction_pointer"
        # puts "$intcode"
    }

    set halted 1
    return [list $intcode $output_queue]
}
