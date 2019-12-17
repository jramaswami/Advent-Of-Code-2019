# Advent of Code 2019 :: Day 17 :: Set and Forget
# https://adventofcode.com/2019/day/17

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

# Procedure for producing coroutine
proc run_computer {intcode} {
    set computer [IntcodeComputer new $intcode]
    $computer run
}

proc print_map {map} {
    puts [join [lmap cols $map {join $cols ""}] "\n"]
}

proc neighborhood {row col} {
    set u [list [expr {$row - 1}] $col]
    set d [list [expr {$row + 1}] $col]
    set l [list $row [expr {$col - 1}]]
    set r [list $row [expr {$col + 1}]]
    return [list $u $d $l $r]
}

proc map_get {map row col} {
    if {$row < 0} {return ""}
    if {$col < 0} {return ""}
    if {$row > [llength $map]} {return ""}
    if {$col > [llength [lindex $map $row]]} {return ""}
    return [lindex [lindex $map $row] $col]
}

# Convert the ascii output of the scaffold into a map.
proc map_scaffold {intcode} {
    set map {}
    set row_data {}
    set c [format %c [coroutine compute run_computer $intcode]]
    lappend row_data $c
    while {[llength [info commands compute]] > 0} {
        set out [compute]
        if {$out == ""} {
            break
        }
        set cell [format %c $out]
        if {$cell == "\n"} {
            lappend map $row_data
            set row_data {}
        } else {
            lappend row_data $cell
        }
    }
    return $map
}

# Find the intersections and solve the first part of the puzzle.
proc solve_part1 {map} {
    set total_align_param 0
    for {set row 0} {$row < [llength $map]} {incr row} {
        for {set col 0} {$col < [llength [lindex $map $row]]} {incr col} {
            set c [map_get $map $row $col]
            if {$c != "#"} {
                continue
            }
            set intersection 1
            foreach neighbor [neighborhood $row $col] {
                lassign $neighbor row0 col0
                set c0 [map_get $map $row0 $col0]
                if {$c0 != "#"} {
                    set intersection 0
                }
            }
            if {$intersection} {
                lset map $row $col "o"
                lappend intersections [list $row $col]
                set align_param [expr {$row * $col}]
                incr total_align_param $align_param
            }
        }
    }
    # puts "Intersection map."
    # print_map $map
    return $total_align_param
}

# Get the position of the robot.
proc find_robot {map} {
    # Find robot
    for {set row 0} {$row < [llength $map]} {incr row} {
        for {set col 0} {$col < [llength [lindex $map $row]]} {incr col} {
            set c [map_get $map $row $col]
            if {$c == "^"} {
                # puts "Robot at $row $col."
                return [list $row $col]
            }
        }
    }
}

# Determine which way to turn and what direction that will be.
proc get_next_turn {posn dirn map} {
    # puts "get_next_turn $posn $dirn map"
    lassign $posn row col
    switch $dirn {
        N {
            # Look left
            set row0 $row
            set col0 [expr {$col - 1}]
            set c [map_get $map $row0 $col0]
            # puts "Looking left $row0 $col0 -- $c"
            if {$c == "#"} {
                return {L W}
            }
            # Look right
            set row0 $row
            set col0 [expr {$col + 1}]
            set c [map_get $map $row0 $col0]
            # puts "Looking right $row0 $col0 -- $c"
            if {$c == "#"} {
                return {R E}
            }
        } 
        S {
            # Look left
            set row0 $row
            set col0 [expr {$col + 1}]
            set c [map_get $map $row0 $col0]
            # puts "Looking left $row0 $col0 -- $c"
            if {$c == "#"} {
                return {L E}
            }
            # Look right
            set row0 $row
            set col0 [expr {$col - 1}]
            set c [map_get $map $row0 $col0]
            # puts "Looking right $row0 $col0 -- $c"
            if {$c == "#"} {
                return {R W}
            }
        }
        E {
            # Look left
            set row0 [expr {$row - 1}]
            set col0 $col
            set c [map_get $map $row0 $col0]
            # puts "Looking left $row0 $col0 -- $c"
            if {$c == "#"} {
                return {L N}
            }
            # Look right
            set row0 [expr {$row + 1}]
            set col0 $col
            set c [map_get $map $row0 $col0]
            # puts "Looking right $row0 $col0 -- $c"
            if {$c == "#"} {
                return {R S}
            }
        }
        W {
            # Look left
            set row0 [expr {$row + 1}]
            set col0 $col
            set c [map_get $map $row0 $col0]
            # puts "Looking left $row0 $col0 -- $c"
            if {$c == "#"} {
                return {L S}
            }
            # Look right
            set row0 [expr {$row - 1}]
            set col0 $col
            set c [map_get $map $row0 $col0]
            # puts "Looking right $row0 $col0 -- $c"
            if {$c == "#"} {
                return {R N}
            }
        }
    }
    return {None None}
}
    
