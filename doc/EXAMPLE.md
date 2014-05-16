PLUMED-GUI usage examples
====================


The following examples require an internet connection to download
structures from the PDB repository.


Example 1: Analysis
===================


Use PLUMED 2.0 to compute and compare, for all frames provided by the
PDB:1KDX (CREB:CBP binding) structure, the following quantities

CV  | Description
--- | -------------
nc  | the number of contacts (<5 Å) between Cα atoms of CREB (KID domain, chain B) and CBP (KIX domain, chain A) 
g1  | the radius of gyration of the KID domain
g2  | the radius of gyration of the KIX domain
d   | the distance between the center of mass of the two


Solution
--------

1. Load the structure: invoke VMD's _Extensions>Data>PDB Database
        Query_ menu entry, enter _1KDX_ and select _Load into new
        molecule_.

2. Open the GUI via _Extensions>Analysis>Collective Variable
        Analysis (PLUMED)_.

3. Enter the analysis scripts below (also provided in
        [EXAMPLE.plumed2](EXAMPLE.plumed2)). Click _Plot_ to evaluate and plot the
        results. If no plot appears, check the console for
        errors. Right click on any keyword to get help.

	    # Switch to Angstroms
	    UNITS  LENGTH=A  ENERGY=kcal/mol  TIME=ps

	    # Carbon-alphas
	    kixCA:   GROUP ATOMS=[chain A and name CA]
	    kidCA:   GROUP ATOMS=[chain B and name CA]

	    # Center of masses for the above
	    kidCOM:  COM ATOMS=kidCA
	    kixCOM:  COM ATOMS=kixCA

	    # The four collective variables
	    nc: COORDINATION GROUPA=kidCA GROUPB=kixCA NN=6  MM=12  D_0=0.0  R_0=7.0
	    g1: GYRATION ATOMS=kidCA TYPE=RADIUS 
	    g2: GYRATION ATOMS=kixCA TYPE=RADIUS 
	    d: DISTANCE ATOMS=kidCOM,kixCOM


4. (Optional) In the plot window, use _File>Export as matrix_ to
        get the data for external analysis and plot. The result should
        be as follows (time, followed by the four CV values - should match
        [EXAMPLE.plumed2.out](EXAMPLE.plumed2.out)):

	    0.000000 36.722447 10.303459 13.210119 14.374999 
	    1.000000 38.522232 10.422169 13.191604 14.171861 
	    2.000000 37.974472 10.315127 13.228145 14.025973 
	    3.000000 33.677059 10.481784 13.066689 15.197608 
	    4.000000 35.658888 10.743880 13.304966 14.464722 
	    5.000000 35.768069 10.891300 12.911168 14.117265 
	    6.000000 38.425781 10.456811 13.263247 14.144517 
	    7.000000 35.961402 10.496452 13.216653 14.702924 
	    8.000000 36.525922 10.675232 13.172231 14.940701 
	    9.000000 36.777001 10.158110 13.360060 14.967064 
	    10.000000 32.705477 10.355259 13.243246 14.919030 
	    11.000000 40.643987 10.041897 13.171775 14.002062 
	    12.000000 39.701419 9.979167 13.005144 13.980439 
	    13.000000 36.456879 10.738193 13.126875 14.392346 
	    14.000000 35.524732 10.215472 13.160106 14.508812 
	    15.000000 37.770794 10.283957 13.182230 14.297389 
	    16.000000 39.594543 10.019501 13.166989 14.280177 




Example 2: Biasing script
=========================

Suppose that the fourth coordinate has been identified as a candidate
for 1-D metadynamics, with gaussian width of 1 Å, height of 0.1
kcal/mol, stride of 1 ns. Generate the corresponding biasing script for 
use in a simulation.


Solution
--------

1. Add the following line to the input file

            METAD ARG=d     SIGMA=1.0     HEIGHT=0.1     PACE=1000     FILE=HILLS


2. Use the GUI's _File>Export_ function to get a biasing script
     	that can be used in PLUMED-based metadynamic simulations. The
     	result will contain numeric atom selections and should look
     	like as the one below (abridged):

	    [...]
	    kixCA:   GROUP ATOMS=2,9,25,49,71,78,102,119,134,151,167,181,198,210,229,253,264,281,300,316,333,355,374,390,407,417,436,456,470,484,498,510,524,534,544,563,585,597,621,645,662,677,691,710,726,736,757,767,789,811,827,842,849,861,878,899,914,925,935,949,960,984,996,1011,1032,1053,1070,1089,1108,1118,1133,1155,1174,1195,1217,1236,1253,1275,1290,1309,1324
	    kidCA:   GROUP ATOMS=1339,1353,1365,1376,1393,1415,1439,1463,1478,1497,1516,1527,1551,1575,1589,1603,1624,1648,1670,1689,1708,1722,1734,1753,1764,1775,1787,1797
	    [...]
	    # The above script includes the following replacements, based on 
	    # a structure named 1kdx with 1809 atoms.
	    #
	    # [chain A and name CA] -> (list of 81 atoms)
	    # [chain B and name CA] -> (list of 28 atoms)

