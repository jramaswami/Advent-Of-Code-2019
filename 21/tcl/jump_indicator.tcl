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
    # puts "NOT $X $Y $X -> $lhs $Y -> [set ::${Y}]"
}

proc WALK {} { }

proc part1_jump_indicator {} {
    set states [dict create]
    for {set i 0} {$i < 16} {incr i} {
        set ::T 0
        set ::J 0
        set ::A 0
        set ::B 0
        set ::C 0
        set ::D 0
        set bits [format "%04b" $i]
        foreach b [split $bits ""] r {A B C D} {
            set ::${r} $b
        }
        source part1_solution.ss
        set flag ""
        if {$::J} {
            set flag "*jumping*"
        }
        puts "$bits -> A $::A B $::B C $::C D $::D T $::T J $::J $flag"
    }
}

if {$::argv0 == [info script]} {
    puts "Part 1 Jump Indicator"
    part1_jump_indicator
}
