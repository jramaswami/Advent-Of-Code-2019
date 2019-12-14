# Advent of Code 2019 :: Day 14 :: Space Stoichiometry
# https://adventofcode.com/2019/day/14
proc solve {input} {
    set lines [split $input "\n"]
    set quantity_made [dict create]
    set recipes [dict create]
    foreach line $lines {
        set i [string first "=" $line]
        set lhs [string range $line 0 [expr {$i - 2}]]
        set rhs [string range $line [expr {$i + 3}] end]

        lassign [lmap x [split $rhs " "] {string trim $x}] qty chem
        dict set quantity_made $chem $qty
        dict set recipes $chem [lmap x [split $lhs ","] {string trim $x}]
    }
    puts "$recipes"
    puts "$quantity_made"

    set queue [dict get $recipes FUEL]
    set final [dict create]
    set new_queue {}
    while {[llength $queue] > 0} {
        puts "Q: $queue"
        foreach item $queue {
            lassign $item quantity chemical
            set recipe [dict get $recipes $chemical]
            if {[llength $recipe] == 1 && [lindex [lindex $recipe 0] 1] == "ORE"} {
                puts "$chemical is a leaf node."
                dict incr final $chemical $quantity
            } else {
                puts "$chemical is not a leaf node."
                puts "recipe $recipe produces [dict get $quantity_made $chemical] $chemical"
                set made [dict get $quantity_made $chemical]
                set lots [expr {int(ceil(double($quantity) / double($made)))}]
                puts "$quantity of $chemical is needed, so $lots lots are required."
                foreach precursor $recipe {
                    puts "precursor $precursor"
                    lassign $precursor q c
                    set item0 [list [expr {$q * $lots}] $c]
                    puts "placing $item0 on queue"
                    lappend new_queue $item0
                }
            }
        }
        set queue $new_queue
        set new_queue {}
    }

    puts "final $final"
    set total_ore_required 0
    dict for {chemical quantity} $final {
        set recipe [dict get $recipes $chemical]
        set ore_required [lindex [lindex $recipe 0] 0]
        set made [dict get $quantity_made $chemical]
        set lots [expr {int(ceil(double($quantity) / double($made)))}]
        puts "$ore_required ore to make $made $chemical"
        puts "$quantity $chemical is needed, this is $lots lots"
        puts "so [expr {$lots * $ore_required}] ore is required"
        incr total_ore_required [expr {$lots * $ore_required}]
    }
    return $total_ore_required
}

proc main {} {
    set input [string trim [read stdin]]
    set soln1 [solve $input]
    puts "The solution to part 1 is $soln1."
}

if {$::argv0 == [info script]} {
    main
}
