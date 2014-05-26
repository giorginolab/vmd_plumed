Installation instructions
========================================



Plumed-GUI version update
----------------------------------------

VMD 1.9.1 comes with a very old version of Plumed-GUI pre-installed,
which does not support PLUMED 2.0. To upgrade Plumed-GUI to the latest
version, please follow the instructions provided below.  

Note that you will **need write privileges** in VMD's program
directory. Should you lack write permissions, either ask your
sysadmin, or perform a private installation of VMD.

1. Download and extract the latest Plumed-GUI release from GitHub.

2. Identify your VMD installation directory (let's call it
   _$VMDDIR_). This is easiest typing the following command in VMD's
   TkConsole:

          puts $env(VMDDIR)

3. Replace files in _$VMDDIR/plugins/noarch/tcl/plumed*_ with those
   just extracted. (Disregard the version mismatch in the directory
   name).  These are the important files to copy:
   * vmdplumed.tcl
   * templates_list_v1.tcl
   * templates_list_v2_autogen.tcl    
   * pkgIndex.tcl

4. Done. The plugin should appear in the _Extensions > Analysis >
   Collective Variable Analysis (PLUMED)_ menu upon VMD's next
   start. Verify the running version from _Help > About_.



Prerequisite: PLUMED engine
----------------------------------------

Plumed-GUI **requires** a _driver_  executable for your architecture to be located somewhere in the
executable path.  The executables are named _plumed_ (PLUMED 2.0, recommended) and _driver_ (PLUMED 1.3). You can have either or both installed.  


 * **Linux/Unix** and **OSX**:   download the code from the [PLUMED home page](http://www.plumed-code.org) and build it according to the instructions.  
 * **Windows**: Plumed-GUI (version > 2.1) provides a _Help > Attempt download of prebuilt Windows driver binaries_.
 menu entry which attempts to get precompiled binaries and to install them in a (system specific) directory. The same directory is temporarily added to the search path. The method requires enough permissions and network access. 
 * **Windows (fallback)**: if automated installation above fails, please manually download the pre-compiled binaries for Win32 ([driver.exe](http://www.multiscalelab.org/utilities/PlumedGUI?action=AttachFile&do=get&target=driver.exe) and [plumed.exe](http://www.multiscalelab.org/utilities/PlumedGUI?action=AttachFile&do=get&target=plumed.exe)) and copy them e.g. in ''c:\windows'' or in VMD's directory. 


If executables are correctly installed, their location will appear in the "Path to executable" box; it can be adjusted manually if not found (not recommended). 

Users willing to compile the engine themselves under Windows can see the [windows build instructions](http://www.multiscalelab.org/utilities/PlumedGUI/BuildWin32).


