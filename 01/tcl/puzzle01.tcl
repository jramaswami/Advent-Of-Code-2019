# Advent of Code 2019 :: Day 1 :: The Tyranny of the Rocket Equation
# https://adventofcode.com/2019/day/1

proc fuel_required0 {module} {
    set total_fuel_required 0
    set fuel [fuel_required $module]
    while {$fuel > 0} {
        incr total_fuel_required $fuel
        set fuel [fuel_required $fuel]
    }
    return $total_fuel_required
}

proc fuel_required {module_mass} {
    return [expr {int($module_mass / 3) - 2}]
}

proc solve {modules} {
    set total_fuel_required 0
    set total_fuel_required0 0
    foreach module $modules {
        incr total_fuel_required [fuel_required $module]
        incr total_fuel_required0 [fuel_required0 $module]
    }
    return [list $total_fuel_required $total_fuel_required0]
}

if {$::argv0 == [info script]} {
    set input [string trimright [read stdin]]
    set modules [split $input "\n"]
    set soln [solve $modules]
    puts "The solution to part 1 is [lindex $soln 0]."
    puts "The solution to part 2 is [lindex $soln 1]."
}
