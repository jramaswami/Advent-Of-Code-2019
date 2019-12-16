# Advent of Code 2019 :: Day 16 :: Flawed Frequency Transmission
# https://adventofcode.com/2019/day/16

proc multiply_pattern {pattern mul} {
    set pattern0 {}
    foreach p $pattern {
        set pattern0 [concat $pattern0 [lrepeat $mul $p]]
    }
    return $pattern0
}

proc run_pattern {fft pattern index} {
    set t 0
    set pattern0 [multiply_pattern $pattern $index]
    for {set i 0; set j 1} {$i < [llength $fft]} {incr i; incr j} {
        if {$j == [llength $pattern0]} {
            set j 0
        }
        set f [lindex $fft $i]
        set p [lindex $pattern0 $j]
        incr t [expr {$f * $p}]
    }
    return $t
}

proc ladd {l} {::tcl::mathop::+ {*}$l}

proc phase {input_signal} {
    set pattern [list 0 1 0 -1]
    set fft [split $input_signal {}]
    set fft0 {}
    set start 0
    set len 1
    while {$start < [llength $fft]} {
        set st 0
        set sn 1
        set step [expr {$len + 1}]
        set b $start
        while {$b < [llength $fft]} {
            set e [expr {$b + $len - 1}]
            set sublist [lrange $fft $b $e]
            set sublist0 [lmap x $sublist {expr {$sn * $x}}]
            incr st [ladd $sublist0]
            set sn [expr {-1 * $sn}]
            set b [expr {$e + $step}]
        }
        set t [expr {abs($st) % 10}]
        lappend fft0 $t

        incr len
        incr start
    }
    return [join $fft0 ""]
}

proc solve {input_signal phases} {
    for {set p 1} {$p <= $phases} {incr p} {
        puts "$p"
        set input_signal [phase $input_signal]
    }
    return $input_signal
}

proc main {} {
    # 592817880 is too high.
    set input [string trim [read stdin]]
    set soln1 [string range [solve $input 100] 0 7]
    puts "The solution to part 1 is $soln1."
    set input [string repeat $input 10000]
    puts [solve $input 100]

    if {$soln1 != 59281788} {error "The solution to part 1 should be 59281788."}
}

if {$::argv0 == [info script]} {
    main
}
