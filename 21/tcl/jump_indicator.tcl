proc AND {X Y} {
    set lhs [set ::${X}]
    set rhs [set ::${Y}]
    set ::${Y} [expr {$rhs && $lhs}]
}

proc OR {X Y} {
    set lhs [set ::${X}]
    set rhs [set ::${Y}]
    set ::${Y} [expr {$rhs || $lhs}]
}

proc NOT {X Y} {
    set lhs [set ::${X}]
    set ::${Y} [expr {!$lhs}]
}

proc WALK {} { }

proc RUN {} { }

proc init_registers {} {
    foreach r {A B C D E F G H I T J} {
        set ::$r 0
    }
}

proc set_registers {bits registers} {
    foreach b [split $bits ""] r $registers {
        set ::${r} $b
    }
}

proc registers_to_string {registers} {
    lappend registers T
    lappend registers J
    set data {}
    foreach r $registers {
        lappend data "${r}[set ::$r]"
    }
    return [join $data " "]
}

proc part1_jump_indicator {} {
    set states [dict create]
    for {set i 0} {$i < 16} {incr i} {
        init_registers
        set bits [format "%04b" $i]
        set_registers $bits {A B C D}
        source part1_solution.ss
        set flag ""
        if {$::J} {
            set flag "*jumping*"
        }
        puts "$bits -> [registers_to_string {A B C D}] $flag"
    }
}

proc part2_jump_indicator {} {
    set limit [expr {pow(2,9)}]
    for {set i 0} {$i < $limit} {incr i} {
        init_registers
        set bits [format "%09b" $i]
        set_registers $bits {A B C D E F G H I}
        source part2_solution.ss
        set flag ""
        if {$::J} {
            set flag "*jumping*"
        }
        puts "$bits -> A$::A B$::B C$::C D$::D  E$::E F$::F G$::G H$::H I$::I T$::T J$::J $flag"
    }
}

if {$::argv0 == [info script]} {
    puts "Part 1 Jump Indicator"
    part1_jump_indicator
    puts "Part 2 Jump Indicator"
    part2_jump_indicator
}
