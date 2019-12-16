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

proc phase {input_signal} {
    set pattern [list 0 1 0 -1]
    set fft [split $input_signal {}]
    set fft0 {}
    for {set i 1} {$i <= [llength $fft]} {incr i} {
        set k [expr {abs([run_pattern $fft $pattern $i]) % 10}]
        lappend fft0 $k
    }
    return [join $fft0 ""]
}

proc solve {input_signal phases} {
    for {set p 1} {$p <= $phases} {incr p} {
        puts "p $p"
        set input_signal [phase $input_signal]
    }
    return $input_signal
}

proc main {} {
    # 592817880 is too high.
    set input [string trim [read stdin]]
    set soln1 [string range [solve $input 100] 0 7]
    puts "The solution to part 1 is $soln1."

    if {$soln1 != 59281788} {error "The solution to part 1 should be 59281788."}
}

if {$::argv0 == [info script]} {
    main
}
