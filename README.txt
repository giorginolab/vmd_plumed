Up-to-date documentation at http://www.multiscalelab.org/utilities/PlumedCVTool .

This page is just a text dump of the above address, provided for convenience.


****************


          A general collective variable analysis tool (VMD PLUMED GUI)

   Documentation for version 1.0

   To use this plugin, you will need PLUMED's driver executable. Download it
   from the 'installation' section below

   The PLUMED collective variable analysis tool is a VMD plugin that provides
   access to the extensive set of collective variables (CV) defined in the
   PLUMED software. It allows you to:
     * analyze the currently loaded trajectory by evaluating and plotting
       arbitrary CVs
     * use VMD's atom selection keywords to define atom groups and ready-made
       templates for common CVs
     * export the CV definition file for use in MD simulations
     * prepare reference files for RMSD, path-variable, native contacts, etc.
     * analyze DCD files in batches

   Please check that you have the latest version installed.

Usage

   The usage of the plugin is straightforward.
    1. From VMD's main window, select "Extensions > Analysis > Collective
       variable analysis (PLUMED)"
    2. Edit the CV definition file, defining one or more CVs
    3. Enter the number of CVs defined in the corresponding box (this will be
       fixed in a future PLUMED release)
    4. Click "Plot". This will open a plot window with the selected CVs.

   Square brackets can be used to conveniently define atom groups (Ctrl-G).
   During evaluation, atom selection keywords in square brackets are replaced
   with a list of the corresponding serial numbers for the top molecule.

   When Plot is clicked, the currently loaded trajectory is exported to a
   temporary directory (shown in the console), and the driver utility is
   invoked. If there are no errors, a plot will show the CVs evaluated on the
   frames of the current trajectory.

   Troublehooting: In case of errors, the console will provide diagnostics
   and the location of the temporary directory where computations are run.
   Common sources of error are:
     * Hills deposition should be disabled.
     * Improperly set periodic boundary conditions, especially when dealing
       with non-wrapped solvent or with MD engines which "break" molecules by
       wrapping them.

     ----------------------------------------------------------------------

The File menu

   CV definition files can be opened, edited and saved as usual. Save and
   Save as... save the currently open file varbatim, while the Export..
   function performs the atom selection replacements (see below), thus
   creating a META_INP file that can be used directly in simulations.

  Batch analysis

   Once a script is tested, the menu option File>Batch analysis... allows you
   to apply it to all of the DCD files in a chosen directory (Linux-only).
   The files are processed according to the current settings, and need to
   match the top molecule. If the Combine option is unselected, a .dcd.colvar
   file will be created along with each .dcd trajectory. If the Combine
   option is selected, the metrics for the various trajectories will be
   joined in a single metric.dat file. Lines of the file contains the file
   name, followed by the usual COLVAR columns (without header). Note:
   existing .colvar or metric.dat files will be overwritten without warning.
   You can set Number of processes to run multiple processes concurrently; it
   is advantageous to spawn between 1 and 2 times the number of CPU cores you
   have.

   Batch analysis can also be performed on the shell command line
   (Linux-only). You will need to
    1. download a wrapper script for the driver executable
    2. export the PLUMED script (say you called it 'analysis.plumed.exp')
    3. issue a command similar to the following (P6 is the number of
       concurrent processes to spawn):

   ls *.dcd| xargs  -i+ -P6 driver_safe -dcd + -pdb filtered.pdb \
              -plumed ../contacts.plumed.exp -ncv 3 -colvar +.cv

    4. to combine the output files into one, use

   awk '!/FIELDS/{print FILENAME $0}' *.cv > cv.all

     ----------------------------------------------------------------------

The Edit menu

   The Edit menu provides the usual cut-copy-paste text-editing options.

     ----------------------------------------------------------------------

The Templates menu

   Elements in the Templates menu provides shortcuts for most CVs supported
   by PLUMED. Please refer to PLUMED's user's guide for the full syntax.

   The Electrostatic energy and Dipole CVs require charges to be defined in
   the currently loaded molecule, so AMBER or CHARMM topology file have to be
   loaded beforehand.

   Structure files (used for RMSD, Z_PATH, S_PATH, etc.) must be referenced
   by absolute pathname.

   The template menu does not hold the full list of the CVs implemented in
   PLUMED, but all of them will work anyway when typed in.

     ----------------------------------------------------------------------

The Structure menu

   The Structure menu provides functions for entering complex CVs.

  Reference structures for RMSD and path variables

   The Structure>Prepare reference structure... dialog can be used to prepare
   pseudo-PDB files that can be used as reference structures for RMSD,
   path-variables, etc. Two VMD atom selections are required to define the
   set of atoms that will be used for alignment (alignment set) and for the
   distance measurement (displacement set), respectively. The currently
   selected frame of the top molecule is used to create a reference file;
   numbering can be altered to conform to another molecule. The file format
   is specified in the 'Path collective variables' section of the PLUMED
   manual.

   Notes:
     * After generating the structures, remember to set the top molecule to
       the one you want to analyze.
     * Structures must be referenced by absolute pathname in the PLUMED
       script.
     * The RMSD keyword has been renamed to MSD in PLUMED 1.3.

  Native contacts

   The Structure>Native contacts CV inserts a native-contacts CV. The
   currently selected frame of the top molecule is taken as the native state.
   Atom numbers are adapted to fit the structure indicated in the target
   molecule field. If selection 2 is given, only intermolecular contacts
   (between selection 1 and 2) are counted. Otherwise, contacts internal in
   selection 1 are considered. The Distance cutoff selects the radius to
   consider contacts in the native state. If only one selection is given,
   contacts can be filtered with the D resid option (see description in RMSD
   trajectory tool enhanced with native contacts). Group name specifies the
   label for two atom lists (that will be placed at the top of the plumed
   file). Note: After generating the CV lines, remember to set the top
   molecule to the one you want to analyze.

  Ramachandran angles

   A list of f, q, and w Ramachandran angles can be inserted for an atom
   selection. Note that N-CA-C atom names are assumed for backbone atoms.
   Dihedrals involving atoms outside the selection are not added. The w angle
   is intended between residue i and i+1.

     ----------------------------------------------------------------------

Notes

     * The plugin was tested up to PLUMED version 1.3.
     * PLUMED's 1.2.2 parser for alignment structures may be broken;
       workarounds are used, but feel free to apply the following patch to
       fix it permanently patch-pdbparser.

Screenshot

   User interface:

   screenshotplumedcollect.png

   attachment:screenshotmultiplot.png attachment:cvs.png
   attachment:screenshotpreparerefere.png

   attachment:screenshotnc.png attachment:screenshotrama.png

Installation

   Plumed driver. The plugin requires that you have PLUMED's driver utility
   (LGPL) in your path.
     * Windows the easiest is to download the pre-compiled binary for Win32
       (version 1.2.2) and copy it e.g. in c:\windows. Users willing to
       compile the plugin can follow the windows build instructions.
     * Linux users can download the code from PLUMED home page and build it
       following the instructions.

   If the executable is not in the path, its location should be specified in
   the "Options" box.

   Upgrades. VMD versions 1.9.0 is distributed with PLUMED GUI v0.9. If you
   want to upgrade, or install in previous versions of VMD, download the
   plugin and follow the installation instructions in the archive.

Licensing

   By downloading the software you agree to comply with the terms of GPL
   version 2.

   (c) Universitat Pompeu Fabra 2011.

   Author and feedback: Toni Giorgino (at upf.edu)

Acknowledgments

   Work partially supported by the VPH-NoE and Generalitat de Catalunya.

   http://img191.imageshack.us/img191/496/vphlogo.png
