# Advent of Code :: Intcode Computer used in days 2, 5

proc get_value {intcode instruction_pointer parameter posn} {
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

proc op1 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode

    set lhs [get_value $intcode $instruction_pointer $parameter 1]
    set rhs [get_value $intcode $instruction_pointer $parameter 2]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
    set res [expr {$lhs + $rhs}]

    lset intcode $dest_index $res

    incr instruction_pointer 4
}

proc op2 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode

    set lhs [get_value $intcode $instruction_pointer $parameter 1]
    set rhs [get_value $intcode $instruction_pointer $parameter 2]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
    set res [expr {$lhs * $rhs}]

    lset intcode $dest_index $res
    incr instruction_pointer 4
}

proc op3 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode
    puts -nonewline "Enter input >> "
    flush stdout
    set input [string trim [gets stdin]]

    set dest_index [lindex $intcode [expr {$instruction_pointer + 1}]]
    lset intcode $dest_index $input
    incr instruction_pointer 2
}

# Opcode 4 outputs the value of its only parameter. For example, the
# instruction 4,50 would output the value at address 50.
proc op4 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode
    # set index [lindex $intcode [expr {$instruction_pointer + 1}]]
    # set value [lindex $intcode $index]
    # puts "output $index $value @ $instruction_pointer parameter $parameter"
    set value [get_value $intcode $instruction_pointer $parameter 1]
    # puts "output $value @ $instruction_pointer parameter $parameter"
    puts "Output: $value"
    incr instruction_pointer 2
}

# Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the
# instruction pointer to the value from the second parameter. Otherwise, it
# does nothing.
proc op5  {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode
    set lhs [get_value $intcode $instruction_pointer $parameter 1]
    if {$lhs != 0} {
        set rhs [get_value $intcode $instruction_pointer $parameter 2]
        set instruction_pointer $rhs
    } else {
        incr instruction_pointer 3
    }
}

# Opcode 6 is jump-if-false: if the first parameter is zero, it sets the
# instruction pointer to the value from the second parameter. Otherwise, it
# does nothing.
proc op6 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode
    set lhs [get_value $intcode $instruction_pointer $parameter 1]
    if {$lhs == 0} {
        set rhs [get_value $intcode $instruction_pointer $parameter 2]
        set instruction_pointer $rhs
    } else {
        incr instruction_pointer 3
    }
}

# Opcode 7 is less than: if the first parameter is less than the second
# parameter, it stores 1 in the position given by the third parameter.
# Otherwise, it stores 0.
proc op7 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode
    set lhs [get_value $intcode $instruction_pointer $parameter 1]
    set rhs [get_value $intcode $instruction_pointer $parameter 2]
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
proc op8 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode
    set lhs [get_value $intcode $instruction_pointer $parameter 1]
    set rhs [get_value $intcode $instruction_pointer $parameter 2]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]
    if {$lhs == $rhs} {
        lset intcode $dest_index 1
    } else {
        lset intcode $dest_index 0
    }
    incr instruction_pointer 4
}

proc run_intcode {intcode} {
    set instruction_pointer 0

    set token [lindex $intcode $instruction_pointer]
    set opcode [expr {$token % 100}]
    set parameter [format %03d [expr {int($token / 100)}]]
    while {$opcode != 99} {
        op${opcode} instruction_pointer intcode $parameter
        set token [lindex $intcode $instruction_pointer]
        set opcode [expr {$token % 100}]
        set parameter [format %03d [expr {int($token / 100)}]]
        # puts "$opcode $parameter @ $instruction_pointer"
    }
    return [lindex $intcode 0]
}

