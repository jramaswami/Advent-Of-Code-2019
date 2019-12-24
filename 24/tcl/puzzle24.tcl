# Advent of Code 2019 :: Day 24 :: Planet of Discord
# https://adventofcode.com/2019/day/24

proc neighborhood {posn} {
    lassign $posn row col
    set u [list [expr {$row - 1}] $col]
    set d [list [expr {$row + 1}] $col]
    set l [list $row [expr {$col - 1}]]
    set r [list $row [expr {$col + 1}]]
    return [list $u $d $l $r]
}

proc inbounds {eris posn} {
    lassign $posn row col
    if {$row < 0} {return 0}
    if {$row >= [llength $eris]} {return 0}
    if {$col < 0} {return 0}
    if {$col >= [llength [lindex $eris $row]]} {return 0}
    return 1
}

proc eris_get {eris posn} {
    lassign $posn row col
    set row_data [lindex $eris $row]
    return [lindex $row_data $col]
}

proc eris_set {eris_var posn value} {
    upvar $eris_var eris
    lassign $posn row col
    lset eris $row $col $value
}

proc eris_to_string {eris} {
    return [join [lmap row $eris {join $row {}}] "\n"]
}

proc count_neighbor_bugs {eris posn} {
    set neighbor_bugs 0
    foreach neighbor [neighborhood $posn] {
        if {[inbounds $eris $neighbor]} {
            set neighbor_cell [eris_get $eris $neighbor]
            if {$neighbor_cell == "#"} {
                incr neighbor_bugs
            }
        }
    }
    return $neighbor_bugs
}

proc tick {eris} {
    set new_eris $eris
    for {set row 0} {$row < [llength $eris]} {incr row} {
        for {set col 0} {$col < [llength [lindex $eris $row]]} {incr col} {
            set posn [list $row $col]
            set current_cell [eris_get $eris $posn]
            set neighbor_bugs [count_neighbor_bugs $eris $posn]
            if {$current_cell == "#" && $neighbor_bugs != 1} {
                set current_cell "."
            } elseif {$current_cell == "." && $neighbor_bugs == 1} {
                set current_cell "#"
            } elseif {$current_cell == "." && $neighbor_bugs == 2} {
                set current_cell "#"
            }
            eris_set new_eris $posn $current_cell
        }
    }
    return $new_eris
}

proc biodiversity_rating {eris} {
    set bdr 0
    set pow2 1
    for {set row 0} {$row < [llength $eris]} {incr row} {
        for {set col 0} {$col < [llength [lindex $eris $row]]} {incr col} {
            set posn [list $row $col]
            set current_cell [eris_get $eris $posn]
            if {$current_cell == "#"} {
                incr bdr $pow2
            }
            set pow2 [expr {$pow2 * 2}]
        }
    }
    return $bdr
}

proc solve_part1 {eris} {
    set states [dict create]
    dict set states $eris 1
    while {1} {
        set eris [tick $eris]
        if {[dict exists $states $eris]} {
            break
        }
        dict set states $eris 1
    }
    return [biodiversity_rating $eris]
}

proc main {} {
    set input [string trim [read stdin]]
    set eris [lmap row [split $input "\n"] {split $row {}}]
    set soln1 [solve_part1 $eris]
    puts "The solution to part 1 is $soln1."

    if {$soln1 != 3186366} {error "The solution to part 1 should be 3186366."}
}

if {$::argv0 == [info script]} {
    main
}
