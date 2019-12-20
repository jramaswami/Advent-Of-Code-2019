# Advent of Code 2019 :: Day 20 :: Donut Maze
# https://adventofcode.com/2019/day/20

package require struct::queue
package require struct::graph
package require struct::graph::op

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
    } elseif {[is_label [maze_get $maze $dn]]} {
        set a [maze_get $maze $dn]
        set b [maze_get $maze [list [expr {$row + 2}] $col]]
    } elseif {[is_label [maze_get $maze $lf]]} {
        set a [maze_get $maze $lf]
        set b [maze_get $maze [list $row [expr {$col - 2}]]]
    } elseif {[is_label [maze_get $maze $rt]]} {
        set a [maze_get $maze $rt]
        set b [maze_get $maze [list $row [expr {$col + 2}]]]
    }
    if {$a < $b} {
        return [list $a $b]
    } else {
        return [list $b $a]
    }
}

proc find_portals {maze} {
    set posns_portals [dict create]
    set portals_posns [dict create]
    for {set row 0} {$row < [llength $maze]} {incr row} {
        set row_data [lindex $maze $row]
        for {set col 0} {$col < [string length $row_data]} {incr col} {
            set posn [list $row $col]
            if {[is_portal_posn $maze $posn]} {
                lassign [get_portal_label $maze $posn] a b
                set portal_label "${a}${b}"
                if {[dict exists $portals_posns $portal_label]} {
                    set portal_label "${b}${a}"
                }
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

    set graph [::struct::graph]
    dict for {portal_label posn} $portals_posns {
        $graph node insert $portal_label
    }

    dict for {portal_label posn} $portals_posns {
        set a [string index $portal_label 0]
        set b [string index $portal_label 1]
        if {$a < $b} {
            set edge [$graph arc insert "${a}${b}" "${b}${a}"]
            $graph arc setweight $edge 1
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
                        # dict lappend graph $start_label [list $portal_label $dist]
                        set edge [$graph arc insert $start_label $portal_label]
                        $graph arc setweight $edge $dist
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
    set dists [::struct::graph::op::dijkstra $graph "AA" -outputformat distances]
    return [dict get $dists "ZZ"]
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
