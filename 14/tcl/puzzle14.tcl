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

    set dists [dict create]
    dict set dists "ORE" 1
    set queue [list "ORE"]
    set new_queue {}
    while {[llength $queue] > 0} {
        foreach node $queue {
            if {$node == "FUEL"} {
                continue
            }
            set node_d [dict get $dists $node]
            foreach neighbor [dict get $graph $node] {
                if {![dict exists $dists $neighbor]} {
                    dict set dists $neighbor 0
                }
                set neighbor_d [dict get $dists $neighbor]
                dict set dists $neighbor [::tcl::mathfunc::max [expr {$node_d + 1}] $neighbor_d]
                lappend new_queue $neighbor
            }
        }
        incr d
        set queue $new_queue
        set new_queue {}
    }
    puts "dists immediate $dists"
    set dists0 {}
    dict for {node dist} $dists {
        lappend dists0 [list $node $dist]
    }
    set reductions [lmap x [lsort -index 1 -integer -decreasing $dists0] {lindex $x 0}]

    # Repeatedly reduce the formula until it cannot be further reduced
    set formula [dict get $recipes FUEL]
    foreach reduction [lrange $reductions 1 end-1] {
        puts "Reducing $reduction"
        puts "formula $formula"
        set needed [dict get $formula $reduction]
        dict unset formula $reduction
        set recipe [dict get $recipes $reduction]
        if {[dict exist $recipe "ORE"]} {
            puts "$reduction is leaf"
            dict incr formula $reduction $needed
        } else {
            set produced [dict get $quantities $reduction]
            set lots [expr {int(ceil(double($needed) / double($produced)))}]
            puts "$reduction $needed $produced -> $lots: $recipe"
            dict for {pre pre_q} $recipe {
                puts "enqueue $pre $pre_q -> [expr {$lots * $pre_q}]"
                dict incr formula $pre [expr {$lots * $pre_q}]
            }
        }
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
