# Advent of Code 2019 :: Day 18 :: Many-Worlds Interpretation
# https://adventofcode.com/2019/day/18

package require struct::queue
package require struct::prioqueue

proc parse_map {input} {
    set map {}
    set row_index 0
    foreach line [split $input "\n"] {
        set row_data [split $line ""]
        lappend map $row_data
    }
    return $map
}

proc neighborhood {posn} {
    lassign $posn row col
    set u [list [expr {$row - 1}] $col]
    set d [list [expr {$row + 1}] $col]
    set l [list $row [expr {$col - 1}]]
    set r [list $row [expr {$col + 1}]]
    return [list $u $d $l $r]
}

proc map_get {map posn} {
    lassign $posn row col
    return [lindex [lindex $map $row] $col]
}

proc map_to_string {map} {
    return [join [lmap col $map {join $col ""}] "\n"]
}

# Returns a dictionary of keys and their positions. Includes
# the start position as well.
proc find_key_posns {map} {
    set key_posns [dict create]
    for {set row 0} {$row < [llength $map]} {incr row} {
        for {set col 0} {$col < [llength [lindex $map $row]]} {incr col} {
            set c [map_get $map [list $row $col]]
            if {$c == "@" || [is_key $c]} {
                dict set key_posns $c [list $row $col]
            }
        }
    }
    return $key_posns
}

proc door_key {door} {
    return [string tolower $door]
}

proc door_unlocked {door keys} {
    set key [door_key $door]
    return [have_key $key $keys]
}

proc is_key {c} {
    return [string is lower $c]
}

proc is_door {c} {
    return [string is upper $c]
}

proc have_key {key keys} {
    set result [expr {[lsearch $keys $key] >= 0}]
    return $result
}

proc clear_path {map posn keys} {
    set c [map_get $map $posn]
    if {$c == "@" || $c == "."} {return 1}
    if {[is_key $c]} { return 1}
    if {[is_door $c] && [door_unlocked $c $keys]} {return 1}
    return 0
}

# Builds a graph with edges between keys where
# each edge is a list: neighbor key, steps, 
# and doors between the key and neighbor key.
proc build_graph {map key_posns} {
    set graph [dict create]
    dict for {key posn} $key_posns {
        set key [map_get $map $posn]
        set queue [::struct::queue]
        set visited [dict create]
        $queue put [list $posn 0 {}]
        dict set visited $posn 1

        while {[$queue size] > 0} {
            lassign [$queue get] posn steps doors
            incr steps
            foreach neighbor [neighborhood $posn] {
                set doors0 $doors
                set c [map_get $map $neighbor]
                if {$c == "#"} {
                    continue
                }
                if {[dict exists $visited $neighbor]} {
                    continue
                }

                if {[is_door $c]} {
                    lappend doors0 $c
                }

                if {[is_key $c]} {
                    dict lappend graph $key [list $c $steps $doors0]
                }

                $queue put [list $neighbor $steps $doors0]
                dict set visited $neighbor 1
            }
        }
    }
    return $graph
}

proc any_doors_locked {doors keys} {
    foreach door $doors {
        set key [string tolower $door]
        if {[lsearch $keys $key] < 0} {
            return 1
        }
    }
    return 0
}

proc neighbor_in_path {neighbor keys} {
    return [expr {[lsearch $keys $neighbor] >= 0}]
}

proc solve {map} {
    set key_posns [find_key_posns $map]
    set key_count [llength [dict keys $key_posns]]
    set graph [build_graph $map $key_posns]

    set min_steps 999999999
    set min_path {}
    set queue [::struct::queue]
    $queue put [list [dict get $key_posns @] 0 {@}]
    while {[$queue size] > 0} {
        lassign [$queue get] posn steps keys
        # puts "$posn $steps $keys"
        if {[llength $keys] == $key_count} {
            puts "Found $keys in $steps"
            if {$steps < $min_steps} {
                set min_steps $steps
                set min_path $keys
            }
        }
        set key [map_get $map $posn]
        foreach edge [dict get $graph $key] {
            lassign $edge neighbor_key neighbor_steps neighbor_doors
            set neighbor_posn [dict get $key_posns $neighbor_key]
            if {[neighbor_in_path $neighbor_key $keys]} {
                # puts "$neighbor_key is already in my path."
                continue
            }
            if {[any_doors_locked $neighbor_doors $keys]} {
                # puts "my $keys cannot unlock all $neighbor_doors"
                continue
            }
            $queue put [list \
                        $neighbor_posn \
                        [expr {$steps + $neighbor_steps}] \
                        [concat $keys [list $neighbor_key]]]
        }
    }
    return [list $min_path $min_steps]
}

proc main {} {
    set input [string trim [read stdin]]
    set map [parse_map $input]
    lassign [solve $map] path steps
    puts "The solution to part 1 is $steps."
}
    
if {$::argv0 == [info script]} {
    main
}
