#!/bin/tclsh

set unsubst {
package provide plumed 1.901
namespace eval ::Plumed {}
proc ::Plumed::templates_list_v2 { } {
    return {  
	"Group definition"    "grp:   GROUP ATOMS=[chain A and name CA]"
	"Center of mass"      "com:   COM   ATOMS=[chain A and name CA]"
	"Ghost atom"          "%%GHOST"
	- -
	"Distance"            "%%DISTANCE"
	"Angle"               "%%ANGLE"
	"Torsion"             "%%TORSION"
        "Radius of gyration"  "%%GYRATION"
	"Electric dipole"     "%%DIPOLE"
	"Coordination"        "%%COORDINATION"
	"Contact map"         "%%CONTACTMAP"
	- -
	"Amount of \u03b1-helical structure"        "%%ALPHARMSD"
        "Amount of parallel-\u03b2 structure"       "%%PARABETARMSD"
	"Amount of antiparallel-\u03b2 structure"   "%%ANTIBETARMSD"
	"RMSD from reference structure"             "%%RMSD"
	- -
	"Distances"           "%%DISTANCES"
	"Coordination number" "%%COORDINATIONNUMBER"
	- -
	"Path RMSD"           "%%PATHMSD"
	"Polynomial CV function"  "%%COMBINE"
	"Piecewise function"  "%%PIECEWISE"
	"Sort CV vector"      "%%SORT"
	"Distance in CV space" "%%TARGET"
	- -
	"Restraint"           "%%RESTRAINT"
        "Moving restraint"    "%%MOVINGRESTRAINT"
	"Metadynamics"        "%%METAD"
	"External"            "%%EXTERNAL"
	"Adiabatic bias"      "%%ABMD"
	"Lower wall (allow higher)" "%%LOWER_WALLS"
	"Upper wall (allow lower)"  "%%UPPER_WALLS"
    }
}
}

#        "Energy"              "%%ENERGY"
#	"Box volume"          "%%VOLUME"
#	"Density"             "%%DENSITY"
#	- -


# Replace all the %%'s
while {[regexp {%%([A-Z_]+)} $unsubst pkw kw]} {
    set fc [open templates_temp/$kw]
    set templ [string trim [gets $fc]]
    close $fc
#    puts stderr [format "%20s --> %s" $kw $templ]
    set unsubst [regsub $pkw $unsubst $templ]
}

# ----------------------------------------
# Part 1: the menu

puts "# AUTOGENERATED! DO NOT EDIT! on [exec date]"
puts "$unsubst"

# ----------------------------------------
# Part 2: popup to insert "short" template

# Generate keyword-help hashes for ALL keywords
puts "namespace eval ::Plumed {"
puts "  variable template_keyword_hash"
puts "  array set template_keyword_hash {"
foreach fkw [glob templates_temp/*] {
    set kw [file tail $fkw]
    set fc [open $fkw]
    set templ [string trim [gets $fc]]
    close $fc
    set templ [string map { " selection>" _selection> } $templ]
    puts "  {$kw} {$templ}"
}
puts "  }"
puts "}"


# ----------------------------------------
# Part 3: popup to insert full template keywords

puts "namespace eval ::Plumed {"
puts "  variable template_full_hash"
puts "  array set template_full_hash {"
foreach fkw [glob templates_full/*] {
    set kw [file tail $fkw]
    set fc [open $fkw]
    set templ [string trim [gets $fc]]
    close $fc
    # kludge to only have spaces as option separators
    set templ [string map { " selection>" _selection> } $templ]
    puts "  {$kw} {$templ}"
}
puts "  }"
puts "}"


