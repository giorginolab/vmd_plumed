# VMD Plumed tool  - a GUI to compute collective variables
# over a trajectory
#
#     Copyright (C) 2012  National Research Council of Italy and
#                         Universitat Pompeu Fabra 
#
#     Author              Toni Giorgino  (toni.giorgino@isib.cnr.it)
#
#     This program is available under either the 3-clause BSD license,
#     (e.g. see http://www.ks.uiuc.edu/Research/vmd/plugins/pluginlicense.html)
#
# $Id: vmdplumed.tcl 1030M 2012-07-20 09:24:02Z (local) $ 

# To reload:
#  destroy .plumed; source vmdplumed.tcl; plumed_tk

package provide plumed 1.901
package require tile

# vmd_install_extension plumed plumed_tk "Analysis/Collective variable analysis (PLUMED)"

namespace eval ::Plumed:: {
    namespace export plumed
    variable debug 0
    variable highlight_error_ms 12000
    variable plugin_version 2.0a
    variable plumed_version 2
    variable w                                          ;# handle to main window
    variable textfile unnamed.plumed
    variable plugin_name "PLUMED-GUI collective variable analysis tool"
    variable driver_path "(Plumed not in path. Please install, or click 'Browse...' to locate it.)"
    variable text_instructions_header \
"Enter collective variable definitions below, in PLUMED syntax.  
Click 'Plot' to evaluate them on the 'top' trajectory.  
VMD atom selections in square brackets expand automatically."
    variable text_instructions_example_v1 \
"For example:

    protein-> \[chain A and name CA\] protein<-
    ligand->  \[chain B and noh\]          ligand<-

    DISTANCE LIST <protein> <ligand>
    COORD LIST <protein> <ligand>  NN 6 MM 12 D_0 5.0 R_0 0.5 "
    variable text_instructions_example_v2 \
"For example:

    protein: COM ATOMS=\[chain A and name CA\]
    ligand:  COM ATOMS=\[chain B and noh\]

    DISTANCE ATOMS=protein,ligand

*Note*: UNITS are nm, ps and kJ/mol unless specified.
Right mouse button provides help on keywords."
    variable empty_meta_inp_v1 "\nDISTANCE LIST 1 200      ! Just an example\n"
    variable empty_meta_inp_v2 "
UNITS  LENGTH=A  ENERGY=kcal/mol  TIME=fs

d1:    DISTANCE ATOMS=1,200                     # Just an example
"
}

proc plumed_tk {} {
    Plumed::plumed
    return $Plumed::w
}


proc ::Plumed::plumed {} { 
    variable w
    variable textfile
    variable plugin_name
    variable driver_path
    variable driver_path_v1
    variable driver_path_v2
    variable plumed_version
    variable pbc_type 1
    variable pbc_boxx
    variable pbc_boxy
    variable pbc_boxz
    variable plot_points 0
    variable text_instructions

    # If already initialized, just turn on
    if { [winfo exists .textview] } {
	wm deiconify $w
	return
    }

    variable file_types {
	{"Plumed Files" { .plumed .metainp .meta_inp } }
	{"Text Files" { .txt .TXT} }
	{"All Files" * }
    }

    set w [toplevel ".plumed"]
    wm title $w "$plugin_name"
#    wm resizable $w 0 0

    # Look for plumed (v2), then driver (v1)
    set driver_path_v1 /path/to/driver
    set driver_path_v2 /path/to/plumed
    set can_run 0

    set dr [ auto_execok driver ]
    if {$dr != ""} {
	set driver_path_v1 $dr 
	set plumed_version 1
	set can_run 1
    }
    set dr [ auto_execok plumed ]
    if {$dr != ""} {
	set driver_path_v2 $dr 
	set plumed_version 2
	set can_run 1
    }

    # If PBC exist, use them
    catch { molinfo top get {a b c} } vmdcell
    if { [llength $vmdcell] == 3 } {
	lassign $vmdcell a b c 
	if { [expr $a * $b * $c ] > 1.0 } {
	    lassign $vmdcell pbc_boxx pbc_boxy pbc_boxz
	}
    }


    ## MENU ============================================================
    frame $w.menubar -relief raised ;# frame for menubar
    pack $w.menubar -padx 1 -fill x

    ## file menu
     menubutton $w.menubar.file -text File -underline 0 -menu $w.menubar.file.menu
    menu $w.menubar.file.menu -tearoff no
    $w.menubar.file.menu add command -label "New" -command  Plumed::file_new
    $w.menubar.file.menu add command -label "Open..." -command Plumed::file_open
    $w.menubar.file.menu add command -label "Save" -command  Plumed::file_save -acce Ctrl-S
    $w.menubar.file.menu add command -label "Save as..." -command  Plumed::file_saveas
    $w.menubar.file.menu add command -label "Export..." -command  Plumed::file_export
    $w.menubar.file.menu add separator
#    FIXME REIMPLEMENT
#    $w.menubar.file.menu add command -label "Batch analysis..." -command  Plumed::batch_gui
#    $w.menubar.file.menu add separator
    $w.menubar.file.menu add command -label "Quit" -command  Plumed::file_quit
    $w.menubar.file config -width 5
    bind $w <Control-s> Plumed::file_save

    ## edit
     menubutton $w.menubar.edit -text Edit -underline 0 -menu $w.menubar.edit.menu
    menu $w.menubar.edit.menu -tearoff no
    $w.menubar.edit.menu add command -label "Undo" -command  "$::Plumed::w.txt.text edit undo" -acce Ctrl-Z
    $w.menubar.edit.menu add command -label "Redo" -command  "$::Plumed::w.txt.text edit redo"
    $w.menubar.edit.menu add separator
    $w.menubar.edit.menu add command -label "Cut" -command  "tk_textCut $::Plumed::w.txt.text" -acce Ctrl-X
    $w.menubar.edit.menu add command -label "Copy" -command  "tk_textCopy $::Plumed::w.txt.text" -acce Ctrl-C
    $w.menubar.edit.menu add command -label "Paste" -command  "tk_textPaste $::Plumed::w.txt.text" -acce Ctrl-V
    $w.menubar.edit config -width 5

    ## Templates
     menubutton $w.menubar.insert -text "Templates" -underline 0 -menu $w.menubar.insert.menu
    menu $w.menubar.insert.menu -tearoff yes
    # FIXME REMOVE templates_populate_menu
    $w.menubar.insert config -width 10

    ## Structural
     menubutton $w.menubar.structure -text Structure -underline 0 -menu $w.menubar.structure.menu
    menu $w.menubar.structure.menu -tearoff no
    $w.menubar.structure.menu add command -label "Build reference structure..." -command Plumed::reference_gui
    $w.menubar.structure.menu add command -label "Insert native contacts CV..." -command Plumed::nc_gui
    $w.menubar.structure.menu add command -label "Insert Ramachandran \u03c6/\u03c8/\u03c9 CVs..." \
	-command Plumed::rama_gui
    $w.menubar.structure config -width 8

    ## help menu
    ## FIXME plumed 2
     menubutton $w.menubar.help -text Help -underline 0 -menu $w.menubar.help.menu
    menu $w.menubar.help.menu -tearoff no
    $w.menubar.help.menu add command -label "Getting started" \
	-command "vmd_open_url http://www.multiscalelab.org/toni/PlumedCVTool"
    $w.menubar.help.menu add separator
    $w.menubar.help.menu add command -label "Help on PLUMED (v1.3)" \
        -command "vmd_open_url http://www.plumed-code.org"
    $w.menubar.help.menu add command -label "PLUMED user's guide and CV syntax (v1.3)" \
	-command "vmd_open_url http://www.plumed-code.org/documentation"
    $w.menubar.help.menu add command -label "How to install the 'driver' binary (v1.3)" \
	-command "vmd_open_url http://www.multiscalelab.org/toni/PlumedCVTool"
    $w.menubar.help.menu add separator
    $w.menubar.help.menu add command -label "About the $plugin_name" \
	-command [namespace current]::help_about
    # XXX - set menubutton width to avoid truncation in OS X
    $w.menubar.help config -width 5

    pack $w.menubar.file -side left
    pack $w.menubar.edit -side left
    pack $w.menubar.insert -side left
    pack $w.menubar.structure -side left
    pack $w.menubar.help -side right


    ## TEXT ============================================================
    frame $w.txt
    label $w.txt.label  -textvariable Plumed::textfile
    text $w.txt.text -wrap none -undo 1 -autoseparators 1 -bg #ffffff -bd 2 \
	-yscrollcommand "$::Plumed::w.txt.vscr set" -font {Courier 12}
    scrollbar $w.txt.vscr -command "$::Plumed::w.txt.text yview"
    label $w.txt.text.instructions -text "(...)" -justify left \
	-relief solid -padx 2m -pady 2m
    file_new
    $w.txt.text window create 1.0 -window $w.txt.text.instructions \
	-padx 100 -pady 10
    pack $w.txt.label            -fill x 
    pack $w.txt.text  -side left -fill both -expand 1
    pack $w.txt.vscr  -side left -fill y    -expand 0
    pack $w.txt                  -fill both -expand 1


    ## OPTIONS ============================================================
    pack [  ttk::labelframe $w.options -relief ridge  -text "Options"  ] \
	-side top -fill x

    pack [  ttk::frame $w.options.pbc   ]  -side top -fill x
    pack [  ttk::radiobutton $w.options.pbc.pbcno -value 1 -text "No PBC" \
	       -variable [namespace current]::pbc_type ] -side left
    pack [  ttk::radiobutton $w.options.pbc.pbcdcd -value 2 -text "From trajectory" \
	       -variable [namespace current]::pbc_type ] -side left
    pack [  ttk::radiobutton $w.options.pbc.pbcbox -value 3 -text "Box:" \
	       -variable [namespace current]::pbc_type ] -side left
    pack [  ttk::entry $w.options.pbc.boxx -width 6 -textvariable [namespace current]::pbc_boxx ] -side left
    pack [  ttk::entry $w.options.pbc.boxy -width 6 -textvariable [namespace current]::pbc_boxy ] -side left
    pack [  ttk::entry $w.options.pbc.boxz -width 6 -textvariable [namespace current]::pbc_boxz ] -side left
    pack [  ttk::label $w.options.pbc.spacer2 -text " " ] -side left -expand true -fill x
    pack [  ttk::checkbutton $w.options.pbc.inspector -text "Show data points" \
	       -variable  [namespace current]::plot_points ] -side left

    # ----------------------------------------
    pack [ frame $w.options.location ] -side top -fill x
    pack [  ttk::label $w.options.location.version -text "Plumed version:" ] -side left -expand 0
    pack [  ttk::radiobutton $w.options.location.v1 -value 1 -text "1.3"        \
	       -variable [namespace current]::plumed_version              \
     	       -command [namespace current]::plumed_version_changed    	  ] -side left 
    pack [  ttk::radiobutton $w.options.location.v2 -value 2 -text "2+"         \
	       -variable [namespace current]::plumed_version              \
     	       -command [namespace current]::plumed_version_changed       ] -side left 

    pack [  ttk::label $w.options.location.text -text "       Path to executable: " ] -side left -expand 0
    pack [  ttk::entry $w.options.location.path -width 40 -textvariable \
	       [namespace current]::driver_path ] -side left -expand 1 -fill x
    pack [  ttk::button $w.options.location.browse -text "Browse..." \
	   -command [namespace current]::location_browse   ] -side left -expand 0

    ## PLOT ============================================================
    pack [  ttk::frame $w.plot ] -side top -fill x
    pack [  ttk::button $w.plot.plot -text "Plot"   \
	   -command [namespace current]::do_compute ]  \
	-side left -fill x -expand 1 

    ## POPUP ============================================================
    menu $w.txt.text.popup -tearoff 0
    bind $w.txt.text <3> { ::Plumed::popup_menu %x %y %X %Y }


    ## FINALIZE ============================================================
    plumed_version_changed

    if {$can_run==0} {
	# Oddly, give time to extensions menu to close
	after 100 { 
	    tk_messageBox -icon warning -title "PLUMED not found" -parent .plumed -message "Neither `plumed' (v2) nor `driver' (v1) executables were found in path.\n\nAlthough you will be able to edit analysis scripts, you will not be able to run them.\n\nPlease see help menu for installation instructions."
	}
    }

}


