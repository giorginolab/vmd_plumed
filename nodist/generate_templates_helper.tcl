#!/bin/tclsh

set unsubst {
package provide plumed 1.901
namespace eval Plumed {}
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
#        "Energy"              "%%ENERGY"
#	"Box volume"          "%%VOLUME"
#	"Density"             "%%DENSITY"
#	- -
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
	"Ratchet-pawl"        "%%ABMD"
	"Lower wall (allow higher)" "%%LOWER_WALLS"
	"Upper wall (allow lower)" "%%UPPER_WALLS"
    }
}
}


# Replace all the %%'s
while {[regexp {%%([A-Z_]+)} $unsubst pkw kw]} {
    set fc [open templates_temp/$kw]
    set templ [string trim [gets $fc]]
    close $fc
    puts stderr "Replacing $pkw with $templ"
    set unsubst [regsub $pkw $unsubst $templ]
}

puts "$unsubst"



