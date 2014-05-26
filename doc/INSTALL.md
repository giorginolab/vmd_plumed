Installation instructions
========================================



Plumed-GUI install/upgrade
----------------------------------------

VMD 1.9.1 comes with a very old version of Plumed-GUI pre-installed,
which does not support PLUMED 2.0. To upgrade Plumed-GUI to the latest
version, please follow the instructions provided below.  Note that you
will *need* write privileges in VMD's program directory.

1. Identify your VMD installation directory (let's call it
   _$VMDDIR_). This is easiest typing the following command in VMD's
   TkConsole:

          puts $env(VMDDIR)

2. Download and extract the latest Plumed-GUI release from GitHub.

3. Replace the files in _$VMDDIR/plugins/noarch/tcl/plumed*_ with those just extracted. Don't worry
   about version number mismatches.  Important files to be copied are:
   * vmdplumed.tcl
   * templates_list_v1.tcl
   * templates_list_v2_autogen.tcl    
   * pkgIndex.tcl

3. Done. The plugin should appear in the _Extensions>Analysis>Collective
   Variable Analysis (PLUMED)_ menu upon VMD's next run.



Prerequisite: PLUMED engine
----------------------------------------

Plumed-GUI *requires* the _plumed_ (PLUMED 2.0, recommended) and/or
_driver_ (PLUMED 1.3) engine executables to be available in the
executable path.  PLUMED engine is available at www.plumed-code.org .

Under *Linux* and *OSX*, installation of engine executables is taken
care by Plumed's standard configure/make procedure (see docs).  Under
*Windows*, you may attempt an automatic installation with Plumed-GUI's
_Help > Attempt download of prebuilt Windows driver binaries_.

See http://www.multiscalelab.org/utilities/PlumedGUI for
further details. 
