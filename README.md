A Plumed collective variable analysis tool for VMD (Plumed-GUI, v 2.2)

The PLUMED-GUI collective variable analysis tool is a plugin for the Visual Molecular Dynamics (VMD) software that provides access to the extensive set of collective variables (CV) defined in the PLUMED. It allows you to:

    analyze the currently loaded trajectory by evaluating and plotting arbitrary CVs
    use VMD's atom selection keywords to define atom groups and ready-made templates for common CVs
    export the CV definition file for use in MD simulations
    prepare reference files for RMSD, path-variable, native contacts, etc.
    analyze DCD files in batches 

For a primer on the use of PLUMED, see e.g. the official website and/or one of the excellent tutorials available.

VMD versions 1.9.0 is distributed with PLUMED GUI v0.9. To upgrade, download the plugin and follow the installation instructions in the archive. The current version supports both Plumed 2.0 and Plumed 1.3.

To use this plugin, you will need PLUMED's driver and/or plumed executables. See the installation section below.

Citation

You are kindly requested to cite the following paper in any publication resulting from the use of Plumed-GUI (in addition to other possibly relevant Plumed citations):

    Toni Giorgino, Plumed-GUI: an environment for the interactive development of molecular dynamics analysis and biasing scripts (2014) Computer Physics Communications, 10.1016/j.cpc.2013.11.019 or arxiv:1312.3190. 

Usage

The usage of the plugin is straightforward.

    From VMD's main window, select "Extensions > Analysis > Collective variable analysis (PLUMED)"
    Edit the CV definition file, defining one or more CVs
    Enter the number of CVs defined in the corresponding box (this will be fixed in a future PLUMED release)
    Click "Plot". This will open a plot window with the selected CVs. 

Square brackets can be used to conveniently define atom groups (Ctrl-G). During evaluation, atom selection keywords in square brackets are replaced with a list of the corresponding serial numbers for the top molecule.

When Plot is clicked, the currently loaded trajectory is exported to a temporary directory (shown in the console), and the driver utility is invoked. If there are no errors, a plot will show the CVs evaluated on the frames of the current trajectory.

Troubleshooting: In case of errors, the console will provide diagnostics and the location of the temporary directory where computations are run. Common sources of error are:

    Hills deposition should be disabled.
    Improperly set periodic boundary conditions, especially when dealing with non-wrapped solvent or with MD engines which "break" molecules by wrapping them. 
