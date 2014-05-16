Installation instructions
========================================


Prerequisite: PLUMED engine
----------------------------------------

Plumed-GUI _requires_ the "plumed" (PLUMED 2.0, recommended) and/or "driver"
(PLUMED 1.3) engine executables to be available in the executable path. 
Both are available at www.plumed-code.org .

Under *Linux* and *OSX*, installation is taken care by
the standard configure/make install procedure. 
Under *Windows*, you may attempt an automatic installation
(in Plumed-GUI's "Help" menu).

See http://www.multiscalelab.org/utilities/PlumedGUI for
further instructions. 



Plumed-GUI install/upgrade
----------------------------------------

VMD comes with an old version of Plumed-GUI pre-installed. To upgrade to the latest
version, please follow the instructions provided below.

Note that you will need write privileges in VMD's program directory.
Installation requires these steps:

1. Identify your VMD installation directory (let's call it
   _$VMDDIR_). You can get the path typing the following
   command in VMD's TkConsole:

          puts $env(VMDDIR)

2. Extract the distribution directory and replace the plugin files in
   _$VMDDIR/plugins/noarch/tcl/plumed*_ with those provided. Don't worry
   about version number mismatches.  Files to be copied are:
   * vmdplumed.tcl
   * templates_list_v1.tcl
   * templates_list_v2_autogen.tcl    
   * pkgIndex.tcl

3. Done. The plugin should appear in the _Extensions>Analysis>Collective
   Variable Analysis (PLUMED)_ menu upon VMD's next run.




Usage without installation
----------------------------------------

As a last resort, plugins may be loaded without installation by
issuing a `source xxx.tcl` command for each of the distributed .tcl
files, with the exclusion of the "*_init.tcl" files, if any.
