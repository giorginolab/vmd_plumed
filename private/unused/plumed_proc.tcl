# Allow invokation of PLUMED from VMD
# Limitations: does not support PBC
# Make sure you have a psf or prmtop loaded if using masses/charges

# Example:
# source plumed_proc.tcl
# Plumed::plumed 1 {
#  lig-> [resname LIG] lig<-
#  POSITION LIST <lig>   DIR Z
# }

namespace eval Plumed:: {}

# Write a PDB file using charges and masses in the topology
# (required by PLUMED's "driver" utility). 
proc Plumed::writePlumed { sel filename } {
    set old [ $sel get { x y z resid occupancy beta } ]

    $sel set x 0;		# workaround for xyz>1000 in PDB
    $sel set y 0
    $sel set z 0
    $sel set resid 1;	# workaround for PLUMED not reading ascii RESID
    $sel set occupancy [ $sel get mass ]	
    $sel set beta [ $sel get charge ]

    $sel writepdb $filename

    $sel set { x y z resid occupancy beta } $old
}



proc Plumed::transpose matrix {
    set cmd list
    set i -1
    foreach col [lindex $matrix 0] {append cmd " \$[incr i]"}
    foreach row $matrix {
        set i -1
        foreach col $row {lappend [incr i] $col}
    }
    eval $cmd
}


proc Plumed::replace_serials { intxt }  {
    set re {\[(.+?)\]}
    set lorig {}
    set lnew {}
    while { [ regexp $re $intxt junk orig ] } {
	lappend lorig $orig
	set as [ atomselect top $orig ]
	set new [ $as get serial ]
	$as delete
	lappend lnew $new
	regsub $re $intxt $new intxt
    }
    set out $intxt
    set out "$out
!
! The above script includes the following replacements, based on 
! a structure named [molinfo top get name] with [molinfo top get numatoms] atoms.
"
    foreach orig $lorig new $lnew {
	set out "$out\n! $orig -> $new\n"
    }
    return $out
}



# http://wiki.tcl.tk/772
proc Plumed::tmpdir { } {
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
}


# Compute the PLUMED definitions passed as arguments on the
# top trajectory; return an array with the CVs (one per frame)
proc Plumed::plumed {cv_n metainp} {
    set tmpd "[ Plumed::tmpdir ]/vmdplumed.[pid]"
    file mkdir $tmpd
    set owd [ pwd ]
    cd $tmpd

    set metainp "$metainp\nPRINT W_STRIDE 1\nENDMETA\n"

    set dcd temp.dcd
    animate write dcd $dcd waitfor all

    set pdb temp.pdb
    Plumed::writePlumed [atomselect top all] $pdb

    set meta META_INP
    set och [open $meta w ]
    puts $och [ Plumed::replace_serials $metainp ]
    close $och

    set pbc "-nopbc"

    puts "Executing: driver -dcd $dcd -pdb $pdb -plumed $meta -ncv $cv_n $pbc"
    set rc [ catch { exec driver -dcd $dcd -pdb $pdb -plumed $meta -ncv $cv_n $pbc } stdout ] 

    if { $rc } {
	puts $stdout
	puts "Something went wrong. Check above messages and $tmpd."
	cd $owd
	return
    } 

    set ret {}
    set ich [open COLVAR r]
    while { -1 != [ gets $ich line ] } {
	if [ regexp FIELDS $line ] {
	    continue 
	}
	if { $cv_n == 1 } {
	    lappend ret [lindex $line 1]
	} else {
	    lappend ret [lrange $line 1 $cv_n]
	}
    }
    close $och
    file delete -force $tmpd
    cd $owd

    if { $cv_n == 1 } {
	return $ret
    } else { 
	return [Plumed::transpose $ret]
    }

}
