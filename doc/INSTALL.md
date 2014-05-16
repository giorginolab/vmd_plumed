Installation instructions
========================================


VMD already comes with Plumed-GUI installed. To upgrade to the latest
version, please follow the instructions provided below.


Prerequisites
----------------------------------------

Plumed-GUI REQUIRES that the "plumed" (PLUMED 2.0) and/or "driver"
(PLUMED 1.3) executables are installed in the path. See
http://www.multiscalelab.org/utilities/PlumedGUI for
instructions. Under Windows, you may attempt an automatic installation
(in Plumed-GUI's "Help" menu).



Manual upgrade
----------------------------------------

Note that you will need write privileges in VMD's program directory.
Installation requires these steps:

1. Identify your VMD installation directory (let's call it
   _$VMDDIR_). You can get the path typing the following
   command in VMD's TkConsole:
   - puts $env(VMDDIR)

2. Extract the distribution directory and replace the plugin files in
   _$VMDDIR/plugins/noarch/tcl/plumed*_ with those provided. Don't worry
   about version number mismatches.  Files to be copied are:
   * vmdplumed.tcl
   * templates_list_v1.tcl
   * templates_list_v2_autogen.tcl    
   * pkgIndex.tcl

3. Done. The plugin should appear in the "Extensions>Analysis>Collective
   Variable Analysis (PLUMED)" menu upon VMD's next run.




Usage without installation
----------------------------------------

As a last resort, plugins may be loaded without installation by
issuing a "source xxx.tcl" command for each of the distributed .tcl
files, with the exclusion of "<PACKAGENAME>_init.tcl".