# Get the position produced by moving in the given direction.
proc update_posn {posn dirn} {
    lassign $posn row col
    switch $dirn {
        E {return [list $row [expr {$col + 1}]]}
        W {return [list $row [expr {$col - 1}]]}
        N {return [list [expr {$row - 1}] $col]}
        S {return [list [expr {$row + 1}] $col]}
    }
}

# Move from the given position in the given direction
# until you run out of scaffold.  Return the new position
# and the number of steps taken.
proc move {posn dirn map_var} {
    upvar $map_var map
    set steps 0
    set posn0 [update_posn $posn $dirn]
    lassign $posn0 row0 col0
    set c [map_get $map $row0 $col0]
    while {$c == "#" || $c == "*"} {
        incr steps
        lset map $row0 $col0 "*"
        set posn $posn0
        set posn0 [update_posn $posn0 $dirn]
        lassign $posn0 row0 col0
        set c [map_get $map $row0 $col0]
    }
    return [list $posn $steps]
}

# Walk the scaffold to determine the path from the starting
# point to the ending point.
proc find_path {map} {
    set path {}
    set posn [find_robot $map]
    lassign [get_next_turn $posn N $map] turn dirn
    while {$turn != "None"} {
        lassign [move $posn $dirn map] posn steps
        # puts "robot now in $posn after $turn $steps ($dirn)"
        set path [concat $path "$turn $steps"]
        # print_map $map
        lassign [get_next_turn $posn $dirn $map] turn dirn
    }
    return $path
}

proc solve_part2 {intcode map} {
    # Find path on scaffolding
    set path [find_path $map]
    # puts $path

    # Break path up into subroutines
    set A {R 6 L 8 L 10 R 6}
    set B {R 6 L 6 L 10}
    set C {L 8 L 6 L 10 L 6}
    set M {B C B C A B C A B A}

    # Make sure the subroutines match the path
    set path0 [concat $B $C $B $C $A $B $C $A $B $A]
    if {$path0 != $path} {
        error "This is not the way!"
    }
    set sub_a [lmap x [concat [split [join $A ,] {}] [list "\n"]] {scan $x %c}]
    set sub_b [lmap x [concat [split [join $B ,] {}] [list "\n"]] {scan $x %c}]
    set sub_c [lmap x [concat [split [join $C ,] {}] [list "\n"]] {scan $x %c}]
    set sub_main [lmap x [concat [split [join $M ,] {}] [list "\n"]] {scan $x %c}]
    set continuous_feed [lmap x [split "n\n" {}] {scan $x %c}]

    lset intcode 0 2
    # Run until computer needs input, it will print the map again
    set c [coroutine compute run_computer $intcode]
    while {$c != "?" && $c != ""} {
        # puts -nonewline [format %c $c]
        set c [compute]
    }
    # puts $c
    
    # Input the main subroutine
    foreach p $sub_main {
        set c [compute $p]
    }

    # Read prompt
    while {$c != "?" && $c != ""} {
        # puts -nonewline [format %c $c]
        set c [compute]
    }
    # puts $c
   
    # Input subroutine A
    foreach p $sub_a {
        set c [compute $p]
    }
    while {$c != "?" && $c != ""} {
        # puts -nonewline [format %c $c]
        set c [compute]
    }
    # puts $c

    # Input subroutine B
    foreach p $sub_b {
        set c [compute $p]
    }
    while {$c != "?" && $c != ""} {
        # puts -nonewline [format %c $c]
        set c [compute]
    }
    # puts $c

    # Input subroutine C
    foreach p $sub_c {
        set c [compute $p]
    }
    while {$c != "?" && $c != ""} {
        # puts -nonewline [format %c $c]
        set c [compute]
    }
    # puts $c

    # Input continuous feed
    foreach p $continuous_feed {
        set c [compute $p]
    }

    # Read output --> it will draw the final map in ascii
    # but will give the answer as a number (greater than 127)
    while {[llength [info commands compute]] > 0} {
        if {$c < 127} {
            # puts -nonewline [format %c $c]
        } else {
            set soln2 $c
        }
        set c [compute]
    }
    return $soln2
}

proc main {} {
    set input [string trim [read stdin]]
    set intcode [split $input ,]
    set map [map_scaffold $intcode]
    set soln1 [solve_part1 $map]
    set soln2 [solve_part2 $intcode $map]
    puts "The solution to part 1 is $soln1."
    if {$soln1 != 1544} {error "The solution to part 1 should be 1544."}
    puts "The solution to part 2 is $soln2."
    if {$soln2 != 696373} {error "The solution to part 1 should be 696373."}
}

if {$::argv0 == [info script]} {
    main
}
