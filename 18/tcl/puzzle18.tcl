# Advent of Code 2019 :: Day 18 :: Many-Worlds Interpretation
# https://adventofcode.com/2019/day/18

package require struct::queue
package require struct::set

proc parse_maze {input} {
    set maze {}
    set row_index 0
    foreach line [split $input "\n"] {
        set row_data [split $line ""]
        lappend maze $row_data
    }
    return $maze
}

proc is_key {cell} { return [string is lower $cell] }

proc is_door {cell} { return [string is upper $cell] }

proc is_open {cell} { 
    return [expr {$cell == "." || [is_start $cell]}] }

proc is_wall {cell} { return [expr {$cell == "#"}] }

proc is_start {cell} {
    return [expr {$cell == "@" || [string is integer $cell]}]
}

proc is_node {cell} {
    return [expr {[is_key $cell] || [is_door $cell] || [is_start $cell]}]
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

proc maze_set {maze_var posn value} {
    upvar $maze_var maze
    lset maze $posn $value
}

proc maze_to_string {maze} {
    return [join [lmap col $maze {join $col ""}] "\n"]
}

proc find_nodes {maze} {
    set nodes [dict create]
    for {set row 0} {$row < [llength $maze]} {incr row} {
        for {set col 0} {$col < [llength [lindex $maze $row]]} {incr col} {
            set posn [list $row $col]
            set cell [maze_get $maze $posn]
            if {[is_node $cell]} {
                dict set nodes $cell $posn
            }
        }
    }
    return $nodes
}

proc maze_to_graph {maze nodes} {
    set graph [dict create]
    foreach start [dict keys $nodes] {
        set start_posn [dict get $nodes $start]
        set queue [::struct::queue]
        $queue put [list $start_posn 0]
        set visited [dict create]
        dict set visited $start_posn 1
        while {[$queue size] > 0} {
            lassign [$queue get] node_posn node_steps
            set node_cell [maze_get $maze $node_posn]
            set neighbor_steps [expr {$node_steps + 1}]
            foreach neighbor_posn [neighborhood $node_posn] {
                if {[dict exists $visited $neighbor_posn]} {
                    continue
                }
                set neighbor_cell [maze_get $maze $neighbor_posn]
                if {[is_wall $neighbor_cell]} {
                    continue
                } elseif {[is_open $neighbor_cell]} {
                    $queue put [list $neighbor_posn $neighbor_steps]
                    dict set visited $neighbor_posn 1
                } elseif {[string is alpha $neighbor_cell]} {
                    dict lappend graph $start [list $neighbor_cell $neighbor_steps]
                }
            }
        }
    }
    return $graph
}

proc key_index {key} {
    set ascii [scan $key %c]
    return [expr {$ascii - 97}]
}

proc add_key {keyset key} {
    set offset [key_index $key]
    set mask [expr {1 << $offset}]
    return [expr {$keyset | $mask}]
}

proc have_key {keyset key} {
    set offset [key_index $key]
    set mask [expr {1 << $offset}]
    return [expr {$keyset & $mask}]
}

proc union_keysets {keyset1 keyset2} {
    return [expr {$keyset1 | $keyset2}]
}

proc solve_part1 {maze} {
    set nodes [find_nodes $maze]
    set key_count 0
    foreach node [dict keys $nodes] {
        if {[is_key $node]} {
            incr key_count
        }
    }
    set all_keys [expr {(1 << ($key_count)) - 1}]
    set graph [maze_to_graph $maze $nodes]
    set starting_state [list "@" 0]
    set state_steps [dict create]
    dict set state_steps $starting_state 0
    set queue [dict create]
    dict set queue $starting_state 1
    set new_queue [dict create]
    set min_steps 99999
    while {[dict size $queue] > 0} {
        foreach state [dict keys $queue] {
            lassign $state node keys_found
            # puts "$node [format %b $keys_found]"
            if {[dict get $state_steps $state] >= $min_steps} {
                continue
            }
            if {$keys_found == $all_keys} {
                set steps [dict get $state_steps $state] 
                set min_steps [::tcl::mathfunc::min $steps $min_steps]
            }
            set node_steps [dict get $state_steps $state]
            foreach neighbor [dict get $graph $node] {
                lassign $neighbor neighbor_cell neighbor_steps
                set next_keys_found $keys_found
                if {[is_key $neighbor_cell]} {
                    set next_keys_found [add_key $keys_found $neighbor_cell]
                } elseif {[is_door $neighbor_cell]} {
                    set key_needed [string tolower $neighbor_cell]
                    if {![have_key $next_keys_found $key_needed]} {
                        continue
                    }
                }
                set next_state [list $neighbor_cell $next_keys_found]
                set next_steps [expr {$node_steps + $neighbor_steps}]
                if {![dict exists $state_steps $next_state]} {
                    dict set state_steps $next_state $next_steps
                    dict set new_queue $next_state 1
                } elseif {$next_steps < [dict get $state_steps $next_state]} {
                    dict set state_steps $next_state $next_steps
                    dict set new_queue $next_state 1
                }
            }
        }
        set queue $new_queue
        set new_queue [dict create]
    }
    return $min_steps
}

proc update_maze {maze} {
    for {set row 0} {$row < [llength $maze]} {incr row} {
        for {set col 0} {$col < [llength [lindex $maze $row]]} {incr col} {
            set cell [maze_get $maze [list $row $col]]
            if {[is_start $cell]} {
                set start_posn [list $row $col]
                break
            }
        }
    }
    lassign $start_posn row col
    maze_set maze [list [expr {$row - 1}] [expr {$col - 1}]] 1
    maze_set maze [list [expr {$row - 1}] [expr {$col}]] "#"
    maze_set maze [list [expr {$row - 1}] [expr {$col + 1}]] 2
    maze_set maze [list $row [expr {$col - 1}]] "#"
    maze_set maze [list $row [expr {$col}]] "#"
    maze_set maze [list $row [expr {$col + 1}]] "#"
    maze_set maze [list [expr {$row + 1}] [expr {$col - 1}]] 3
    maze_set maze [list [expr {$row + 1}] [expr {$col}]] "#"
    maze_set maze [list [expr {$row + 1}] [expr {$col + 1}]] 4
    return $maze
}

proc solve_part2 {maze} {
    set nodes [find_nodes $maze]
    set key_count 0
    foreach node [dict keys $nodes] {
        if {[is_key $node]} {
            incr key_count
        }
    }
    set all_keys [expr {(1 << ($key_count)) - 1}]
    set graph [maze_to_graph $maze $nodes]
    set starting_state [list [list 1 2 3 4] 0]
    set state_steps [dict create]
    dict set state_steps $starting_state 0
    set queue [dict create]
    dict set queue $starting_state 1
    set new_queue [dict create]
    set min_steps 99999
    while {[dict size $queue] > 0} {
        foreach state [dict keys $queue] {
            lassign $state robot_nodes keys_found
            if {[dict get $state_steps $state] >= $min_steps} {
                continue
            }
            if {$keys_found == $all_keys} {
                set steps [dict get $state_steps $state] 
                set min_steps [::tcl::mathfunc::min $steps $min_steps]
            }

            # Each robot can move
            for {set robot 0} {$robot < 4} {incr robot} {
                set robot_node [lindex $robot_nodes $robot]
                set node_steps [dict get $state_steps $state]
                foreach neighbor [dict get $graph $robot_node] {
                    lassign $neighbor neighbor_cell neighbor_steps
                    set next_keys_found $keys_found
                    if {[is_key $neighbor_cell]} {
                        set next_keys_found [add_key $keys_found $neighbor_cell]
                    } elseif {[is_door $neighbor_cell]} {
                        set key_needed [string tolower $neighbor_cell]
                        if {![have_key $next_keys_found $key_needed]} {
                            continue
                        }
                    }
                    set next_robot_nodes $robot_nodes
                    lset next_robot_nodes $robot $neighbor_cell
                    set next_state [list $next_robot_nodes $next_keys_found]
                    set next_steps [expr {$node_steps + $neighbor_steps}]
                    if {![dict exists $state_steps $next_state]} {
                        dict set state_steps $next_state $next_steps
                        dict set new_queue $next_state 1
                    } elseif {$next_steps < [dict get $state_steps $next_state]} {
                        dict set state_steps $next_state $next_steps
                        dict set new_queue $next_state 1
                    }
                }
            }
        }
        set queue $new_queue
        set new_queue [dict create]
    }
    return $min_steps
}

proc main {} {
    set input [string trim [read stdin]]
    set maze [parse_maze $input]
    set soln1 [solve_part1 $maze] 
    puts "The solution to part 1 is $soln1."
    if {$soln1 != 6098} {error "The solution to part 1 should be 6098."}

    puts "Stand by ...."
    set maze [update_maze $maze]
    set soln2 [solve_part2 $maze] 
    puts "The solution to part 2 is $soln2."
    if {$soln2 != 1698} {error "The solution to part 2 should be 1698."}
}

if {$::argv0 == [info script]} {
    main
}
