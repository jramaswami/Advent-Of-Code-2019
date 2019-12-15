# Advent of Code 2019 :: Day 15 :: Oxygen System
# https://adventofcode.com/2019/day/15

package require struct::queue

oo::class create IntcodeComputer {

    variable instruction_pointer memory relative_base input_value output_value

    constructor {memory0 {ip 0} {rb 0}} {
        my variable memory relative_base input_value output_value instruction_pointer
        set memory $memory0
        set instruction_pointer $ip
        set relative_base $rb
        set input_value ""
        set output_value ""
    }

    method copy {} {
        my variable memory relative_base instruction_pointer
        set mini_me [IntcodeComputer new $memory $instruction_pointer $relative_base]
        return $mini_me
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
        my variable instruction_pointer input_value
        if {$input_value == ""} {
            error "Input required."
        }
        set dest_index [my get_dest_index $parameter 1]
        my memory_set $dest_index $input_value
        set $input_value ""
        incr instruction_pointer 2
    }

    # Opcode 4 outputs the value of its only parameter. For example, the
    # instruction 4,50 would output the value at address 50.
    method op4 {parameter} {
        my variable instruction_pointer output_value
        set output_value [my get_value $parameter 1]
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

    method run {{inp ""}} {
        my variable instruction_pointer memory output_value
        # set token [lindex $intcode $instruction_pointer]
        set output_value ""
        set input_value $inp
        set token [my memory_get $instruction_pointer]
        set opcode [expr {$token % 100}]
        set parameter [format %03d [expr {int($token / 100)}]]
        while {$opcode != 99} {
            if {$opcode == 3 && $input_value == ""} {
                return ?
            }
			my op${opcode} $parameter
            if {$opcode == 4} {
                return $output_value
            }
            # set token [lindex $intcode $instruction_pointer]
            set token [my memory_get $instruction_pointer]
            set opcode [expr {$token % 100}]
            set parameter [format %03d [expr {int($token / 100)}]]
		}
	}
}

proc draw_map {} {
    set drawn_map {}
    for {set y $::min_y} {$y <= $::max_y} {incr y} {
        set row_data {}
        for {set x $::min_x} {$x <= $::max_x} {incr x} {
            set posn [list $x $y]
            if {[info exists ::map($posn)]} {
                lappend row_data [set ::map($posn)]
            } else {
                lappend row_data ?
            }
        }
        lappend drawn_map [join $row_data {}]
    }
    puts [join $drawn_map "\n"]
}
            
proc dirn_to_string {dirn} {
    switch $dirn {
        1 { return "North" }
        2 { return "South" }
        3 { return "West" }
        4 { return "East" }
    }
}

proc update_posn {dirn posn} {
    lassign $posn x y
    switch $dirn {
        1 {
            #North
            return [list $x [expr {$y + 1}]]
        }
        2 {
            # South
            return [list $x [expr {$y - 1}]]
        }
        3 {
            # West
            return [list [expr {$x - 1}] $y]
        }
        4 {
            # East
            return [list [expr {$x + 1}] $y]
        }
    }
}

proc solve {intcode} {
    set ::min_y 0
    set ::max_y 0
    set ::min_x 0
    set ::max_x 0

    set mem [dict create]
    for {set i 0} {$i < [llength $intcode]} {incr i} {
        dict set mem $i [lindex $intcode $i]
    }

    set start [list 0 0]
    set frontier [::struct::queue]
    $frontier put $start
    set visited [dict create]
    dict set visited $start 1
    set computers [dict create]
    set start_computer [IntcodeComputer new $mem]
    set ::map($start) "O"
    # Run until input needed
    $start_computer run
    dict set computers $start $start_computer

    while {[$frontier size] > 0} {
        set current [$frontier get]
        set current_computer [dict get $computers $current]
        for {set dirn 1} {$dirn <= 4} {incr dirn} {
            set neighbor [update_posn $dirn $current]
            if {![dict exists $visited $neighbor]} {
                set neighbor_computer [$current_computer copy]
                set status [$neighbor_computer run $dirn]
                if {$status == "?"} {error "Bad status: $status"}

                switch $status {
                    0 { set ::map($neighbor) # }
                    1 { set ::map($neighbor) . }
                    2 { set ::map($neighbor) x ; set o2posn $neighbor }
                }

                lassign $neighbor x y
                set ::min_y [::tcl::mathfunc::min $y $::min_y]
                set ::max_y [::tcl::mathfunc::max $y $::max_y]
                set ::min_x [::tcl::mathfunc::min $x $::min_x]
                set ::max_x [::tcl::mathfunc::max $x $::max_x]

                if {$status != 0} {
                    # Run computer again so that it needs input
                    set prompt [$neighbor_computer run]
                    if {$prompt != "?"} {error "Bad prompt: $prompt"}
                    $frontier put $neighbor
                    dict set visited $neighbor 1
                    dict set computers $neighbor $neighbor_computer
                }
            }
        }
    }

    draw_map

    set start $o2posn
    set frontier [list $start]
    set next_frontier {}
    set visited [dict create]
    dict set visited $start 1
    set dist 0
    set soln1 0
    while {[llength $frontier] > 0} {
        incr dist
        set oxy_spread 0
        foreach current $frontier {
            for {set dirn 1} {$dirn <= 4} {incr dirn} {
                set neighbor [update_posn $dirn $current]
                if {[set ::map($neighbor)] == "O"} {
                    puts "O marks the spot!"
                    set soln1 $dist
                    if {![dict exists $visited $neighbor]} {
                        lappend next_frontier $neighbor
                        dict set visited $neighbor 1
                    }
                    set ::map($neighbor) 2
                    set oxy_spread 1
                } elseif {[set ::map($neighbor)] == "."} {
                    if {![dict exists $visited $neighbor]} {
                        lappend next_frontier $neighbor
                        dict set visited $neighbor 1
                    }
                    set ::map($neighbor) 2
                    set oxy_spread 1
                }
            }
        }
        puts $dist
        draw_map
        if {$oxy_spread == 0} {
            # There was no oxygen spread this round, so the time to spread
            # was the previous round.
            return [list $soln1 [expr {$dist - 1}]]
        }

        set frontier $next_frontier
        set next_frontier {}
    }
}

proc main {} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]
    lassign [solve $intcode] soln1 soln2
    puts "The solution to part 1 is $soln1."
    puts "The solution to part 1 is $soln2."

    if {$soln1 != 230} {error "The solution to part 1 should be 230."}
    if {$soln2 != 288} {error "The solution to part 2 should be 288."}
}

if {$::argv0 == [info script]} {
    main
}
