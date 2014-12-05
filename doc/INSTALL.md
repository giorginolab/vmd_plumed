~~Installation~~ Upgrade instructions
========================================

The official distribution of VMD may contain an outdated version of
Plumed-GUI, and upgrading to one of the releases in
https://github.com/tonigi/vmd_plumed is highly recommended.
To upgrade, please follow the directions in this file.

There are various ways to install, depending on whether you have write
privileges in VMD's program directory (i.e. you are the administrator,
or installed VMD as a user). 

The plugin should appear in the _Extensions > Analysis > Collective
Variable Analysis (PLUMED)_ menu upon VMD's next start. Verify the
running version from _Help > About_.



## Method 1: edit VMD's startup file (VMD 1.9.1 and earlier)

You may download and extract the plugin in any directory. Then add the
following lines to your `.vmdrc` startup file. Note that name and location
[differ under Windows](http://www.ks.uiuc.edu/Research/vmd/vmd-1.7/ug/node197.html) !

        set auto_path [linsert $auto_path 0 /PATH/TO/EXTRACTED/VMD_PLUMED]
        menu main on


## Method 2: use VMD's preference manager (VMD 1.9.2 and on)

If you are using VMD 1.9.2's new preference manager, `.vmdrc` should
not be edited by hand, so method 1 above is not applicable. In this
case, refer to the following figure, adjusting the plugin name (*my
new plugin* becomes e.g. *vmdplugin*), location and script.

        set auto_path [linsert $auto_path 0 /PATH/TO/EXTRACTED/VMD_PLUMED]

![VMD 1.9.2 Preferences Editor](install_vmd_1.9.2.png)



## Method 3: set the TCLLIBPATH environment variable

This is suitable e.g. if you use *modulefiles*. Note that, unlike
other Unix paths, multiple path components should be space-separated.

        export TCLLIBPATH="/PATH/TO/EXTRACTED/VMD_PLUMED $TCLLIBPATH"


## Method 4: replace the plugin directory

This method is viable if you have write access to the directory where
VMD is installed. Just replace the _plugins/noarch/tcl/plumedX.Y_
directory in VMD's installation with the archive downloaded from
GitHub.

To identify your VMD installation directory, the easiest is to type the
following command in VMD's TkConsole:

          puts $env(VMDDIR)


