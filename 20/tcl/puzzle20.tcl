# Advent of Code 2019 :: Day 20 :: Donut Maze
# https://adventofcode.com/2019/day/20

package require struct::queue
package require struct::prioqueue

proc parse_maze {input} {
    set maze {}
    set row_index 0
    foreach line [split $input "\n"] {
        set row_data [split $line ""]
        lappend maze $row_data
    }
    return $maze
}

proc neighborhood {posn} {
    lassign $posn row col
    set u [list [expr {$row - 1}] $col]
    set d [list [expr {$row + 1}] $col]
    set l [list $row [expr {$col - 1}]]
    set r [list $row [expr {$col + 1}]]
    return [list $u $d $l $r]
}

proc maze_get {maze posn} {
    lassign $posn row col
    return [lindex [lindex $maze $row] $col]
}

proc is_open {cell} { return [expr {$cell == "."}] }

proc is_label {cell} { return [string is alpha $cell] }

proc is_portal_posn {maze posn} {
    set cell [maze_get $maze $posn]
    lassign $posn row col
    if {[is_open $cell]} {
        foreach neighbor [neighborhood $posn] {
            if {[is_label [maze_get $maze $neighbor]]} {
                return 1
            }
        }
    }
    return 0
}

proc get_portal_label {maze posn} {
    lassign $posn row col
    set height [llength maze]
    set width [llength [lindex $maze $row]]
    set cell [maze_get $maze $posn]
    set level_offset 0
    lassign [neighborhood $posn] up dn lf rt
    if {[is_label [maze_get $maze $up]]} {
        set a [maze_get $maze $up]
        set b [maze_get $maze [list [expr {$row - 2}] $col]]
        if {[expr {$row - 2}] == 0} {
            set level_offset 1
        } else {
            set level_offset -1
        }
    } elseif {[is_label [maze_get $maze $dn]]} {
        set a [maze_get $maze $dn]
        set b [maze_get $maze [list [expr {$row + 2}] $col]]
        if {[expr {$row + 2}] == [expr {$height - 1}]} {
            set level_offset 1
        } else {
            set level_offset -1
        }
    } elseif {[is_label [maze_get $maze $lf]]} {
        set a [maze_get $maze $lf]
        set b [maze_get $maze [list $row [expr {$col - 2}]]]
        if {[expr {$col - 2}] == 0} {
            set level_offset 1
        } else {
            set level_offset -1
        }
    } elseif {[is_label [maze_get $maze $rt]]} {
        set a [maze_get $maze $rt]
        set b [maze_get $maze [list $row [expr {$col + 2}]]]
        if {[expr {$col + 2}] == [expr {$width - 1}]} {
            set level_offset 1
        } else {
            set level_offset -1
        }
    }
    if {$a < $b} {
        return [list $a $b $level_offset]
    } else {
        return [list $b $a $level_offset]
    }
}

proc find_portals {maze} {
    set posns_portals [dict create]
    set portals_posns [dict create]
    set level_offsets [dict create]
    for {set row 0} {$row < [llength $maze]} {incr row} {
        set row_data [lindex $maze $row]
        for {set col 0} {$col < [string length $row_data]} {incr col} {
            set posn [list $row $col]
            if {[is_portal_posn $maze $posn]} {
                lassign [get_portal_label $maze $posn] a b level_offset
                set portal_label "${a}${b}"
                if {[dict exists $portals_posns $portal_label]} {
                    set portal_label "${b}${a}"
                }
                if {$a == $b} {
                    set level_offset 0
                }
                dict set posns_portals $posn $portal_label
                dict set portals_posns $portal_label $posn
                dict set level_offsets $portal_label $level_offset
            }
        }
    }
    return [list $posns_portals $portals_posns $level_offsets]
}

proc maze_to_graph {maze} {
    # Find the positions of the portals.
    lassign [find_portals $maze] posns_portals portals_posns level_offsets

    set graph [dict create]

    dict for {portal_label posn} $portals_posns {
        set a [string index $portal_label 0]
        set b [string index $portal_label 1]
        if {$a != $b} {
            set opposite_portal_label "${b}${a}"
            set level_offset [dict get $level_offsets $portal_label]
            dict lappend graph $portal_label [list $opposite_portal_label 1]
        }
    }

    dict for {start_posn start_label} $posns_portals {
        set queue [::struct::queue]
        $queue put [list $start_posn 0]
        set visited [dict create]
        dict set visited $start_posn 1
        while {[$queue size] > 0} {
            lassign [$queue get] posn dist
            incr dist
            foreach neighbor [neighborhood $posn] {
                if {[dict exists $visited $neighbor]} {
                    continue
                }
                if {[is_open [maze_get $maze $neighbor]]} {
                    if {[dict exists $posns_portals $neighbor]} {
                        set portal_label [dict get $posns_portals $neighbor]
                        dict lappend graph $start_label [list $portal_label $dist]
                    }
                    $queue put [list $neighbor $dist]
                    dict set visited $neighbor 1
                }
            }
        }
    }
    return $graph
}

proc solve_part1 {graph} {
    set distance [dict create]
    set processed [dict create]
    dict for {node edges} $graph {
        dict set distance $node 99999
    }
    dict set distance "AA" 0
    set queue [::struct::prioqueue]
    $queue put "AA" 0
    while {[$queue size] > 0} {
        set node [$queue get]
        if {[dict exists $processed $node]} {
            continue
        }
        dict set processed $node 1
        set node_distance [dict get $distance $node]
        foreach edge [dict get $graph $node] {
            lassign $edge neighbor weight
            set neighbor_distance [dict get $distance $neighbor]
            if {[expr {$node_distance + $weight}] < $neighbor_distance} {
                dict set distance $neighbor [expr {$node_distance + $weight}]
                $queue put $neighbor -[dict get $distance $neighbor]
            }
        }
    }
    return [dict get $distance "ZZ"]
}

proc are_connected_portals {portal1 portal2} {
    return [expr {[string reverse $portal1] == $portal2}]
}

proc is_terminal {portal} {
    return [expr {$portal == "AA" || $portal == "ZZ"}]
}

proc solve_part2 {graph} {
    puts $graph
    return 0
}

proc main {} {
    set input [read stdin]
    set maze [parse_maze $input]
    set graph [maze_to_graph $maze]
    set soln1 [solve_part1 $graph]
    puts "The solution to part 1 is $soln1."
    set soln2 [solve_part2 $graph]
    puts "The solution to part 2 is $soln2."
    

    # if {$soln1 != 604} {error "The solution to part 1 should be 604."}

}

if {$::argv0 == [info script]} {
    main
}
