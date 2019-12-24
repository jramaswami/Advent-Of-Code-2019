# Advent of Code 2019 :: Day 24 :: Planet of Discord
# https://adventofcode.com/2019/day/24

namespace eval ::util {
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
}

namespace eval ::part1 {
    proc neighborhood {posn} {
        lassign $posn row col
        set u [list [expr {$row - 1}] $col]
        set d [list [expr {$row + 1}] $col]
        set l [list $row [expr {$col - 1}]]
        set r [list $row [expr {$col + 1}]]
        return [list $u $d $l $r]
    }

    proc count_neighbor_bugs {eris posn} {
        set neighbor_bugs 0
        foreach neighbor [neighborhood $posn] {
            if {[::util::inbounds $eris $neighbor]} {
                set neighbor_cell [::util::eris_get $eris $neighbor]
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
                set current_cell [::util::eris_get $eris $posn]
                set neighbor_bugs [count_neighbor_bugs $eris $posn]
                if {$current_cell == "#" && $neighbor_bugs != 1} {
                    set current_cell "."
                } elseif {$current_cell == "." && $neighbor_bugs == 1} {
                    set current_cell "#"
                } elseif {$current_cell == "." && $neighbor_bugs == 2} {
                    set current_cell "#"
                }
                ::util::eris_set new_eris $posn $current_cell
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
                set current_cell [::util::eris_get $eris $posn]
                if {$current_cell == "#"} {
                    incr bdr $pow2
                }
                set pow2 [expr {$pow2 * 2}]
            }
        }
        return $bdr
    }

    proc solve {eris} {
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
}

namespace eval ::part2 {

    proc erisr_get {erisr posn} {
        if {![dict exists $erisr $posn]} {
            return "."
        }
        return [dict get $erisr $posn]
    }

    proc erisr_set {erisr_var posn value} {
        upvar $erisr_var erisr
        dict set erisr $posn $value
    }

    proc neighborhood {posn} {
        lassign $posn level row col
        set neighbors {}
        # Up
        set urow [expr {$row - 1}]
        set ucol $col
        if {$urow < 0} {
            # Go up one level
            lappend neighbors [list [expr {$level + 1}] 1 2]
        } elseif {$urow == 2 && $ucol == 2} {
            # Center square; go one level down and add whole bottom row
            set l [expr {$level - 1}]
            for {set c 0} {$c < 5} {incr c} {
                lappend neighbors [list $l 4 $c]
            }
        } else {
            lappend neighbors [list $level $urow $ucol]
        }
        # Down
        set drow [expr {$row + 1}]
        set dcol $col
        if {$drow > 4} {
            # Go up one level
            lappend neighbors [list [expr {$level + 1}] 3 2]
        } elseif {$drow == 2 && $dcol == 2} {
            # Center square; go one level down and add whole top row
            set l [expr {$level - 1}]
            for {set c 0} {$c < 5} {incr c} {
                lappend neighbors [list $l 0 $c]
            }
        } else {
            lappend neighbors [list $level $drow $dcol]
        }
        # Left
        set lrow $row
        set lcol [expr {$col - 1}]
        if {$lcol < 0} {
            # Go up one level
            lappend neighbors [list [expr {$level + 1}] 2 1]
        } elseif {$lrow == 2 && $lcol == 2} {
            # Center square; go one level down and add whole right col
            set l [expr {$level - 1}]
            for {set r 0} {$r < 5} {incr r} {
                lappend neighbors [list $l $r 4]
            }
        } else {
            lappend neighbors [list $level $lrow $lcol]
        }
        # Right
        set rrow $row
        set rcol [expr {$col + 1}]
        if {$rcol > 4} {
            # Go up one level
            lappend neighbors [list [expr {$level + 1}] 2 3]
        } elseif {$rrow == 2 && $rcol == 2} {
            # Center square; go one level down and add whole left col
            set l [expr {$level - 1}]
            for {set r 0} {$r < 5} {incr r} {
                lappend neighbors [list $l $r 0]
            }
        } else {
            lappend neighbors [list $level $rrow $rcol]
        }
        return $neighbors
    }

    proc count_neighbor_bugs {erisr posn} {
        set neighbor_bugs 0
        set neighbors [neighborhood $posn]
        foreach neighbor $neighbors {
            set neighbor_cell [erisr_get $erisr $neighbor]
            if {$neighbor_cell == "#"} {
                incr neighbor_bugs
            }
        }
        return $neighbor_bugs
    }

    proc tick {t erisr} {
        set total_bugs 0
        set new_erisr $erisr
        for {set level -$t} {$level <= $t} {incr level} {
            for {set row 0} {$row < 5} {incr row} {
                for {set col 0} {$col < 5} {incr col} {
                    if {$row == 2 && $col == 2} {
                        continue
                    }
                    set posn [list $level $row $col]
                    set current_cell [erisr_get $erisr $posn]
                    set neighbor_bugs [count_neighbor_bugs $erisr $posn]
                    if {$current_cell == "#" && $neighbor_bugs != 1} {
                        set current_cell "."
                    } elseif {$current_cell == "." && $neighbor_bugs == 1} {
                        set current_cell "#"
                    } elseif {$current_cell == "." && $neighbor_bugs == 2} {
                        set current_cell "#"
                    }

                    if {$current_cell == "#"} {
                        incr total_bug_count
                    }
                    erisr_set new_erisr $posn $current_cell
                }
            }
        }
        return [list $new_erisr $total_bug_count]
    }

    proc init_erisr {eris} {
        set erisr [dict create]
        for {set row 0} {$row < [llength $eris]} {incr row} {
            set row_data [lindex $eris $row]
            for {set col 0} {$col < [llength [lindex $eris $row]]} {incr col} {
                set cell [lindex $row_data $col]
                dict set erisr [list 0 $row $col] $cell
            }
        }
        return $erisr
    }

    proc solve {eris} {
        set bug_count 0
        set erisr [init_erisr $eris]
        set tick_limit 200
        for {set t 1} {$t <= $tick_limit} {incr t} {
            lassign [tick $t $erisr] erisr bug_count
        }
        return $bug_count
    }
}

proc main {} {
    set input [string trim [read stdin]]
    set eris [lmap row [split $input "\n"] {split $row {}}]
    set soln1 [::part1::solve $eris]
    puts "The solution to part 1 is $soln1."
    set soln2 [::part2::solve $eris]
    puts "The solution to part 2 is $soln2."

    if {$soln1 != 3186366} {error "The solution to part 1 should be 3186366."}
    if {$soln2 != 2031} {error "The solution to part 2 should be 2031."}
}

if {$::argv0 == [info script]} {
    main
}
