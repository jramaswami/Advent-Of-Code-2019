# Advent of Code 2019 :: Day 9 :: Sensor Boost
# https://adventofcode.com/2019/day/9

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

proc run {intcode inputs} {
    # Copy intcode into memory
    for {set i 0} {$i < [llength $intcode]} {incr i} {
        memory_set $i [lindex $intcode $i]
    }
    # Set global vars
    set ::instruction_pointer 0
    set ::input_queue $inputs
    set ::input_pointer 0
    set ::output_queue {}
    set ::relative_base 0

    # Run program
    set token [memory_get $::instruction_pointer]
    set opcode [expr {$token % 100}]
    set parameter [format %03d [expr {int($token / 100)}]]
    while {$opcode != 99} {
        # puts "$opcode $parameter @ $::instruction_pointer"
        op${opcode} $parameter
        set token [memory_get $::instruction_pointer]
        set opcode [expr {$token % 100}]
        set parameter [format %03d [expr {int($token / 100)}]]
    }
    return $::output_queue
}

if {$::argv0 == [info script]} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]

    set soln1 [run $intcode [list 1]]
    puts "The solution to part 1 is $soln1."
    set soln2 [run $intcode [list 2]]
    puts "The solution to part 2 is $soln2."

    if {$soln1 != 4234906522} {error "The solution to part 1 should be 4234906522."}
    if {$soln2 != 60962} {error "The solution to part 2 should be 60962."}
}
