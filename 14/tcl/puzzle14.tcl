# Advent of Code 2019 :: Day 14 :: Space Stoichiometry
# https://adventofcode.com/2019/day/14

proc solve {input} {
    # Parse input
    set lines [split $input "\n"]
    set quantities [dict create]
    set recipes [dict create]
    set graph [dict create]
    foreach line $lines {
        set i [string first "=" $line]
        set lhs [string range $line 0 [expr {$i - 2}]]
        set rhs [string range $line [expr {$i + 3}] end]

        lassign [lmap x [split $rhs " "] {string trim $x}] qty chem
        dict set quantities $chem $qty
        
        set recipe [dict create]
        foreach item [lmap x [split $lhs ","] {string trim $x}] {
            lassign $item q c
            dict lappend graph $c $chem
            dict set recipe $c $q
        }
        dict set recipes $chem $recipe
    }

    puts "graph $graph"
    set dists [dict create]
    set d 1
    set queue [dict get $graph "ORE"]
    set new_queue {}
    while {[llength $queue] > 0} {
        foreach node $queue {
            if {$node == "FUEL"} {
                puts "FUEL $d"
                continue
            }
            dict set dists $node $d
            foreach neighbor [dict get $graph $node] {
                lappend new_queue $neighbor
            }
        }
        incr d
        set queue $new_queue
        set new_queue {}
    }
    set dists0 {}
    dict for {node dist} $dists {
        lappend dists0 [list $node $dist]
    }
    set reductions [lmap x [lsort -index 1 -integer -decreasing $dists0] {lindex $x 0}]
    reductions "dists $dists"

    # Repeatedly reduce the formula until it cannot be further reduced
    set formula [dict get $recipes FUEL]
    set formula0 [dict create]
    set reduced 1
    while {$reduced} {
        set reduced 0
        puts "formula $formula"
        dict for {key needed} $formula {
            set recipe [dict get $recipes $key]
            if {[dict exist $recipe "ORE"]} {
                puts "$key is leaf"
                dict incr formula0 $key $needed
            } else {
                set reduced 1
                set produced [dict get $quantities $key]
                set lots [expr {int(ceil(double($needed) / double($produced)))}]
                puts "$key $needed $produced -> $lots: $recipe"
                dict for {pre pre_q} $recipe {
                    puts "enqueue $pre $pre_q -> [expr {$lots * $pre_q}]"
                    dict incr formula0 $pre [expr {$lots * $pre_q}]
                }
            }
        }
        puts "formula0 $formula0"
        set formula $formula0
        set formula0 [dict create]
    }

    # Compute cost in ore
    puts "Computing ..."
    set ore 0
    dict for {chem needed} $formula {
        set produced [dict get $quantities $chem]
        set lots [expr {int(ceil(double($needed) / double($produced)))}]
        set cost [lindex [dict get $recipes $chem] 1]
        puts "$chem $qty $lots $cost [expr {$cost * $lots}]"
        incr ore [expr {$cost * $lots}]
    }
    return $ore
}

proc main {} {
    set input [string trim [read stdin]]
    set soln1 [solve $input]
    puts "The solution to part 1 is $soln1."
}

if {$::argv0 == [info script]} {
    main
}
