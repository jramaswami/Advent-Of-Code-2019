# Advent of Code 2019 :: Day 12 :: The N-Body Problem
# https://adventofcode.com/2019/day/12

package require math::numtheory

proc parse_position {input} {
    scan $input "<x=%d, y=%d, z=%d>" x y z
    return [list $x $y $z]
}

proc potential_energy {position_vector} {
    set pe 0
    for {set axis 0} {$axis < 3} {incr axis} {
        incr pe [expr {abs([lindex $position_vector $axis])}]
    }
    return $pe
}

proc kinetic_energy {velocity_vector} {
    set ke 0
    for {set axis 0} {$axis < 3} {incr axis} {
        incr ke [expr {abs([lindex $velocity_vector $axis])}]
    }
    return $ke
}

proc add_vectors {v1 v2} {
    set v {}
    for {set i 0} {$i < 3} {incr i} {
        lappend v [expr {[lindex $v1 $i] + [lindex $v2 $i]}]
    }
    return $v
}

proc compute_deltas {moon1 moon2 position_var velocity_var} {
    upvar $position_var position
    upvar $velocity_var velocity
    set moon1_delta {}
    set moon2_delta {}
    for {set axis 0} {$axis < 3} {incr axis} {
        set m1 [lindex [set position($moon1)] $axis]
        set m2 [lindex [set position($moon2)] $axis]
        if {$m1 > $m2} {
            lappend moon1_delta -1
            lappend moon2_delta 1
        } elseif {$m1 < $m2} {
            lappend moon1_delta 1
            lappend moon2_delta -1
        } else {
            lappend moon1_delta 0
            lappend moon2_delta 0
        }
    }
    return [list $moon1_delta $moon2_delta]
}

proc apply_gravity {moons position_var velocity_var} {
    upvar $position_var position
    upvar $velocity_var velocity
    
    # Init deltas
    foreach moon $moons {
        set delta($moon) [list 0 0 0]
    }

    # Compute deltas
    for {set i 0} {$i < [llength $moons]} {incr i} {
        set moon1 [lindex $moons $i]
        for {set j [expr {$i + 1}]} {$j < [llength $moons]} {incr j} {
            set moon2 [lindex $moons $j]
            lassign [compute_deltas $moon1 $moon2 position velocity] moon1_delta moon2_delta
            set delta($moon1) [add_vectors [set delta($moon1)] $moon1_delta]
            set delta($moon2) [add_vectors [set delta($moon2)] $moon2_delta]
        }
    }

    # Apply deltas
    foreach moon $moons {
        set velocity($moon) [add_vectors [set velocity($moon)] [set delta($moon)]]
    }
}

proc move_moons {moons position_var velocity_var} {
    upvar $position_var position
    upvar $velocity_var velocity
    foreach moon $moons {
        set position($moon) [add_vectors [set position($moon)] [set velocity($moon)]]
    }
}

proc tick {moons position_var velocity_var} {
    upvar $position_var position
    upvar $velocity_var velocity

    apply_gravity $moons position velocity
    move_moons $moons position velocity
}
    
proc compute_total_energy {moons position_var velocity_var} {
    upvar $position_var position
    upvar $velocity_var velocity
    set total_energy 0
    foreach moon $moons {
        set pe [potential_energy [set position($moon)]]
        set ke [potential_energy [set velocity($moon)]]
        incr total_energy [expr {$pe * $ke}]
    }
    return $total_energy
}

proc make_axis_state {moons position_var velocity_var axis} {
    upvar $position_var position
    upvar $velocity_var velocity
    set state {}
    foreach moon $moons {
        set p [lindex [set position($moon)] $axis]
        set v [lindex [set velocity($moon)] $axis]
        lappend state [list $p $v]
    }
    return $state
}

# Solve puzzle.
# Part 1 is looking for the total energy of system at part1_ticks.
# Part 2 is looking for the period of the entire system.  This can be
# worked out by finding the period of each axis.  The period of the whole
# system is the LCM of the periods of each individual axis.
proc solve {moons position_var velocity_var part1_ticks} {
    upvar $position_var position
    upvar $velocity_var velocity

    set x_states [dict create [make_axis_state $moons position velocity 0] 1]
    set y_states [dict create [make_axis_state $moons position velocity 1] 1]
    set z_states [dict create [make_axis_state $moons position velocity 2] 1]
    set x_period 0
    set y_period 0
    set z_period 0

    set total_energy 0
    set t 0

    while {[expr {($x_period == 0) || ($y_period == 0) || ($z_period == 0)}]} {
        tick $moons position velocity
        incr t
        if {$t == $part1_ticks} {
            set total_energy [compute_total_energy $moons position velocity]
        }

        if {$x_period == 0} {
            set x_state [make_axis_state $moons position velocity 0]
            if {[dict exists $x_states $x_state]} {
                set x_period $t
            }
        }
        if {$y_period == 0} {
            set y_state [make_axis_state $moons position velocity 1]
            if {[dict exists $y_states $y_state]} {
                set y_period $t
            }
        }
        if {$z_period == 0} {
            set z_state [make_axis_state $moons position velocity 2]
            if {[dict exists $z_states $z_state]} {
                set z_period $t
            }
        }
    }
    set period [::math::numtheory::lcm [::math::numtheory::lcm $x_period $y_period] $z_period]
    return [list $total_energy $period]
}

proc main {} {
    # Read and parse input, placing data in position and velocity arrays
    set lines [split [string trim [read stdin]] "\n"]
    set moons [list io europa ganymeded callisto]
    for {set m 0} {$m < 4} {incr m} {
        set name [lindex $moons $m]
        set position($name) [parse_position [lindex $lines $m]]
        # Intitial velocity is 0 on all axes.
        set velocity($name) [list 0 0 0]
    }

    lassign [solve $moons position velocity 1000] soln1 soln2

    puts "The solution to part 1 is $soln1."
    puts "The solution to part 2 is $soln2."

    if {$soln1 != 7179} {error "Solution to part 1 should be 7179."}
    if {$soln2 != 428576638953552} {error "Solution to part 2 should be 428576638953552."}
}

if {$::argv0 == [info script]} {
    main
}
