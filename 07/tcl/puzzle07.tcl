# Advent of Code 2019 :: Day 7 :: Amplification Circuit
# https://adventofcode.com/2019/day/7

source "../../lib/tcl/intcode.tcl"

proc next_permutation {lst} {
    # Find the largest index k such that a[k] < a[k + 1]. 
    # If no such index exists, the permutation is the last permutation.
    set list_length [llength $lst]
    set search_limit [expr {$list_length - 1}]
    set k -1
    set i 0
    for {set i 0} {$i < $search_limit} {incr i} {
        set a [lindex $lst $i]
        set b [lindex $lst [expr {$i+1}]]
        if {[string compare $a $b] < 0} {
            set k $i
        }
    }

    if {$k == -1} {
        return {}
    }

    # Find the largest index l greater than k such that a[k] < a[l].
    set ak [lindex $lst $k]
    set l -1
    for {set i [expr {$k+1}]} {$i < $list_length} {incr i} {
        set al [lindex $lst $i]
        if {[string compare $ak $al] < 0} {
            set l $i
        }
    }

    # Swap the value of a[k] with that of a[l].
    set t [lindex $lst $k]
    lset lst $k [lindex $lst $l]
    lset lst $l $t

    # Reverse the sequence from a[k + 1] up to and including the 
    # final element a[n].
    set lst0 [lrange $lst 0 $k]
    set tail [lreverse [lrange $lst [expr {$k+1}] end]]
    lappend lst0 {*}$tail
    return $lst0
}

proc solve_part1 {intcode} {
    set phase_settings [list 0 1 2 3 4]
    set max_output_signal 0
    while {$phase_settings != {}} {
        set input_signal 0
        foreach phase_setting $phase_settings {
            Intcode::init $intcode [list $phase_setting $input_signal]
            lassign [Intcode::run] intcode0 output_signal
            set input_signal [lindex $output_signal 0]
        }
        set phase_settings [next_permutation $phase_settings]
        set max_output_signal [::tcl::mathfunc::max $max_output_signal $output_signal]
    }
    return $max_output_signal
}

proc solve_part2 {intcode} {
    set phase_settings [list 5 6 7 8 9]
    set max_output_signal 0
    while {$phase_settings != {}} {

        set computers {}
        for {set i 0} {$i < 5} {incr i} {
            lappend computers [list $intcode 0]
        }
        set input_signal 0
        set ok 1

        for {set i 0} {$i < 5} {incr i} {
            lassign [lindex $computers $i] intcode0 ip0
            set phase_setting [lindex $phase_settings $i]
            Intcode::init $intcode0 [list $phase_setting $input_signal] $ip0 1
            lassign [Intcode::run] intcode1 output_signal ip1
            lset computers $i [list $intcode1 $ip1]
            set input_signal [lindex $output_signal end]
        }

        while {$ok} {
            for {set i 0} {$i < 5} {incr i} {
                lassign [lindex $computers $i] intcode0 ip0
                set phase_setting [lindex $phase_settings $i]
                Intcode::init $intcode0 [list $input_signal] $ip0 1
                lassign [Intcode::run] intcode1 output_signal ip1
                if {$::Intcode::halted} {
                    set ok 0
                }
                lset computers $i [list $intcode1 $ip1]
                set input_signal [lindex $output_signal end]
                if {[llength $output_signal] > 0} {
                    set max_output_signal [::tcl::mathfunc::max $max_output_signal [lindex $output_signal end]]
                }
            }
        }
        set phase_settings [next_permutation $phase_settings]

    }
    return $max_output_signal
}

if {$::argv0 == [info script]} {
    set input [string trim [read stdin]]
    set intcode [split $input ","]
    puts "Ths solution to part 1 is [solve_part1 $intcode]."
    puts "Ths solution to part 2 is [solve_part2 $intcode]."
}
