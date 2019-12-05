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

proc op4 {instruction_pointer_var intcode_var parameter} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode
    set index [lindex $intcode [expr {$instruction_pointer + 1}]]
    set value [lindex $intcode $index]
    puts "Output: $value"
    incr instruction_pointer 2
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
    }
    return [lindex $intcode 0]
}

