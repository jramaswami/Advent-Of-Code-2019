# Advent of Code 2019 :: Day 14 :: Space Stoichiometry
# https://adventofcode.com/2019/day/14

# Returns dictionary of recipes, quantities, and the order of reductions.
proc parse_input {input} {
    set lines [split $input "\n"]
    # Dictionary of the quantities produced by the formula/recipe
    set quantities [dict create]
    # Dictionary of recipes
    set recipes [dict create]
    # Graph used to determine the order of reductions
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

    # BFS to determine the maximum distance from ORE to the given chemical
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

    # Take the dictionary of distances and turn it into a list of pairs
    set dists0 {}
    dict for {node dist} $dists {
        lappend dists0 [list $node $dist]
    }

    # Sort the list of chemicals by distance to ORE (descending); this is the 
    # order of reductions.
    set reductions [lmap x [lsort -index 1 -integer -decreasing $dists0] {lindex $x 0}]

    return [list $recipes $quantities $reductions]
}

# Returns the amount of ore required to produce the given formula, which
# should be {FUEL n} where n is an integer greater than 0.
proc compute_ore_required {formula recipes quantities reductions} {

    # Loop over the reductions; remove the chemical under reduction from
    # the formula and add to the formula the chemicals required for the
    # chemical of reduction.
    foreach reduction [lrange $reductions 0 end-1] {
        set needed [dict get $formula $reduction]
        dict unset formula $reduction
        set recipe [dict get $recipes $reduction]
        if {[dict exist $recipe "ORE"]} {
            dict incr formula $reduction $needed
        } else {
            set produced [dict get $quantities $reduction]
            set lots [expr {int(ceil(double($needed) / double($produced)))}]
            dict for {pre pre_q} $recipe {
                dict incr formula $pre [expr {$lots * $pre_q}]
            }
        }
    }

    # Compute cost in ore for all the base chemicals left in the formula.
    set ore 0
    dict for {chem needed} $formula {
        set produced [dict get $quantities $chem]
        set lots [expr {int(ceil(double($needed) / double($produced)))}]
        set cost [lindex [dict get $recipes $chem] 1]
        incr ore [expr {$cost * $lots}]
    }
    return $ore
}

proc solve {input} {
    # Parse input
    lassign [parse_input $input] recipes quantities reductions

    # Reduce formula to find out how much ore is required for 1 unit of fuel.
    set formula [list FUEL 1]
    set soln1 [compute_ore_required $formula $recipes $quantities $reductions]

    # Binary search for the maximum amount of fuel that can be produced using
    # 1000000000000 units of ore or less.
    set soln2 1
    set low 2
    set high 100000000
    set limit 1000000000000
    while {$low <= $high} {
        set mid [expr {int(($low + $high) / 2)}]
        set ore [compute_ore_required [list FUEL $mid] $recipes $quantities $reductions]
        if {$ore < $limit} {
            set low [expr {$mid + 1}]
        } elseif {$ore > $limit} {
            set high [expr {$mid - 1}]
        } else {
            break
        }
    }
    
    # Binary search may return the amount of fuel produced by just more than
    # 1000000000000, if so, reduce the fuel by one unit.
    set ore [compute_ore_required [list FUEL $mid] $recipes $quantities $reductions]
    if {$ore > $limit} {
        incr mid -1
    }
    return [list $soln1 $mid]
}

proc main {} {
    set input [string trim [read stdin]]
    lassign [solve $input] soln1 soln2
    puts "The solution to part 1 is $soln1."
    puts "The solution to part 2 is $soln2."

    if {$soln1 != 136771} {error "The solution to part 1 should be 136771."}
    if {$soln2 != 8193614} {error "The solution to part 1 should be 8193614."}
}

if {$::argv0 == [info script]} {
    main
}
