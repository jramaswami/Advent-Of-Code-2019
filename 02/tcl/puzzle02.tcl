# Advent of Code 2019 :: Day 2 :: 1202 Program Alarm
# https://adventofcode.com/2019/day/2

proc op1 {instruction_pointer_var intcode_var} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode

    set lhs_index [lindex $intcode [expr {$instruction_pointer + 1}]]
    set rhs_index [lindex $intcode [expr {$instruction_pointer + 2}]]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]

    set lhs [lindex $intcode $lhs_index]
    set rhs [lindex $intcode $rhs_index]

    set res [expr {$lhs + $rhs}]

    lset intcode $dest_index $res

    incr instruction_pointer 4
}

proc op2 {instruction_pointer_var intcode_var} {
    upvar $instruction_pointer_var instruction_pointer
    upvar $intcode_var intcode

    set lhs_index [lindex $intcode [expr {$instruction_pointer + 1}]]
    set rhs_index [lindex $intcode [expr {$instruction_pointer + 2}]]
    set dest_index [lindex $intcode [expr {$instruction_pointer + 3}]]

    set lhs [lindex $intcode $lhs_index]
    set rhs [lindex $intcode $rhs_index]
    set res [expr {$lhs * $rhs}]

    lset intcode $dest_index $res

    incr instruction_pointer 4
}

proc run_intcode {intcode} {
    set instruction_pointer 0

    set opcode [lindex $intcode $instruction_pointer]
    while {$opcode != 99} {
        op${opcode} instruction_pointer intcode
        set opcode [lindex $intcode $instruction_pointer]
    }
    return [lindex $intcode 0]
}

proc reset_1202 {intcode} {
    lset intcode 1 12
    lset intcode 2 2
    return $intcode
}

proc set_verb_and_noun {intcode noun verb} {
    lset intcode 1 $noun
    lset intcode 2 $verb
    return $intcode
}

proc solve_part2 {intcode} {
    # 2682 is too low.
    for {set noun 0} {$noun < 100} {incr noun} {
        for {set verb 0} {$verb < 100} {incr verb} {
            set intcode0 [set_verb_and_noun $intcode $noun $verb]
            set result [run_intcode $intcode0]
            if {$result == 19690720} {
                return [expr {100 * $noun + $verb}]
            }
        }
    }
}

if {$::argv0 == [info script]} {
    set input [string trimright [read stdin]]
    set intcode [split $input ","]
    puts "The solution to part 1 is [run_intcode [reset_1202 $intcode]]."
    puts "The solution to part 2 is [solve_part2 $intcode]."
}
