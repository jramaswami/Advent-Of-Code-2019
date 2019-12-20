# Advent of Code 2019 :: Day 20 :: Donut Maze
# https://adventofcode.com/2019/day/20

package require struct::queue

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
    set cell [maze_get $maze $posn]
    lassign $posn row col
    lassign [neighborhood $posn] up dn lf rt
    if {[is_label [maze_get $maze $up]]} {
        set a [maze_get $maze $up]
        set b [maze_get $maze [list [expr {$row - 2}] $col]]
        return "${b}${a}"
    } elseif {[is_label [maze_get $maze $dn]]} {
        set a [maze_get $maze $dn]
        set b [maze_get $maze [list [expr {$row + 2}] $col]]
        return "${a}${b}"
    } elseif {[is_label [maze_get $maze $lf]]} {
        set a [maze_get $maze $lf]
        set b [maze_get $maze [list $row [expr {$col - 2}]]]
        return "${b}${a}"
    } elseif {[is_label [maze_get $maze $rt]]} {
        set a [maze_get $maze $rt]
        set b [maze_get $maze [list $row [expr {$col + 2}]]]
        return "${a}${b}"
    }
}

proc find_posns_portals {maze} {
    set posns_portals [dict create]
    for {set row 0} {$row < [llength $maze]} {incr row} {
        set row_data [lindex $maze $row]
        for {set col 0} {$col < [string length $row_data]} {incr col} {
            set posn [list $row $col]
            if {[is_portal_posn $maze $posn]} {
                set portal_label [get_portal_label $maze $posn]
                dict set posns_portals $posn $portal_label
            }
        }
    }
    return $posns_portals
}

proc maze_to_graph {maze} {
    # Find the positions of the portals.
    set posns_portals [find_posns_portals $maze]
    # Create dict to look up the matching portal.
    set portals_posns [dict create]
    dict for {posn portal_label} $posns_portals {
        dict lappend portals_posns $portal_label $posn
    }

    set graph [dict create]
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

proc solve {maze} {
    set graph [maze_to_graph $maze]
    set dists [dict create]
    foreach node [dict keys $graph] {
        dict set dists $node 999999
    }

    while {1} {
        set queue [::struct::queue]
        $queue put [list "AA" None]
        set visited [dict create]
        dict set visited "AA" 1
        dict set dists "AA" 0
        set flag 1
        while {[$queue size] > 0} {
            lassign [$queue get] node parent
            set node_dist [dict get $dists $node]
            puts "node $node $node_dist parent $parent"
            foreach edge [dict get $graph $node] {
                lassign $edge neighbor neighbor_steps
                puts "\t$neighbor $neighbor_steps"
                if {$neighbor == $parent} {
                    puts "$neighbor == $parent"
                    continue
                }
                if {![dict exists $visited $neighbor]} {
                    puts "$neighbor visited"
                    continue
                }
                set next_dist [expr {$neighbor_steps + $node_dist}]
                if {$next_dist < [dict get $dists $neighbor]} {
                    set flag 0
                    dict set dists $neighbor $next_dist
                }
                $queue put [list $neighbor $node]
                dict set visited $neighbor 1
            }
        }
        puts "flag $flag"
        if {$flag} { break }
    }
    puts $dists
    return 0
}

proc main {} {
    set input [read stdin]
    set maze [parse_maze $input]
    set soln1 [solve $maze]
    puts "The solution to part 1 is $soln1."

}

if {$::argv0 == [info script]} {
    main
}