# ==================================================


proc ::Plumed::empty_meta_inp {} {
    variable plumed_version
    variable empty_meta_inp_v1
    variable empty_meta_inp_v2
    switch $plumed_version {
	1  {return $empty_meta_inp_v1}
	2  {return $empty_meta_inp_v2}
    } 
}

proc ::Plumed::file_new { } {
    variable w
    variable textfile

    $w.txt.text delete 1.0 {end - 1c}
    set textfile "untitled.plumed"
    $w.txt.text insert end [empty_meta_inp]
}


proc ::Plumed::file_open { } {
    variable w
    variable textfile
    variable file_types

    set textfile [tk_getOpenFile -filetypes $file_types \
		      -initialfile "$Plumed::textfile"    ]

    if { $textfile == "" } { return }
    set rc [ catch { set fd [open $textfile "r"] } ]
    if { $rc == 1} { return }
    close $fd

    $w.txt.text delete 1.0 {end - 1c}
    $w.txt.text insert end [read_file $textfile ]
}

proc ::Plumed::file_save { } {
    variable w
    variable textfile

    if { $textfile == "untitled.plumed" } {
	Plumed::file_saveas
	return
    }

    set rc [ catch { set fd [open $textfile "w"] } ]
    if { $rc == 1} {
	tk_messageBox -title "Error" -parent .plumed -message "Failed to open file $textfile"
	return
    } else {
	puts $fd  [$w.txt.text get 1.0 {end -1c}] 
	close $fd
    }
}

proc ::Plumed::file_saveas { } {
    variable w
    variable file_types
    variable textfile

    set textfile [tk_getSaveFile -filetypes $file_types \
		       -initialfile $Plumed::textfile ]
    set rc [ catch { set fd [open $textfile "w"] } ]
    if { $rc == 1} {
	puts "failed to open file $textfile"
	return
    }
    puts $fd [$w.txt.text get 1.0 {end -1c}]
    close $fd
}

proc ::Plumed::file_export { } {
    variable w
    variable plumed_version
    set file_types {
	{"All Files" * }
    }
    set textfile [tk_getSaveFile -filetypes $file_types \
		       -initialfile "META_INP"       ]
    set rc [ catch { set fd [open $textfile "w"] } ]
    if { $rc == 1} {
	puts "failed to open file $textfile"
	return
    }
    puts $fd  [ Plumed::replace_serials [$w.txt.text get 1.0 {end -1c}] ]
    if {$plumed_version==1} { puts $fd  "ENDMETA" }
    close $fd
}


# Well, not really quit
proc ::Plumed::file_quit { } {
    variable w
    wm withdraw $w
}

# Browse for executable
proc ::Plumed::location_browse { } {
    variable driver_path
    set tmp [ tk_getOpenFile  ]
    if { $tmp != "" } {
	set driver_path $tmp
    }
}


proc ::Plumed::help_about { {parent .plumed} } {
    variable plugin_name
    variable plugin_version

    tk_messageBox -title "About" -parent $parent -message \
"
$plugin_name

Version $plugin_version

Toni Giorgino <toni.giorgino@isib.cnr.it>
Institute of Biomedical Engineering
National Research Council of Italy
ISIB-CNR

Copyright (c) 2010-2012

Consiglio Nazionale delle Ricerche,
Universitat Pompeu Fabra

\$Id: vmdplumed.tcl 1030M 2012-07-20 09:24:02Z (local) $
"
}



# ==================================================                                                 

# http://wiki.tcl.tk/772
proc ::Plumed::tmpdir { } {
    global tcl_platform
    switch $tcl_platform(platform) {
	unix {
	    set tmpdir /tmp   ;# or even $::env(TMPDIR), at times.
	} macintosh {
	    set tmpdir $::env(TRASH_FOLDER)  ;# a better place?
	} default {
	    set tmpdir [pwd]
	    catch {set tmpdir $::env(TMP)}
	    catch {set tmpdir $::env(TEMP)}
	}
    }
    return $tmpdir
}

