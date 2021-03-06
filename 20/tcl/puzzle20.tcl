# Advent of Code 2019 :: Day 20 :: Donut Maze
# https://adventofcode.com/2019/day/20

package require struct::queue
package require struct::prioqueue

proc parse_maze {input} {
    set maze {}
    set row_index 0
    foreach line [split $input "\n"] {
        if {$line != ""} {
            set row_data [split $line ""]
            lappend maze $row_data
        }
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
    set height [llength $maze]
    set width [llength [lindex $maze $row]]
    set cell [maze_get $maze $posn]
    lassign [neighborhood $posn] up dn lf rt
    if {[is_label [maze_get $maze $up]]} {
        set a [maze_get $maze $up]
        set b [maze_get $maze [list [expr {$row - 2}] $col]]
        if {[expr {$row - 2}] == 0} {
            # Outside
            return [string toupper [join [lsort -ascii [list $a $b]] ""]]
        } else {
            # Inside
            return [string tolower [join [lsort -ascii [list $a $b]] ""]]
        }
    } elseif {[is_label [maze_get $maze $dn]]} {
        set a [maze_get $maze $dn]
        set b [maze_get $maze [list [expr {$row + 2}] $col]]
        if {[expr {$row + 2}] == [expr {$height - 1}]} {
            # Outside
            return [string toupper [join [lsort -ascii [list $a $b]] ""]]
        } else {
            # Inside
            return [string tolower [join [lsort -ascii [list $a $b]] ""]]
        }
    } elseif {[is_label [maze_get $maze $lf]]} {
        set a [maze_get $maze $lf]
        set b [maze_get $maze [list $row [expr {$col - 2}]]]
        if {[expr {$col - 2}] == 0} {
            # Outside
            return [string toupper [join [lsort -ascii [list $a $b]] ""]]
        } else {
            # Inside
            return [string tolower [join [lsort -ascii [list $a $b]] ""]]
        }
    } elseif {[is_label [maze_get $maze $rt]]} {
        set a [maze_get $maze $rt]
        set b [maze_get $maze [list $row [expr {$col + 2}]]]
        if {[expr {$col + 2}] == [expr {$width - 1}]} {
            # Outside
            return [string toupper [join [lsort -ascii [list $a $b]] ""]]
        } else {
            # Inside
            return [string tolower [join [lsort -ascii [list $a $b]] ""]]
        }
    }
}

proc are_connected_portals {portal1 portal2} {
    return [expr {[string tolower $portal1] == [string tolower $portal2]}]
}

proc is_terminal {portal} {
    return [expr {$portal == "AA" || $portal == "ZZ"}]
}

proc get_portal_offset {portal} {
    if {[is_outer $portal]} {
        return 1
    } elseif {[is_terminal $portal]} {
        return 0
    } else {
        return -1
    }
}

proc get_opposite_portal {portal} {
    if {[string is lower $portal]} {
        return [string toupper $portal]
    } else {
        return [string tolower $portal]
    }
}

proc is_outer {portal} {
    return [expr {![is_terminal $portal] && [string is upper $portal]}]
}

proc find_portals {maze} {
    set posns_portals [dict create]
    set portals_posns [dict create]
    for {set row 0} {$row < [llength $maze]} {incr row} {
        set row_data [lindex $maze $row]
        for {set col 0} {$col < [string length $row_data]} {incr col} {
            set posn [list $row $col]
            if {[is_portal_posn $maze $posn]} {
                set portal_label [get_portal_label $maze $posn]
                dict set posns_portals $posn $portal_label
                dict set portals_posns $portal_label $posn
            }
        }
    }
    return [list $posns_portals $portals_posns]
}

proc maze_to_graph {maze} {
    # Find the positions of the portals.
    lassign [find_portals $maze] posns_portals portals_posns

    set graph [dict create]

    dict for {portal_label posn} $portals_posns {
        if {![is_terminal $portal_label]} {
            set opposite_portal_label [get_opposite_portal $portal_label]
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

# Use Dijkstra's algorithm to solve first part of the puzzle.
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

# Update the graph to fit the rules for part 2,  by adding th change in levels
# that occurs when teleporting through a portal.
proc update_graph {graph} {
    set graph0 [dict create]
    dict for {node edges} $graph {
        foreach edge $edges {
            lassign $edge neighbor weight
            set offset 0
            if {[are_connected_portals $node $neighbor]} {
                set offset [get_portal_offset $node]
            }
            dict lappend graph0 $node [list $neighbor $weight $offset]
        }
    }
    return $graph0
}

# Reconstruction the path taken through the maze.
proc reconstruct_path {distance parent} {
    set end_state [list "ZZ" 0]
    set path [list [list $end_state [dict get $distance $end_state]]]
    set t [dict get $parent $end_state]
    while {$t != "None"} {
        lappend path [list $t [dict get $distance $t]]
        set t [dict get $parent $t]
    }
    return $path
}

# Use Dijkstra's algorithm to solve the second part of the puzzle.
# The nodes being searched are not graph nodes, but possible states
# where a state is a combination of the graph node (portal) and the
# recursion level.
proc solve_part2 {graph} {
    set graph [update_graph $graph]

    set start_state [list "AA" 0]
    set end_state [list "ZZ" 0]

    set parent [dict create]
    dict set parent $start_state "None"

    set distance [dict create]
    dict set distance $start_state 0
    dict set distance $end_state 999999999

    set processed [dict create]
    set queue [::struct::prioqueue]
    $queue put $start_state 0

    while {[$queue size] > 0} {
        set current_state [$queue get]

        # Do not reprocess states that may have been queued more than once.
        if {[dict exists $processed $current_state]} { continue }
        dict set processed $current_state 1

        # Get the current state
        if {![dict exists $distance $current_state]} {
            dict set distance $current_state 999999999
        }
        set current_distance [dict get $distance $current_state]
        if {$current_distance > [dict get $distance $end_state]} {
            continue
        }
        lassign $current_state current_node current_level

        # Look at all the neighboring nodes ...
        foreach edge [dict get $graph $current_node] {

            lassign $edge neighbor_node neighbor_weight offset

            # Build the next state, including any possible level change.
            set neighbor_level [expr {$current_level + $offset}]
            set neighbor_state [list $neighbor_node $neighbor_level]

            # We can only use terminal portals, AA and ZZ, on level 0.
            # We cannot use non-terminal portals on level 0.
            if {$neighbor_level == 0} {
                if {[is_outer $neighbor_node]} {
                    continue
                }
            } else {
                if {[is_terminal $neighbor_node]} {
                    continue
                }
            }

            # Insert the next state into the distance dict with "infinite" 
            # distance, if the state does not already exist.
            if {![dict exists $distance $neighbor_state]} {
                dict set distance $neighbor_state 999999999
            }

            # If the distance to the neighbor state has decreased, then 
            # update the neighbor_states distance, enqueue the neighbor
            # state, and record the parent state.
            set neighbor_distance [dict get $distance $neighbor_state]
            if {[expr {$current_distance + $neighbor_weight}] < $neighbor_distance} {
                dict set distance $neighbor_state [expr {$current_distance + $neighbor_weight}]
                $queue put $neighbor_state [expr {-1 * [dict get $distance $neighbor_state]}]
                dict set parent $neighbor_state $current_state
            }
        }
    }
    # set path [reconstruct_path $distance $parent]
    return [dict get $distance $end_state]
}

proc main {} {
    set input [read stdin]
    set maze [parse_maze $input]
    set graph [maze_to_graph $maze]
    set soln1 [solve_part1 $graph]
    puts "The solution to part 1 is $soln1."
    set soln2 [solve_part2 $graph]
    puts "The solution to part 2 is $soln2."
    

    if {$soln1 != 604} {error "The solution to part 1 should be 604."}
    if {$soln2 != 7166} {error "The solution to part 2 should be 7166."}

}

if {$::argv0 == [info script]} {
    main
}
