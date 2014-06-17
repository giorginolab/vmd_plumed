Installation instructions
========================================



Plumed-GUI version update
----------------------------------------

VMD 1.9.1 comes with a very old (0.9) version of Plumed-GUI
pre-installed, which does not support PLUMED 2.0. Updating Plumed-GUI
to the latest version is easy and highly recommended. To upgrade,
please follow the instructions provided below.

Note that you will **need write privileges** in VMD's program
directory. Should you lack them, perform a private installation of VMD 
or, alternatively, try the _non-root instructions_ below (need testing).


### How to upgrade (one-sentence version) ###

Replace the _plugins/noarch/tcl/plumed0.9_ directory in VMD's installation with
the archive downloaded from GitHub.


### How to upgrade (detailed version) ###

1. Download and extract the latest Plumed-GUI release from GitHub.

2. Identify your VMD installation directory (let's call it
   _$VMDDIR_). This is easiest typing the following command in VMD's
   TkConsole:

          puts $env(VMDDIR)

3. Delete the directory  _$VMDDIR/plugins/noarch/tcl/plumed0.9_, 
   which contains the old version of the plugin.

4. Unzip the archive downloaded at step 1 as a subdirectory of _$VMDDIR/plugins/noarch/tcl/_.  At least the following files should be present:
   * vmdplumed.tcl
   * templates_list_v1.tcl
   * templates_list_v2_autogen.tcl
   * pkgIndex.tcl


5. Done. The plugin should appear in the _Extensions > Analysis >
   Collective Variable Analysis (PLUMED)_ menu upon VMD's next
   start. Verify the running version from _Help > About_.


### How to upgrade (if you have no root access) ###

If you cannot replace files in VMD's directory, you might have some success with the following trick:

1. Unzip the _vmd_plumed_ distribution anywhere in your system

2. Add the following lines to your _.vmdrc_ startup file (name and location [differs under Windows](http://www.ks.uiuc.edu/Research/vmd/vmd-1.7/ug/node197.html))

        lappend auto_path  /PATH/TO/THE/EXTRACTED/DISTRIBUTION
        menu main on

   or, alternatively, set the following environment variable (e.g. via modules)

        export TCLLIBPATH=/PATH/TO/VMD_PLUMED:$TCLLIBPATH






Prerequisite: PLUMED engine
----------------------------------------

Plumed-GUI **requires** a _driver_  executable for your architecture to be located somewhere in the
executable path.  The executables are named _plumed_ (PLUMED 2.1, recommended) and _driver_ (PLUMED 1.3).
You can have either or both installed.  

Until PLUMED 2.1 is officially released, please use the _master_ development branch, which you
can obtain from https://github.com/plumed/plumed2 .


 * **Linux/Unix** and **OSX**:   download the code from the [PLUMED home page](http://www.plumed-code.org) and build it according to the instructions.  
 * **Windows**: Plumed-GUI (version > 2.1) provides a _Help > Attempt download of prebuilt Windows driver binaries_.
 menu entry which attempts to get precompiled binaries and to install them in a (system specific) directory. The same directory is temporarily added to the search path. The method requires enough permissions and network access. 
 * **Windows (fallback)**: if automated installation above fails, please manually download the pre-compiled binaries for Win32 ([driver.exe](http://www.multiscalelab.org/utilities/PlumedGUI?action=AttachFile&do=get&target=driver.exe) and [plumed.exe](http://www.multiscalelab.org/utilities/PlumedGUI?action=AttachFile&do=get&target=plumed.exe)) and copy them e.g. in ''c:\windows'' or in VMD's directory. 


If executables are correctly installed, their location will appear in the "Path to executable" box; it can be adjusted manually if not found (not recommended). 

Users willing to compile the engine themselves under Windows can see the [windows build instructions](http://www.multiscalelab.org/utilities/PlumedGUI/BuildWin32).




