Prerequisite: PLUMED engine
========================================

Plumed-GUI **requires** a _driver_ executable for your architecture to
be located somewhere in the executable path.  The executables are
named `plumed` (PLUMED ≥ 2, recommended) and `driver` (PLUMED 1.3).
You can have either or both installed.

If the executables are correctly installed, their location will appear
in the "Path to executable" box; the path can be adjusted manually.


Linux/Unix and OSX
------------------

Download the code from the [PLUMED home
page](http://www.plumed.org) and build it according to the
instructions. 
     
Alternatively, install it under the Conda package 
manager as follows:

    conda install -c conda-forge plumed


Windows
-------

> [!WARNING]  
> The instructions in this section are outdated and no longer work.

Plumed-GUI provides a _Help > Attempt
download of prebuilt Windows driver binaries_.  menu entry which
attempts to get precompiled binaries and to install them in a
(system specific) directory. The same directory is temporarily
added to the search path. The method requires enough permissions
and network access.

Instructions for cross-compilation are provided in the
[PLUMED-WIN32.md](PLUMED-WIN32.md) file.

