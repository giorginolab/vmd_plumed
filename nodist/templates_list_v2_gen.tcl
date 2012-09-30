#!/bin/tclsh

set unsubst {
proc Plumed::templates_list_v2 { } {
    return {  
	"Group definition"    "grp:   GROUP ATOMS=[chain A and name CA]"
	"Center of mass"      "com:   COM   ATOMS=[chain A and name CA]"
	"Ghost atom"          "%%GHOST"
	- -
	"Distance"            "%%DISTANCE"
	"Angle"               "%%ANGLE"
	"Torsion"             "%%TORSION"
        "Gyration radius"     "%%GYRATION"
	"Electric dipole"     "%%DIPOLE"
	"Coordination"        "%%COORDINATION"
	"Contact map"         "%%CONTACTMAP"
	- -
	"Alpha-helix"         "%%ALPHARMSD"
        "Parallel beta"       "%%PARABETARMSD"
	"Antiparallel beta"   "%%ANTIBETARMSD"
	"RMSD from structure" "%%RMSD"
	- -
	"Distances"           "%%DISTANCES"
	"Coordination number" "%%COORDINATIONNUMBER"
	- -
        "Energy"              "%%ENERGY"
	"Box volume"          "%%VOLUME"
	"Density"             "%%DENSITY"
	- -
	"CV Polynomial"       "%%COMBINE"
        "CV Math Function"    "%%MATHEVAL"
	"Path RMSD"           "%%PATHMSD"
	"Piecewise Function"  "%%PIECEWISE"
	"Sort vector CV"      "%%SORT"
	"Distance in CV space" "%%TARGET"
	- -
	"Restraint"           "%%RESTRAINT"
        "Moving restraint"    "%%MOVINGRESTRAINT"
    }
}
}


# Replace all the %%'s
while {[regexp {%%([A-Z]+)} $unsubst pkw kw]} {
    set fc [open templates/$kw]
    set templ [read $fc]
    close $fc
    puts "Replacing $pkw with $templ"
    set unsubst [regsub {$pkw} $unsubst $templ]
puts "$unsubst"

break
}