# Write a PDB file using charges and masses in the topology
# (required by PLUMED's "driver" utility). 
proc ::Plumed::writePlumed { sel filename } {
    set old [ $sel get { x y z resid occupancy beta } ]

    $sel set x 0;		# workaround for xyz>1000 in PDB
    $sel set y 0
    $sel set z 0
    $sel set resid 1;	# workaround for PLUMED not reading ascii RESID
    $sel set occupancy [ $sel get mass ]	
    $sel set beta [ $sel get charge ]
    # FIXME: plumed does not read serial > 100k
    $sel writepdb $filename

    $sel set { x y z resid occupancy beta } $old
}


# TONI consider braces
proc ::Plumed::replace_serials { intxt }  {
    variable plumed_version
    set re {\[(.+?)\]}
    set lorig {}
    set lnew {}
    set lcount {}
    while { [ regexp $re $intxt junk orig ] } {
	lappend lorig $orig
	set as [ atomselect top $orig ]
	set new [ $as get serial ]
	$as delete
	lappend lcount [llength $new]
	if {$plumed_version==2} {
	    set new [string map { " " , } $new ]
	}
	lappend lnew $new
	regsub $re $intxt $new intxt
    }
    set out $intxt
    set out "$out
 
# The above script includes the following replacements, based on 
# a structure named [molinfo top get name] with [molinfo top get numatoms] atoms.\n#\n"
    foreach orig $lorig new $lnew cnt $lcount {
	set out "${out}# \[$orig\] -> (list of $cnt atoms)\n"
    }
    return $out
}


proc ::Plumed::transpose matrix {
    set cmd list
    set i -1
    foreach col [lindex $matrix 0] {append cmd " \$[incr i]"}
    foreach row $matrix {
        set i -1
        foreach col $row {lappend [incr i] $col}
    }
    eval $cmd
}


# Return the contents of a file
proc ::Plumed::read_file { fname } {
    set fd [open $fname r]
    set dtext [read $fd]
    close $fd
    return $dtext
}

# from rmsdtt
proc ::Plumed::index2rgb {i} {
  set len 2
  lassign [colorinfo rgb $i] r g b
  set r [expr int($r*255)]
  set g [expr int($g*255)]
  set b [expr int($b*255)]
  #puts "$i      $r $g $b"
  return [format "#%.${len}X%.${len}X%.${len}X" $r $g $b]
}

proc ::Plumed::dputs { text } {
    variable debug
    if {$debug} {
	puts "DEBUG: $text"
    }
}






# ==================================================

# TONI context menus http://www.megasolutions.net/tcl/right-click-menu-49868.aspx


# http://wiki.tcl.tk/16317
# possibly replace by tklib version

proc ::Plumed::setBalloonHelp {w msg args} {
  array set opt [concat {
      -tag ""
    } $args]
  if {$msg ne ""} then {
    set toolTipScript\
	[list [namespace current]::showBalloonHelp %W [string map {% %%} $msg]]
    set enterScript [list after 1000 $toolTipScript]
    set leaveScript [list after cancel $toolTipScript]
    append leaveScript \n [list after 200 [list destroy .balloonHelp]]
  } else {
    set enterScript {}
    set leaveScript {}
  }
  if {$opt(-tag) ne ""} then {
    switch -- [winfo class $w] {
      Text {
        $w tag bind $opt(-tag) <Enter> $enterScript
        $w tag bind $opt(-tag) <Leave> $leaveScript
      }
      Canvas {
        $w bind $opt(-tag) <Enter> $enterScript
        $w bind $opt(-tag) <Leave> $leaveScript
      }
      default {
        bind $w <Enter> $enterScript
        bind $w <Leave> $leaveScript
      }
    }
  } else {
    bind $w <Enter> $enterScript
    bind $w <Leave> $leaveScript
  }
}

proc ::Plumed::showBalloonHelp {w msg} {
  set t .balloonHelp
  catch {destroy $t}
  toplevel $t -bg black
  wm overrideredirect $t yes
  if {$::tcl_platform(platform) == "macintosh"} {
    unsupported1 style $t floating sideTitlebar
  }
  pack [label $t.l -text [subst $msg] -bg yellow -font {Helvetica 12}]\
    -padx 1\
    -pady 1
  set width [expr {[winfo reqwidth $t.l] + 2}]
  set height [expr {[winfo reqheight $t.l] + 2}]
  set xMax [expr {[winfo screenwidth $w] - $width}]
  set yMax [expr {[winfo screenheight $w] - $height}]
  set x [winfo pointerx $w]
  set y [expr {[winfo pointery $w] + 20}]
  if {$x > $xMax} then {
    set x $xMax
  }
  if {$y > $yMax} then {
    set y $yMax
  }
  wm geometry $t +$x+$y
  set destroyScript [list destroy .balloonHelp]
  bind $t <Enter> [list after cancel $destroyScript]
  bind $t <Leave> $destroyScript
}


# RAMACHANDRAN ==================================================                                                 

