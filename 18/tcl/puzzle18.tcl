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
    return [lindex $map $row $col]
}

proc map_set {map_var posn value} {
    upvar $map_var map
    lassign $posn row col
    lset map $posn $value
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
            if {$c == "@" || [is_key $c] || [is_door $c]} {
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

proc find_visible_keys {map posn} {
    set visible_keys {}
    set queue [::struct::queue]
    set visited [dict create]
    $queue put [list $posn 0]
    dict set visited $posn 1
    while {[$queue size] > 0} {
        lassign [$queue get] posn steps
        set c [map_get $map $posn]
        if {[is_key $c]} {
            lappend visible_keys [list $c $posn $steps]
        }
        incr steps
        foreach neighbor [neighborhood $posn] {
            set n [map_get $map $neighbor]
            if {$n == "#"} {
                continue
            }
            if {[is_door $n]} {
                continue
            }
            if {[dict exists $visited $neighbor]} {
                continue
            }
            $queue put [list $neighbor $steps]
            dict set visited $neighbor 1
        }
    }
    return $visible_keys
}

proc find_visible_doors {map posn} {
    set visible_doors {}
    set queue [::struct::queue]
    set visited [dict create]
    $queue put [list $posn 0]
    dict set visited $posn 1
    while {[$queue size] > 0} {
        lassign [$queue get] posn steps
        set c [map_get $map $posn]
        if {[is_door $c]} {
            lappend visible_doors [list $c $posn $steps]
            continue
        }
        incr steps
        foreach neighbor [neighborhood $posn] {
            set n [map_get $map $neighbor]
            if {$n == "#"} {
                continue
            }
            if {[dict exists $visited $neighbor]} {
                continue
            }
            $queue put [list $neighbor $steps]
            dict set visited $neighbor 1
        }
    }
    return $visible_doors
}
proc solve {map} {

    set key_posns [find_key_posns $map]
    set key_count 0
    dict for {k p} $key_posns {
        if {[string is lower $k]} {
            incr key_count
        }
    }
    set posn [dict get $key_posns "@"]
    set path {}
    set total_steps 0
    while {[llength $path] < $key_count} {
        puts "Path $path $total_steps"
        map_set map $posn .
        set visible_keys [find_visible_keys $map $posn]
        puts $visible_keys
        set visible_doors [find_visible_doors $map $posn]
        puts $visible_doors
        return

        set key [map_get $map $posn]
        lappend path $key
        incr total_steps $steps
        map_set map $posn +

        puts "found $posn $steps [map_get $map $posn]"

        if {$posn == ""} {
            puts "Cannot find key from $posn"
            puts [map_to_string $map]
        }
        set door [string toupper $key]
        if {[dict exists $key_posns $door]} {
            set door_posn [dict get $key_posns $door]
            puts "Unlocking $door @ $door_posn"
            map_set map $door_posn .
        }
        puts [map_to_string $map]
    }
    puts [map_to_string $map]
    puts "$path $total_steps"
    return


    set min_path {}
    set queue [::struct::prioqueue]
    $queue put [list [dict get $key_posns @] 0 {@}] 0
    while {[$queue size] > 0} {
        lassign [$queue get] posn steps keys
        # puts "$posn $steps $keys"
        if {$steps > $min_steps} {
            break
        }
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
            set steps0 [expr {$steps + $neighbor_steps}]
            set keys0 [concat $keys [list $neighbor_key]]
            $queue put [list $neighbor_posn $steps0 $keys0] -$steps0
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
