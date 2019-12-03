# Advent of Code 2019 :: Day 3 :: Crossed Wires
# https://adventofcode.com/2019/day/3

set offset(R) {1 0}
set offset(L) {-1 0}
set offset(U) {0 1}
set offset(D) {0 -1}

proc move {cmd posn steps visited_var} {
    upvar $visited_var visited
    set x [lindex $posn 0]
    set y [lindex $posn 1]
    set dirn [string index $cmd 0]
    set dist [string range $cmd 1 end]
    set off_x [lindex [set ::offset($dirn)] 0]
    set off_y [lindex [set ::offset($dirn)] 1]
    for {set i 0} {$i < $dist} {incr i} {
        incr x $off_x
        incr y $off_y
        set posn [list $x $y]
        incr steps
        if {![dict exists $visited $posn]} {
            dict append visited $posn $steps
        }
    }
    return [list $posn $steps]
}

proc solve {wire0 wire1} {
    set posn [list 0 0]
    set steps 0
    set visited0 [dict create]
    foreach cmd $wire0 {
        set result [move $cmd $posn $steps visited0]
        set posn [lindex $result 0]
        set steps [lindex $result 1]
    }

    set posn [list 0 0]
    set steps 0
    set visited1 [dict create]
    foreach cmd $wire1 {
        set result [move $cmd $posn $steps visited1]
        set posn [lindex $result 0]
        set steps [lindex $result 1]
    }
    
    set min_dist 9999999999
    set min_steps 9999999999
    foreach posn [dict keys $visited0] {
        if {[dict exists $visited1 $posn]} {
            set x [lindex $posn 0]
            set y [lindex $posn 1]
            set dist [expr {abs($x) + abs($y)}]
            set min_dist [::tcl::mathfunc::min $min_dist $dist]
            set steps [expr {[dict get $visited0 $posn] + [dict get $visited1 $posn]}]
            set min_steps [::tcl::mathfunc::min $min_steps $steps]
        }
    }
    return [list $min_dist $min_steps]
}

if {$::argv0 == [info script]} {
    set input [string trimright [read stdin]]
    set wires [split $input "\n"]
    set wire0 [split [lindex $wires 0] ","]
    set wire1 [split [lindex $wires 1] ","]
    set soln [solve $wire0 $wire1]
    puts "The solution to part 1 is a distance of [lindex $soln 0]."
    puts "The solution to part 2 is [lindex $soln 1] steps."
}