proc ::Plumed::rama_gui { } {
    if { [winfo exists .plumedrama] } {
	wm deiconify .plumedrama
	return
    }

    variable rama_sel "protein"
    variable rama_phi 1
    variable rama_psi 1
    variable rama_omega 0

    toplevel .plumedrama -bd 4
    wm title .plumedrama "Insert Ramachandran CVs"
    pack [ ttk::label .plumedrama.head1 -text "Insert CVs for the Ramachandran angles of the matched residues.
N-CA-C atom naming is assumed for backbone atoms.
Dihedrals involving atoms outside the selection are skipped.
" ] -side top -fill x 

    pack [ ttk::frame .plumedrama.sel ] -side top -fill x
    pack [ ttk::label .plumedrama.sel.txt -text "Selection: backbone and " ] -side left -fill x
    pack [ ttk::entry .plumedrama.sel.in -width 20 -textvariable [namespace current]::rama_sel ] -side left -expand 1 -fill x

    pack [ ttk::frame .plumedrama.cv ] -side top -fill x
    pack [ ttk::label .plumedrama.cv.txt -text "Dihedral angles: " ] -side left -fill x
    pack [ ttk::checkbutton .plumedrama.cv.phi -text Phi -variable  [namespace current]::rama_phi ] -side left
    pack [ ttk::checkbutton .plumedrama.cv.psi -text Psi -variable  [namespace current]::rama_psi ] -side left
    pack [ ttk::checkbutton .plumedrama.cv.omega -text Omega -variable  [namespace current]::rama_omega ] -side left

    pack [ ttk::frame .plumedrama.act ] -side top -fill x
    pack [ ttk::button .plumedrama.act.ok -text "Insert"  -command \
	       { Plumed::rama_insert } ] -side left -fill x -expand 1
    pack [ ttk::button .plumedrama.act.close -text "Close"  \
	       -command {  destroy .plumedrama }   ] -side left -fill x -expand 1

}

# Insert Ramachandran angles. Uses the following atoms
#       Cm   N CA C   Np CAp
# phi    +   +  + +
# psi        +  + +   +
# omega         + +   +  +
# where "m/p" means previous/next residue Computation is done on the
# base of "residue" (unique), but they will be printed as "resid"
# (human-readable)

proc ::Plumed::rama_insert {} {
    variable rama_sel
    variable rama_phi
    variable rama_psi
    variable rama_omega
    variable w

    set nnew 0

    set sel [atomselect top "($rama_sel) and name CA and backbone"]
    set rlist [lsort -integer -uniq [$sel get residue]]
    $sel delete

    if {[llength $rlist] == 0} {
	tk_messageBox -title "Error" -parent .plumedrama -message "Selection is empty."
	return	
    }

    foreach r $rlist {
	if {$r == 0} {
	    set rm1 1000000;	# non-existent residue, kludge not to atomselect a negative one
	} else {
	    set rm1 [expr $r-1]
	}
	set rp1 [expr $r+1]
	set Cm  [atomselect top "($rama_sel) and backbone and residue $rm1 and name C"]
	set N   [atomselect top "($rama_sel) and backbone and residue $r and name N"]
	set CA  [atomselect top "($rama_sel) and backbone and residue $r and name CA"]
	set C   [atomselect top "($rama_sel) and backbone and residue $r and name C"]
	set Np  [atomselect top "($rama_sel) and backbone and residue $rp1 and name N"]
	set CAp [atomselect top "($rama_sel) and backbone and residue $rp1 and name CA"]
	set rid [format "%s%d" [$CA get resname] [$CA get resid]]; # human readable
	if {$rama_phi && [rama_insert_cv_maybe $Cm $N $CA $C             PHI $rid] } { 	incr nnew }
	if {$rama_psi && [rama_insert_cv_maybe     $N $CA $C  $Np        PSI $rid] } {	incr nnew }
	if {$rama_omega && [rama_insert_cv_maybe      $CA $C  $Np $CAp  OMEGA $rid] } { incr nnew }
	$Cm delete; 
	$N delete; $CA delete; $C delete
	$Np delete; $CAp delete
    }
    $w.txt.text insert insert "# The above list contains $nnew Ramachandan CVs\n" 
}


# Return the line computing a torsion CV defined by the arguments iff all of them are valid
proc ::Plumed::rama_insert_cv_maybe {A B C D angle rid} {
    variable w
    variable plumed_version
    set cv_lines_v1_v2 { - "TORSION LIST %d %d %d %d  ! %s_%s\n"
	                   "TORSION ATOMS=%d,%d,%d,%d  LABEL=%s_%s\n" }
    set oos_msg "# No dihedral %s for residue %s: out of selection\n"
    set topo_msg "# No dihedral %s for residue %s: chain break\n"
    if { [$A num]==0 || [$B num]==0 || [$C num]==0 || [$D num]==0 } {
	set r [format $oos_msg $angle $rid]
	set ok 0
    } elseif { [llength [lsort -uniq -integer [list \
  	         [$A get fragment] [$B get fragment] [$C get fragment] [$D get fragment] ]]] != 1 } {
	# above; check that all fragment IDs are equal (check enforced on topology)
	# could also be segid or chain (check enforced on "logical" structure)
	set r [format $topo_msg $angle $rid]
	set ok 0
    } else {
	set cv_line [lindex $cv_lines_v1_v2 $plumed_version ]
	set r [format $cv_line  \
		   [$A get serial] [$B get serial] [$C get serial] [$D get serial]  \
		   $rid $angle ]
	set ok 1
    } 
    $w.txt.text insert insert $r
    return $ok
}





# BUILD REFERENCE ==================================================                                                 

proc ::Plumed::reference_gui { } {
    if { [winfo exists .plumedref] } {
	wm deiconify .plumedref
	return
    }

    variable refalign "backbone"
    variable refmeas "name CA"
    variable reffile "reference.pdb"
    variable refmol top
    variable ref_oneframe 0
    variable plumed_version

    if {$plumed_version==1} { set ref_oneframe 1 }

    toplevel .plumedref -bd 4
    wm title .plumedref "Build reference structure"
    pack [ ttk::label .plumedref.title -text "Convert top molecule's current frame\ninto a reference file for FRAMESET-type analysis:" ] -side top
    pack [ ttk::frame .plumedref.align ] -side top -fill x
    pack [ ttk::label .plumedref.align.aligntext -text "Alignment set: " ] -side left
    pack [ ttk::entry .plumedref.align.align -width 20 -textvariable [namespace current]::refalign ] -side left -expand 1 -fill x
    pack [ ttk::frame .plumedref.meas ] -side top -fill x
    pack [ ttk::label .plumedref.meas.meastext -text "Displacement set: " ] -side left
    pack [ ttk::entry .plumedref.meas.meas -width 20 -textvariable [namespace current]::refmeas ] -side left -expand 1 -fill x
    pack [ ttk::frame .plumedref.mol ] -side top -fill x
    pack [ ttk::label .plumedref.mol.moltext -text "Numbering for molecule: " ] -side left
    pack [ ttk::entry .plumedref.mol.mol -width 20 -textvariable [namespace current]::refmol ] -side left -expand 1 -fill x
    pack [ ttk::frame .plumedref.file ] -side top -fill x
    pack [ ttk::label .plumedref.file.filetxt -text "File to write: " ] -side left
    pack [ ttk::entry .plumedref.file.file -width 20 -textvariable [namespace current]::reffile ] -side left -expand 1 -fill x
    pack [ ttk::button .plumedref.file.filebrowse -text "Browse..." \
	       -command { Plumed::reference_set_reffile [ tk_getSaveFile  -initialfile "$::Plumed::reffile" ] }   ] -side left -expand 0
    pack [ ttk::checkbutton .plumedref.multiframe -text "Only current frame (Plumed 1)" -variable  [namespace current]::ref_oneframe ] -side top -fill x
    pack [ ttk::frame .plumedref.act ] -side top -fill x
    pack [ ttk::button .plumedref.act.ok -text "Write" -command \
	       { Plumed::reference_write } ] -side left -fill x -expand 1
    pack [ ttk::button .plumedref.act.cancel -text "Close" \
	       -command {  destroy .plumedref }   ] -side left -fill x -expand 1
}

proc ::Plumed::reference_set_reffile { x } { 
    variable reffile; 
    if { $x != "" } {set reffile $x} 
}; # why??


proc ::Plumed::reference_write {} {
    variable ref_oneframe
    variable reffile
 
   if [ catch {
	if { $ref_oneframe == 1 } {
	    reference_write_one $reffile now
	    puts "File $reffile written."
	} else {
	    # Could be vastly improved and refactored, considering that
	    # selections are constant
	    set nf [molinfo top get numframes]
	    set ofs [open $reffile w]
	    set tmpf [file join [ Plumed::tmpdir ] "reftmp.[pid].one.pdb" ]
	    for {set f 0} {$f<$nf} {incr f} {
		reference_write_one $tmpf $f
		set ifs [open $tmpf r]
		set dat [read -nonewline $ifs]
		puts $ofs "REMARK FRAME=$f"
		puts $ofs $dat
		puts $ofs "END"
		close $ifs
		file delete $tmpf
	    }
	    close $ofs
	    puts "Multi-frame $reffile ($nf frames) written."
	}
    } exc ] {
	tk_messageBox -title "Error" -parent .plumedref -message $exc
    }

}



# Uses class variables to get the selection strings
proc ::Plumed::reference_write_one { fileout frameno } {
    variable refalign
    variable refmeas
    variable refmol

    # From where new serials are taken
    set asnew [ atomselect $refmol "($refalign) or ($refmeas)" ]
    set newserial [ $asnew  get serial ]
    $asnew delete

    set asref [ atomselect top "($refalign) or ($refmeas)" ]
    set oldserial [ $asref  get serial ]

    
    if { [llength $oldserial] != [llength $newserial] } {
	$asref delete
	error "Selection ($refalign) or ($refmeas) matches a different number of atoms in molecule $refmol ([llength $newserial] matched atoms) with respect to the top molecule ([llength $oldserial] atoms)."
    }

    set asall [ atomselect top all]
    set asalign [ atomselect top $refalign ] 
    set asmeas  [ atomselect top $refmeas ] 

    set old [ $asall get {occupancy beta segname} ]; # backup
    
    $asall set occupancy 0
    $asall set beta 0
    $asall set segname XXXX
    
    $asalign set occupancy 1
    $asmeas  set beta 1
    $asref   set segname YYYY

    set tmpf [ file join [ Plumed::tmpdir ] "reftmp.[pid].pdb" ]
    $asall frame $frameno
    $asall writepdb $tmpf

    $asall set {occupancy beta segname} $old; # restore
    $asall delete
    $asref delete
    $asalign delete
    $asmeas delete

    # i.e. grep YYYY $tmpd/reftmp.pdb > $fileout
    # plumed <1.3 had a bug in PDB reader, which required
    # non-standard empty chain: ## set line [string replace $line 21 21 " "]
    set fdr [ open $tmpf r ]
    set fdw [ open $fileout w ]
    set i 0
    while { [gets $fdr line] != -1 } {
	if { [ regexp {YYYY} $line ] } {
	    # replace serial
	    set line [string replace $line 6 10 \
			  [ format "%5s" [ lindex $newserial $i ] ] ]
	    puts $fdw $line
	    incr i
	}
    }
    close $fdr
    close $fdw
    file delete $tmpf
}




# Alpha, parabeta, antibeta ordered lists ==================================================                                                 

proc ::Plumed::secondary_rmsd {N CA C O CB} {
    set Nsel [atomselect top $N]
    set CAsel [atomselect top $CA]
    set Csel [atomselect top $C]
    set Osel [atomselect top $O]
    set CBsel [atomselect top $CB]

    set ret {}
    set lens [list [$Nsel num] [$CAsel num] [$Csel num] [$Osel num] [$CBsel num]]
    set lens [lsort -integer -uniq $lens]
    if {[llength $lens] != 1} {
	puts "ERROR. Atom selection lengths are different: [$Nsel num] C, [$CAsel num] CA, [$Csel num] C, [$Osel num] O, [$CBsel num] CB"
    } else {
	set ret [list [$Nsel get serial] [$CAsel get serial] [$Csel get serial] [$Osel get serial] [$CBsel get serial]]
	set ret [transpose $ret]; # transpose
	set ret [concat {*}$ret]; # flatten
    }

    $Nsel delete
    $CAsel delete
    $Csel delete
    $Osel delete
    $CBsel delete
    return $ret
}



# BATCH ==================================================

proc ::Plumed::batch_gui {} {
    variable batch_dir
    variable batch_nthreads 1
    variable batch_extension colvar
    variable merge_results 0
    variable batch_keep 0
    variable batch_progress_width 400.0

    if { ! [ info exists batch_dir ] } { set batch_dir [pwd] }

    global tcl_platform
    if { $tcl_platform(platform) != "unix" } {
	tk_messageBox -title "Error" -parent .plumed -message "Sorry, unix only"; return; }

    toplevel .plumedbatch -bd 4
    wm title .plumedbatch "Batch analysis"
    pack [ label .plumedbatch.info -text "Process all DCD files in directory..." \
	        ] -side top -fill x 
    pack [ frame .plumedbatch.dir ] -side top -fill x
    pack [ entry .plumedbatch.dir.dir -width 60 -textvariable [namespace current]::batch_dir ] -side left -expand 1 -fill x
    pack [ button .plumedbatch.dir.dirbrowse -text "Browse..." -relief raised \
	       -command { Plumed::batch_setdir [ tk_chooseDirectory -mustexist 1 -parent .plumedbatch ] }   ] -side left -expand 0

    pack [ frame .plumedbatch.merge ] -side top -fill x
    pack [ checkbutton .plumedbatch.merge.button -text "Combine results"  -variable \
	       [namespace current]::merge_results -command Plumed::batch_update_gui ] -side left -fill x
    pack [ label .plumedbatch.merge.info  -relief sunken -bd 1 -text " " -pady 3] -side left   -fill x -expand 1

    pack [ frame .plumedbatch.threads ] -side top -fill x
    pack [ checkbutton .plumedbatch.threads.keep -text "Keep existing"  \
	   -variable  [namespace current]::batch_keep ] -side left -fill x 
    pack [ label .plumedbatch.threads.info2 -text "   File extension: " ] -side left -fill x
    pack [ entry .plumedbatch.threads.extension -width 15 -textvariable [namespace current]::batch_extension \
	       -validate key -validatecommand [list Plumed::batch_update_gui %P] ] \
	-side left -expand 1 -fill x
    pack [ label .plumedbatch.threads.info -text "Concurrent processes: " ] -side left -fill x
    pack [ entry .plumedbatch.threads.nthreads -width 5 -textvariable [namespace current]::batch_nthreads ] \
	-side left -expand 1 -fill x
    catch { set batch_nthreads [exec grep processor /proc/cpuinfo | wc -l] }

    pack [ canvas .plumedbatch.progress -relief sunken -bd 1 -width $batch_progress_width -height 20  ]  \
	-side top  -padx 10 -pady 10 -expand 1
    .plumedbatch.progress create rectangle 0 0 0 20 -tags bar -fill lavender
    .plumedbatch.progress create text [ expr $batch_progress_width / 2 ] 10 -tags text 

    pack [ frame .plumedbatch.act ] -side top -fill x
    pack [ button .plumedbatch.act.ok -text "Start" -relief raised -command \
	       { Plumed::batch_start } ] -side left -fill x -expand 1 
    pack [ button .plumedbatch.act.abort -text "Abort" -relief raised -command \
	       { set Plumed::batch_abort 1; Plumed::batch_abort_do } ] -side left -fill x -expand 1 
    pack [ button .plumedbatch.act.cancel -text "Close" -relief raised \
	       -command {  destroy .plumedbatch }   ] -side left -fill x -expand 1
    Plumed::batch_update_gui
}

proc ::Plumed::batch_setdir { x } { 
    variable batch_dir; if {$x != "" } {
	set batch_dir $x
	.plumedbatch.progress coords bar 0 0 0 20 
	.plumedbatch.progress itemconfigure text -text "Counting files..."
	update
	.plumedbatch.progress itemconfigure text -text [ format "%d files to process" \
	     [ llength [ glob -directory $batch_dir *.dcd ] ] ]
    } 
}

proc ::Plumed::batch_update_gui { { ext __UNSET__ } } {
    variable merge_results
    variable batch_extension
    if { $ext == "__UNSET__" } { 	# not called from validate
	set ext $batch_extension 
    }
    .plumedbatch.merge.info config -text \
	[ switch -- $merge_results  \
	      0 { format "Results will be stored in separate files: *.dcd -> *.dcd.$ext" } \
	      1 { format "A single '$ext.all' file will be created in the directory" } ]
    return 1
}

proc ::Plumed::batch_progress { x { y 100 } } { 
    variable batch_progress_width
    .plumedbatch.progress coords bar 0 0 [ expr {int($batch_progress_width*$x/$y) } ] 20 
    .plumedbatch.progress itemconfigure text -text [ format "Processed %d of %d" $x $y ]
}


# somewhat contrived implementation of a process pool
proc ::Plumed::batch_start { } {
    variable merge_results
    variable batch_nthreads 
    variable batch_ongoing {}
    variable batch_abort 0
    variable batch_ok 0
    variable batch_nfiles
    variable batch_extension
    variable batch_dir;		# must be absolute
    variable batch_keep
    variable driver_path

    .plumedbatch.progress itemconfigure text -text "Please wait..."

    set tmpd "[ Plumed::tmpdir ]/vmdplumed.[pid]"
    file mkdir $tmpd
    set owd [ pwd ]
    cd $tmpd

    set pdb temp.pdb
    writePlumed [atomselect top all] $pdb

    set meta META_INP
    write_meta_inp $meta

    set pbc [ get_pbc ]

    set filelist [ lsort -dictionary [ glob -directory $batch_dir *.dcd ] ]
    set batch_nfiles [ llength $filelist ]
    
    set fi 0;			# file index
    while { [llength $filelist] > 0  && !$batch_abort } {
	dputs "Batch ongoing is now $batch_ongoing"
	if { [llength $batch_ongoing] < $batch_nthreads } {
	    # spawn a new process, pop it from filelist and put it in batch_ongoing (kindof)
	    set fn [ lindex $filelist 0 ]
	    set filelist [ lreplace $filelist 0 0 ]

	    # if file exists and user requested not overwrite, skip
	    if { $batch_keep==1 && [file exists $fn.$batch_extension ] } {
		dputs "File  $fn.$batch_extension exists, skipping"
		incr batch_ok
		batch_progress $batch_ok $batch_nfiles
		continue
	    }

	    # else...
	    set dn batch.$fi;	# make a temp sub dir
	    cd $tmpd; file mkdir $dn; cd $tmpd/$dn
	    file link link.dcd $fn 
	    file link $pdb ../$pdb; # workaround: driver does not accept paths on cl
	    file link $meta ../$meta

	    set cmd "$driver_path -dcd link.dcd -pdb $pdb -plumed $meta $pbc"
	    puts "Processing $fn"
	    dputs "Spawning $cmd"
	    set io [ open "| $cmd 2>driver.stderr " r ]
	    lappend batch_ongoing $io
	    fconfigure $io -blocking 0
	    fileevent $io readable [ list Plumed::batch_event $io $fi $fn ]
	    incr fi
	} else {
	    dputs "C batch_ongoing $batch_ongoing"
	    update
	    dputs "D batch_ongoing $batch_ongoing"
	}
    }

    while { [llength $batch_ongoing] > 0 } {
	dputs "Still waiting for processes to finish"
	update
	dputs "F batch_ongoing $batch_ongoing"
    }

    catch { cd $owd }

    # cat, prepending file name
    if { $merge_results } {
	.plumedbatch.progress itemconfigure text -text "Merging results..."
	update
	set filelist [ lsort -dictionary [ glob -directory $batch_dir *.dcd ] ]
	set wch [ open "$batch_dir/$batch_extension.all" w ]
	foreach fn $filelist {
	    set fns [ file tail $fn ]
	    set rch [ open "$fn.$batch_extension" r ]
	    while {[gets $rch line] != -1} {
		if { [ regexp {^#} $line ] } { continue }
		puts $wch "$fns $line"
	    }
	    close $rch
	    if { $batch_keep==0 } {
		file delete "$fn.$batch_extension"
	    }
	}
	close $wch
    }

    .plumedbatch.progress itemconfigure text -text "Complete."
}


proc ::Plumed::batch_abort_do {  } {
    variable batch_ongoing
    set tmpd "[ Plumed::tmpdir ]/vmdplumed.[pid]"
    puts "Cleaning up [llength $batch_ongoing] ongoing processes."
    foreach fh $batch_ongoing {
	catch { close $fh }
    }
    foreach f [ glob $tmpd/batch.* ] {
	file delete -force $f
    }
    set batch_ongoing {}
    return
}

proc ::Plumed::batch_event { io findex fname } {
    variable batch_abort
    variable batch_nfiles
    variable batch_ok
    variable batch_ongoing
    variable batch_extension
    
    while { [gets $io line] != -1 } { }
    if { [eof $io] } {
	set tmpd "[ Plumed::tmpdir ]/vmdplumed.[pid]"
	set colvarfile "$tmpd/batch.$findex/COLVAR"
	if { ! [file exists $colvarfile] } {
	    puts "$line"
	    puts "-----------"
	    puts "Error processing file $fname, aborting. Check above output."
	    set batch_abort 1
	    batch_abort_do
	} else {
	    puts "File handle $io, index $findex, $fname completed ok"
	    incr batch_ok
	    Plumed::batch_progress $batch_ok $batch_nfiles
	    file rename -force $colvarfile $fname.$batch_extension
	    catch { close $io }
	    file delete -force $tmpd/batch.$findex
	    dputs "A batch_ongoing $batch_ongoing"
	    set batch_ongoing [ lreplace $batch_ongoing [ lsearch $batch_ongoing $io ] [ lsearch $batch_ongoing $io ] ]
	    dputs "B batch_ongoing $batch_ongoing"
	}
    }
}



# NATIVE CONTACTS ==================================================

proc ::Plumed::nc_gui { } { 
    if { [winfo exists .plumednc] } {
	wm deiconify .plumednc
	return
    }

    variable nc_selA "protein and name CA"
    variable nc_selB ""
    variable nc_cutoff 7
    variable nc_dresid 0
    variable nc_destmol top
    variable nc_groupname nc

    toplevel .plumednc -bd 4
    wm title .plumednc "Native contacts CV"
    pack [ ttk::label .plumednc.head1 -text "Insert a CV and group definitions required to define a native contacts CV.
The current frame of the top molecule is taken as the native state." ] -side top -fill x 

    pack [ ttk::frame .plumednc.sel1 ] -side top -fill x
    pack [ ttk::label .plumednc.sel1.txt -text "Selection 1: " ] -side left -fill x
    pack [ ttk::entry .plumednc.sel1.sel -width 50 -textvariable [namespace current]::nc_selA ] -side left -expand 1 -fill x

    pack [ ttk::frame .plumednc.sel2 ] -side top -fill x
    pack [ ttk::label .plumednc.sel2.txt -text "Selection 2 (optional): " ] -side left -fill x
    pack [ ttk::entry .plumednc.sel2.sel -width 40 -textvariable [namespace current]::nc_selB ] -side left -expand 1 -fill x

    pack [ ttk::frame .plumednc.cutoff ] -side top -fill x
    pack [ ttk::label .plumednc.cutoff.txt -text "Distance cutoff (A): " ] -side left -fill x
    pack [ ttk::entry .plumednc.cutoff.sel -width 10 -textvariable [namespace current]::nc_cutoff ] -side left -expand 1 -fill x
    pack [ ttk::label .plumednc.cutoff.txt2 -text "      Single selection: |\u0394 resid| \u2265 " ] -side left -fill x
    pack [ ttk::entry .plumednc.cutoff.dresid -width 10 -textvariable [namespace current]::nc_dresid ] -side left -expand 1 -fill x
    Plumed::setBalloonHelp .plumednc.cutoff.dresid "Consider contact pairs only if they span at least N monomers in the sequence (by resid attribute). 
   0 - consider all contact pairs;
   1 - ignore contacts within the same residue;
   2 - also ignore contacts between neighboring monomers; and so on."

    pack [ ttk::frame .plumednc.destmol ] -side top -fill x
    pack [ ttk::label .plumednc.destmol.txt -text "Target molecule ID: " ] -side left -fill x
    pack [ ttk::entry .plumednc.destmol.sel -width 10 -textvariable [namespace current]::nc_destmol ] -side left -expand 1 -fill x

    pack [ ttk::frame .plumednc.groupname ] -side top -fill x
    pack [ ttk::label .plumednc.groupname.txt -text "Prefix for PLUMED groups: " ] -side left -fill x
    pack [ ttk::entry .plumednc.groupname.sel -width 20 -textvariable [namespace current]::nc_groupname ] -side left -expand 1 -fill x

    pack [ ttk::label .plumednc.preview -text "Click `Count' to compute the number of contacts." ] -side top -fill x 

    pack [ ttk::frame .plumednc.act ] -side top -fill x
    pack [ ttk::button .plumednc.act.preview -text "Count"  -command \
	       { Plumed::nc_preview } ] -side left -fill x -expand 1 
    pack [ ttk::button .plumednc.act.insert -text "Insert"  -command \
	       { Plumed::nc_insert } ] -side left -fill x -expand 1 
    pack [ ttk::button .plumednc.act.close -text "Close"  \
	       -command {  destroy .plumednc }   ] -side left -fill x -expand 1
}


proc ::Plumed::nc_compute { } {
    variable nc_selA
    variable nc_selB
    variable nc_cutoff
    variable nc_destmol
    variable nc_dresid
    
    # See RMSD trajectory tool enhanced with native contacts
    # http://www.multiscalelab.org/utilities/RMSDTTNC
    set sel1 [ atomselect top $nc_selA ] 
    set sel2 [ atomselect $nc_destmol $nc_selA ]
    if { [$sel1 num] != [$sel2 num] } {
	tk_messageBox -title "Error" -parent .plumednc -message "Selection ($nc_selA) has different number of atoms in molecule top ([$sel1 num]) versus $nc_destmol ([$sel2 num])."
	return
    }

    if { $nc_selB != "" } {
	set sel1B [ atomselect top $nc_selB ] 
	set sel2B [ atomselect $nc_destmol $nc_selB ]
	if { [$sel1B num] != [$sel2B num] } {
	    tk_messageBox -title "Error" -parent .plumednc -message "Selection ($nc_selB) has different number of atoms in molecule top ([$sel1B num]) versus $nc_destmol ([$sel2B num])."
	    return
	}
    } else {
	set sel1B 0
	set sel2B 0 
    }

    # mapping index of top -> serials of $nc_destmol
    # sel1 and sel1B are in top
    # sel2 and sel2B are in $nc_destmol
    array set i1_s2 {}
    foreach idx1 [$sel1 get index]   ser2 [$sel2 get serial] {
	set i1_s2($idx1) $ser2
    }

    # Add atoms in selB if intermolecular
    if { $sel1B != 0 } {
	foreach idx1 [$sel1B get index]  ser2 [$sel2B get serial] {
	    set i1_s2($idx1) $ser2
	}
    }

    # Prepare list of resids in reference
    array set i1resid {}
    if { $sel1B == 0 } {
	foreach i [$sel1 get index] resid [$sel1 get resid] {
	    set i1resid($i) $resid
	}
    }

    # Get native contacts (sel1)
    if { $sel1B != 0 } {
	set nclist [transpose [ measure contacts $nc_cutoff $sel1 $sel1B ] ]
	puts "\nDEBUG: reference is [$sel1 text], sel1B is [$sel1B text], nclist has [llength $nclist]"
    } else {
	set nclist [transpose [ measure contacts $nc_cutoff $sel1 ] ]
    }
    set ncref_full [ llength $nclist ]

    # Convert pair list as atomnos, removing close pairs if needed
    set ncl {}
    foreach pairs $nclist {
	set i1 [lindex $pairs 0]
	set i2 [lindex $pairs 1]
	if { $sel1B == 0 } {
	    if { [ expr abs( $i1resid($i1) - $i1resid($i2) ) ] < $nc_dresid } {
		puts "DEBUG: Removing contact pair $i1-$i2 (resid $i1resid($i1) - $i1resid($i2) )"
		continue
	    }
	}
	set p1 $i1_s2($i1)
	set p2 $i1_s2($i2)
	lappend ncl [ list $p1 $p2 ]
    }

    puts "CONTACTS: [ llength $nclist ] in reference, [ llength $ncl ] after removing close resids"
    return $ncl
}

proc ::Plumed::nc_preview { } {
    .plumednc.preview configure -text "Counting, please wait..."
    update
    set ncl [ Plumed::nc_compute ]
    set ncn [ llength $ncl ]
    puts "NC: $ncl "
    .plumednc.preview configure -text "There are $ncn native contacts."
}


proc ::Plumed::nc_insert { } {
    variable nc_groupname 
    variable nc_cutoff
    variable plumed_version
    variable w

    set nc [ Plumed::nc_compute ]
    .plumednc.preview configure -text "There are [llength $nc] native contacts."
    if { [llength $nc ] == 0 } {
	tk_messageBox -title "Error" -parent .plumednc -message "There are no contacts in the currently selected frame."
	return
    }
    set ncl [ transpose $nc  ]

    switch $plumed_version {
	1 {
	    set txt1 "${nc_groupname}_1-> [lindex $ncl 0] ${nc_groupname}_1<-"
	    set txt2 "${nc_groupname}_2-> [lindex $ncl 1] ${nc_groupname}_2<-"
	    set txt3 "COORD LIST <${nc_groupname}_1> <${nc_groupname}_2> PAIR NN 6 MM 12 D_0 $nc_cutoff R_0 0.5"
	    $w.txt.text insert 1.0 "$txt1\n$txt2\n\n"
	    $w.txt.text insert insert "$txt3\n"
	} 
	2 {
	    set txt1 "${nc_groupname}_a: GROUP ATOMS={[lindex $ncl 0]}"
	    set txt2 "${nc_groupname}_b: GROUP ATOMS={[lindex $ncl 1]}"
	    set txt3 "nc:   COORDINATION GROUPA=${nc_groupname}_a GROUPB=${nc_groupname}_b  PAIR  D_0=$nc_cutoff R_0=0.5"
	    $w.txt.text insert insert "\n$txt1\n$txt2\n$txt3\n"
	}
    }

}

# ERROR HANDLING ==================================================


proc ::Plumed::get_label_from_line {line} {
    

}


proc ::Plumed::get_action_from_line {line} {
    

}



# Lookup label in v2 syntax
proc ::Plumed::highlight_error_label {label etext} {
    variable w
    variable highlight_error_ms
    set t $w.txt.text

    # match label prefixed by word boundary and followed by colon, or
    # prefixed by LABEL= and followed by word boundary. 
    set pos [$t search -regexp "(\\y$label:|LABEL=$label\\y)" 1.0]

    # The first half of the regexp should match only at the beginning
    # of the line, but some bug is gobbling all whitespace in
    # preceding lines.
    ## set pos [$t search -regexp "(^\\s*?$label:|LABEL=$label\\y)" 1.0]

    if {$pos != ""} {
	dputs "Label found at $pos"
	$t see $pos
	# lassign [split $pos .] line char
	# if {$char == 0} { incr line; set pos "$line.1" }
	## NOW highlight the line, show error, wait, remove hl
	$t tag add errorTag "$pos linestart" "$pos lineend"
	$t tag configure errorTag -background yellow -foreground red
	setBalloonHelp $t $etext -tag errorTag
	after $highlight_error_ms "$w.txt.text tag delete errorTag"
    } else {
	puts "Label not found in text area"
    }
}


# TEMPLATES ==================================================

proc ::Plumed::plumed_version_changed {} {
    instructions_update
    templates_populate_menu
    pbc_dcd_set_state
    driver_path_update
}

proc ::Plumed::pbc_dcd_set_state {} {
    variable w
    variable plumed_version
    switch $plumed_version {
	1 { $w.options.pbc.pbcdcd configure -state normal }
	2 { $w.options.pbc.pbcdcd configure -state disabled }
    }
}

proc ::Plumed::instructions_update {} {
    variable w
    variable plumed_version
    variable text_instructions_header
    variable text_instructions_example_v1
    variable text_instructions_example_v2
    switch $plumed_version {
	1 { set txt "$text_instructions_header $text_instructions_example_v1" }
	2 { set txt "$text_instructions_header $text_instructions_example_v2" }
    }
    catch { $w.txt.text.instructions configure -text $txt } err
}

proc ::Plumed::driver_path_update {} {
    variable plumed_version
    variable driver_path
    variable driver_path_v1
    variable driver_path_v2
    switch $plumed_version {
	1  {set driver_path $driver_path_v1}
	2  {set driver_path $driver_path_v2}
    } 
}

# ==================================================
# Templates

proc ::Plumed::templates_populate_menu {} {
    variable w
    variable plumed_version

    switch $plumed_version {
	1  {set templates [templates_list_v1]}
	2  {set templates [templates_list_v2]}
    } 

    $w.menubar.insert.menu delete 0 last
    foreach { disp insr } $templates {
	if {$disp == "-" } {
	    $w.menubar.insert.menu add separator
	} else {
	    $w.menubar.insert.menu add command -label $disp \
		-command [list $::Plumed::w.txt.text insert insert "$insr\n"]
	}
    }

    switch $plumed_version {
	1 {
	    bind $w <Control-g> "$::Plumed::w.menubar.insert.menu invoke 1" 
	    $w.menubar.insert.menu entryconfigure 1 -accelerator Ctrl-G
	}
	2 {
	    bind $w <Control-g> "$::Plumed::w.menubar.insert.menu invoke 1" 
	    $w.menubar.insert.menu entryconfigure 1 -accelerator Ctrl-G
	    bind $w <Control-m> "$::Plumed::w.menubar.insert.menu invoke 2" 
	    $w.menubar.insert.menu entryconfigure 2 -accelerator Ctrl-M
	}
    }
}
				      

# Plumed::templates_list_v1 is in a separate file in the same
# package

# Plumed::templates_list_v2 is in a separate, autogenerated
# file in the same package


# ==================================================
# Context-sensitive pop up

# Invoked upon right-click
proc ::Plumed::popup_menu {x y X Y} {
    variable plumed_version
    variable w
    variable template_keyword_hash
    variable template_full_hash

    # No menu for plumed 1
    if {$plumed_version==1} { return }

    # Get word at mouse
    set t $w.txt.text
    set word [$w.txt.text get "@$x,$y wordstart" "@$x,$y wordend"]
    set word [string trim $word]

    # Build popup
    $t.popup delete 0 last
    if {$word != ""} {
	set uword [string toupper $word]
	$t.popup add command -label "Lookup $uword in documentation..." \
	    -command "[namespace current]::popup_local_or_remote_help $uword"
	$t.popup add separator

	# Short template
	if { [info exists template_keyword_hash($uword)] } {
	    $t.popup add command -label {Insert template line below cursor} \
		-command "[namespace current]::popup_insert_line \{$template_keyword_hash($uword)\}"
	} else {
	    $t.popup add command -label "No template for keyword $uword" -state disabled
	}

	# Long template
	if { [info exists template_full_hash($uword)] } {
	    $t.popup add command -label {Insert full template line below cursor} \
		-command "[namespace current]::popup_insert_line \{$template_full_hash($uword)\}"

	    # Build lists of mandatory and optional keywords
	    set okw_l {}
	    set kw_l  {}
	    foreach kw $template_full_hash($uword) {
		if { $kw == $uword } { continue }
		if [ regexp {\[(.+)\]} $kw junk kw ] {
		    lappend okw_l $kw; # in brackets? push in optional
		} else { 
		    lappend kw_l $kw; # push in regular
		}
	    }
	    
	    if {[llength $kw_l] > 0} {
		$t.popup add separator
		$t.popup add command -label "Parameters:" -state disabled
		foreach kw $kw_l {
		    $t.popup add command -label "   $kw" \
			-command "[namespace current]::popup_insert_keyword $kw"
		}
	    }

	    if {[llength $okw_l] > 0} {
		$t.popup add separator
		$t.popup add command -label "Optional modifiers:" -state disabled
		foreach kw $okw_l {
		    $t.popup add command -label "   $kw" \
			-command "[namespace current]::popup_insert_keyword $kw"
		}
	    }
	}
    } else {
	$t.popup add command -label "No keyword here" -state disabled
    }
    tk_popup $w.txt.text.popup $X $Y
}

# Insert line below cursor
proc ::Plumed::popup_insert_line {line} {
    variable w
    $w.txt.text edit separator
    $w.txt.text insert {insert lineend} "\n# $line"
}

# Insert word at cursor
proc ::Plumed::popup_insert_keyword {kw} {
    variable w
    $w.txt.text edit separator
    $w.txt.text insert insert " $kw"
}


# Convert word to doxygen-generated filename
proc ::Plumed::popup_prepend_underscore {p} {
    set pu [string tolower $p];	# lower
    set pu [join [split $pu ""] _]; # intermix underscorse
    set pu [regsub {___} $pu __];   # ___ -> __
    return "_$pu";		    # prepend underscore
}

# Do what it takes to open Doxygen-generated help on keyword
proc ::Plumed::popup_local_or_remote_help {kw} {
    variable driver_path
    if {$kw == ""} { return }

    # Ask Plumed's path
    set root [exec $driver_path info --root]

    set kwlu [popup_prepend_underscore $kw]
    set htmlfile [file join $root user-doc html $kwlu.html]
    if [file readable $htmlfile] {
	vmd_open_url $htmlfile
    } else {
	# TODO lookup online
	tk_messageBox -icon error -title Error -parent .plumed \
	    -message "Sorry, help file not found for keyword $kw."
    }	
}



# ==================================================
# Version-independent stuff

proc ::Plumed::do_compute {} {
    variable plumed_version 
    variable driver_path

    if {[molinfo top]==-1 || [molinfo top get numframes] < 2} {
	tk_messageBox -title "Error" -parent .plumed -message \
	    "A top molecule and at least two frames are required to plot."
	return 
    }

    if {![file executable $driver_path]} { 
	tk_messageBox -title "Error" -parent .plumed -message \
	    "The plumed executable is required. See manual for installation instructions."
	return }

    # Delegate
    switch $plumed_version {
	1 do_compute_v1
	2 do_compute_v2
    }

}


# Assume a well-formed COLVAR file: one header line
# FIXME - assuming time is the first column
proc ::Plumed::do_plot { { out COLVAR } { txt ""  } } {
    variable w
    variable plot_points

    # slurp $out
    set fd [open $out r]
    set data {}
    set header {}
    set nlines 0
    while {[gets $fd line]>=0} {
	if [regexp {^#!} $line] {
	    set op [lindex $line 1]
	    if { $op == "FIELDS" } {
		# remove hash-FIELDS-time . Now header contains CV names
		set header [lreplace $line 0 2]
	    } else {
		continue;		# skip other headers (eg periodicity)
	    }
	} else {
	    lappend data $line
	    incr nlines
	}
    }
    close $fd

    if { [llength $header] == 0 } {
	puts "No FIELDS header line found. Please use PLUMED version >= 1.3 ."
	return
    } elseif { $nlines == 0 } {
	puts "No output in COLVAR. Please check above messages."
	return
    } elseif { $nlines == 1 } {
	puts "Single frame output. Omitting plot"
	return
    }

    set data [transpose $data]

    # pop the time column
    set ltime [lindex $data 0]
    set data [lreplace $data 0 0]
    set cv_n [llength $data]

    if { $plot_points } {
	set pt circle
    } else {
	set pt none
    }

    set cvplot [multiplot -title "Collective variables" -xlabel "Time" \
		    -nostats ]

    for { set i 0 } { $i < $cv_n } {incr i } {
	set coln [ expr ($i-1)%16 ]
	set color [index2rgb $coln]
	$cvplot add $ltime [lindex $data $i] -legend [lindex $header $i] \
	    -lines -marker $pt -radius 2 -fillcolor $color \
	    -color $color -nostats
    }

    $cvplot replot

}


# ==================================================                                                 
# V1-specific stuff

proc ::Plumed::write_meta_inp_v1 { meta } { 
    variable w
    set text [$w.txt.text get 1.0 {end -1c}]
    set fd [open $meta w]
    puts $fd [ Plumed::replace_serials $text ]
    puts $fd "PRINT W_STRIDE 1  ! line added by vmdplumed for visualization"
    puts $fd "ENDMETA" 
    close $fd
}

proc ::Plumed::get_pbc_v1 { } {
    variable pbc_type
    variable pbc_boxx
    variable pbc_boxy
    variable pbc_boxz
    set pbc [ switch $pbc_type {
	1 {format "-nopbc"}
	2 {format "" }
	3 {format "-cell $pbc_boxx $pbc_boxy $pbc_boxz" } } ]
    return $pbc
}

proc ::Plumed::do_compute_v1 {} {
    variable driver_path

    set tmpd "[ Plumed::tmpdir ]/vmdplumed.[pid]"
    file mkdir $tmpd
    set owd [ pwd ]
    cd $tmpd

    set dcd temp.dcd
    animate write dcd $dcd waitfor all

    set pdb temp.pdb
    Plumed::writePlumed [atomselect top all] $pdb

    set meta META_INP
    Plumed::write_meta_inp_v1 $meta

    set out COLVAR
    file delete $out
    set pbc [ get_pbc_v1 ]

    puts "Executing: $driver_path -dcd $dcd -pdb $pdb -plumed $meta  $pbc"
    if { [ catch { eval exec $driver_path -dcd $dcd -pdb $pdb -plumed $meta $pbc } driver_stdout ] } {
	set dontplot 1
    } else {
	set dontplot 0
    }

    puts $driver_stdout
    puts "-----------"
    puts "Temporary files are in directory $tmpd"
    cd $owd

    if { $dontplot } {
	puts "Something went wrong. Check above messages."
    } else {
	Plumed::do_plot "$tmpd/$out" "$driver_stdout"
    }
}


# ==================================================                                                 
# V2-specific stuff

proc ::Plumed::write_meta_inp_v2 { meta colvar } { 
    variable w
    set text [$w.txt.text get 1.0 {end -1c}]
    set fd [open $meta w]
    puts $fd [ Plumed::replace_serials $text ]
    puts $fd "# line added by vmdplumed for visualization"
    puts $fd "PRINT ARG=* FILE=$colvar"
    close $fd
}

proc ::Plumed::get_pbc_v2 { } {
    variable pbc_type
    variable pbc_boxx
    variable pbc_boxy
    variable pbc_boxz
    set largebox 100000
    set pbc [ switch $pbc_type {
	1 {format "$largebox,$largebox,$largebox"}
	2 {format "$largebox,$largebox,$largebox" }
	3 {format "$pbc_boxx,$pbc_boxy,$pbc_boxz" } } ]
    return $pbc
}

# Unlike v1, there is no need to cd 
proc ::Plumed::do_compute_v2 {} {
    variable driver_path

    set tmpd [file join [tmpdir] vmdplumed.[pid]]
    file mkdir $tmpd

    set meta [file join $tmpd META_INP]
    set pdb [file join $tmpd temp.pdb] 
    set xyz [file join $tmpd temp.xyz]
    set colvar [file join $tmpd COLVAR]

    write_meta_inp_v2 $meta $colvar
    writePlumed [atomselect top all] $pdb
    animate write xyz $xyz waitfor all
    file delete $colvar

    set pbc [get_pbc_v2]
    set cmd [list $driver_path --standalone-executable driver --ixyz $xyz --pdb $pdb --plumed $meta --box $pbc --length-units A]

    puts "Executing: $cmd"
    if { [ catch { eval exec $cmd } driver_stdout ] ||
	 ! [file readable $colvar]  } {
	set dontplot 1
    } else {
	set dontplot 0
    }

    puts $driver_stdout
    puts "-----------"
    puts "Temporary files are in directory $tmpd"

    if { $dontplot } {
	puts "Something went wrong. Check above messages."
	if [regexp -line {^PLUMED: ERROR .+ with label (.+?) : (.+)} \
		$driver_stdout junk label etext] {
	    dputs "Trying to highlight label $label -- $etext "
	    highlight_error_label $label $etext
	}
    } else {
	Plumed::do_plot $colvar $driver_stdout
    }
}








