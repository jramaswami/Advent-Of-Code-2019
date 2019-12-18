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

proc find_start {map} {
    for {set row 0} {$row < [llength $map]} {incr row} {
        for {set col 0} {$col < [llength [lindex $map $row]]} {incr col} {
            set c [map_get $map [list $row $col]]
            if {$c == "@"} {
                return [list $row $col]
            }
        }
    }
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

proc find_keys {map posn keys} {
    set key_posns {}
    set queue [::struct::queue]
    set visited [dict create]
    $queue put [list $posn 0]
    dict set visited $posn 1

    while {[$queue size] > 0} {
        lassign [$queue get] posn steps
        incr steps
        foreach neighbor [neighborhood $posn] {
            if {![clear_path $map $neighbor $keys]} {
                continue
            }
            if {[dict exists $visited $neighbor]} {
                continue
            }
            set c [map_get $map $neighbor]
            if {[is_key $c] && ![have_key $c $keys]} {
                lappend key_posns [list $neighbor $steps]
            } else {
                $queue put [list $neighbor $steps]
                dict set visited $neighbor 1
            }
        }
    }
    return $key_posns
}

proc solve {map} {
    set shortest_path {}
    set shortest_steps 999999999
    
    set display_steps 0
    set posn [find_start $map]
    set queue [::struct::prioqueue -integer]
    set visited [dict create]
    $queue put [list $posn {} 0] 0
    while {[$queue size] > 0} {
        lassign [$queue get] posn keys steps
        set state_key [list [lsort $keys] $posn]
        if {[dict exists $visited $state_key] && $steps > [dict get $visited $state_key]} {
            continue
        }
        # puts "item @$posn keys $keys steps $steps"
        if {$steps > $display_steps} {
            puts $steps
            set display_steps $steps
        }
        if {$steps > $shortest_steps} {
            break
        }
        set key_posns [find_keys $map $posn $keys]
        if {$key_posns == {}} {
            if {$steps < $shortest_steps} {
                puts "retrieved $keys in $steps steps"
                set shortest_path $keys
                set shortest_steps $steps
                break
            }
        }
        foreach k $key_posns {
            lassign $k key_posn key_steps
            # puts "\t[map_get $map $key_posn] @ $key_posn key steps $key_steps"
            set keys0 [concat $keys [list [map_get $map $key_posn]]]
            set steps0 [expr {$steps + $key_steps}]
            set state_key [list [lsort $keys0] $key_posn]
            if {[dict exists $visited $state_key] && $steps0 <= [dict get $visited $state_key]} {
                continue
            }
            set state [list $key_posn $keys0 $steps0]
            # puts "\tenqueuing $state with priority -$steps0"
            $queue put $state -$steps0
            dict set visited $keys $steps0
        }
    }
    return [list $shortest_path $shortest_steps]
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
