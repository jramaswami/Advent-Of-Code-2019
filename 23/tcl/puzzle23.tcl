# Advent of Code 2019 :: Day 23 :: Category Six
# https://adventofcode.com/2019/day/23

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

proc run_to_yield {computer_name current} {
    set output {}
    while {$current != "?" && $current != "halt"} {
        lappend output $current
        set current [$computer_name]
    }
    if {$current == "halt"} {
        return [list 0 $current $output]
    }
    return [list 1 $current $output]
}

################################## End Intcode ################################

package require struct::queue

proc solve_part1 {intcode} {
    set packets [dict create]
    for {set net_addr 0} {$net_addr < 50} {incr net_addr} {
        # puts "Spinning up computer $net_addr ..."
        set current [coroutine computer${net_addr} run_computer $intcode]
        dict set packets $net_addr {}

    }

    # puts "Entering network addresses ..."
    for {set net_addr 0} {$net_addr < 50} {incr net_addr} {
        # puts "Entering network address for computer $net_addr ..."
        lassign [run_to_yield computer${net_addr} $current] ok current output
        set current [computer${net_addr} $net_addr]
        # puts "$net_addr $current"
    }

    for {set t 0} {$t < 10} {incr t} {
        # puts "Tick $t"
        for {set net_addr 0} {$net_addr < 50} {incr net_addr} {
            # Computer should always be waiting so current will be ?
            set current "?"
            # puts "Computer $net_addr has the conn ..."
            # If there is anything in the input queue, put it in ...
            set queue [dict get $packets $net_addr]
            if {$queue == {}} {
                set current [computer${net_addr} -1]
            } else {
                foreach packet $queue {
                    lassign $packet x y
                    # Input this packet
                    set current [computer${net_addr} $x]
                    set current [computer${net_addr} $y]
                }
                dict set packets $net_addr {}
            }
            # Run until I get I am waiting for input ...
            lassign [run_to_yield computer${net_addr} $current] ok current output
            if {$output != {}} {
                # puts "$net_addr > $output"
                for {set i 0} {$i < [llength $output]} {incr i 3} {
                    set addr [lindex $output $i]
                    set x [lindex $output [expr {$i + 1}]]
                    set y [lindex $output [expr {$i + 2}]]
                    # puts "Sending $x $y to $addr"
                    dict lappend packets $addr [list $x $y]
                }
            }
            if {$current != "?"} {
                # puts "$net_addr should be out of output but I am not waiting for input ..."
            }
        }
    }
    # puts $packets
    lassign [lindex [dict get $packets 255] 0] x y
    return $y
}

proc network_idle {packets} {
    dict for {addr queue} $packets {
        if {[llength $queue] > 0} {
            return 0
        }
    }
    return 1
}

proc read_packets_to_send {net_addr current packets_var packets_sent_var NAT_var} {
    upvar $packets_var packets
    upvar $packets_sent_var packets_sent
    upvar $NAT_var NAT
    # Run until I get I am waiting for input ...
    lassign [run_to_yield computer${net_addr} $current] ok current output
    if {$output != {}} {
        # puts "$net_addr > $output ($current) [llength $output]"
        for {set i 0} {$i < [llength $output]} {incr i 3} {
            set addr [lindex $output $i]
            set x [lindex $output [expr {$i + 1}]]
            set y [lindex $output [expr {$i + 2}]]
            if {$addr >= 0 && $addr < 50} {
                incr packets_sent
                # puts "$net_addr sending x $x y $y to $addr"
                dict lappend packets $addr [list $x $y]
            } elseif {$addr == 255} {
                # puts "Sending NAT ($addr) packet $x $y"
                set NAT [list $x $y]
            } else {
                # puts "$net_addr sending bad packet: $x $y to $addr"
            }
        }
    }
    return $current
}
proc solve_part2 {intcode} {
    set NAT {}
    set NAT_packets_sent [dict create]
    set packets [dict create]
    for {set net_addr 0} {$net_addr < 50} {incr net_addr} {
        # puts "Spinning up computer $net_addr ..."
        set current [coroutine computer${net_addr} run_computer $intcode]
        dict set packets $net_addr {}

    }

    # puts "Entering network addresses ..."
    for {set net_addr 0} {$net_addr < 50} {incr net_addr} {
        # puts "Entering network address for computer $net_addr ..."
        lassign [run_to_yield computer${net_addr} $current] ok current output
        set current [computer${net_addr} $net_addr]
        # puts "$net_addr $current"
    }

    set t 1
    while {1} {
        # puts "Tick $t"
        incr t
        set packets_sent 0
        for {set net_addr 0} {$net_addr < 50} {incr net_addr} {
            # Computer should always be waiting so current will be ?
            set current "?"
            # puts "Computer $net_addr has the conn ..."
            # If there is anything in the input queue, put it in ...
            set queue [dict get $packets $net_addr]
            if {$queue == {}} {
                set current [computer${net_addr} -1]
                # puts "$net_addr > -1 ($current)"
                set current [read_packets_to_send $net_addr $current packets packets_sent NAT]
            } else {
                foreach packet $queue {
                    lassign $packet x y
                    # Input this packet
                    set current [computer${net_addr} $x]
                    set current [computer${net_addr} $y]
                    # puts "$net_addr > $x $y ($current)"
                    set current [read_packets_to_send $net_addr $current packets packets_sent NAT]
                }
                dict set packets $net_addr {}
            }

            if {$current != "?"} {
                # puts "$net_addr should be out of output but I am not waiting for input ..."
            }
        }

        # puts "packets sent $packets_sent"
        if {$packets_sent < 1} {
            lassign $NAT x y
            if {[dict exists $NAT_packets_sent $y]} {
                # puts "We've already seen y value $y from $NAT in $NAT_packets_sent"
                return $y
            }
            # puts "NAT Sending $NAT to 0 ..."
            dict set NAT_packets_sent $y $NAT
            dict lappend packets 0 $NAT
        }
    }
    lassign $NAT x y
    return $y
}

proc main {} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]
    set soln1 [solve_part1 $intcode]
    puts "The solution to part 1 is $soln1."
    set soln2 [solve_part2 $intcode]
    puts "The solution to part 2 is $soln2."
}


if {$::argv0 == [info script]} {
    main
}
