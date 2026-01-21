Plumed-GUI
==========

Toni Giorgino  


A collective variable analysis tool for VMD
------------

The PLUMED-GUI collective variable analysis tool is a plugin for the [Visual Molecular Dynamics (VMD)](https://www.ks.uiuc.edu/Research/vmd/)
software that provides access to the extensive set of collective variables (CV) defined in the PLUMED. It allows you to:

- analyze the currently loaded trajectory by evaluating and plotting arbitrary CVs
- use VMD's *atom selection* keywords to define atom groups and ready-made templates for common CVs
- export the CV definition file for use in MD simulations
- prepare reference files for RMSD, path-variable, native contacts, etc.
 
The code is hosted on GitHub at
[giorginolab/vmd_plumed](https://github.com/giorginolab/vmd_plumed).




Installation
------------

First, you likely want PLUMED 2's *plumed* executable in your path: 
see [INSTALL-PLUMED-FIRST.md](doc/INSTALL-PLUMED-FIRST.md). The GUI
also supports older PLUMED 1.3's *driver*.

Second, you may want to update PLUMED-GUI to its latest version,
rather than using the one distributed with VMD. See instructions
in [INSTALL.md](doc/INSTALL.md).




Documentation
-------------

Please find

- A short manual and quickstart in the [doc/README.md](doc/README.md) file
- An extensive description in the accompanying paper (see the Citation section):   _Plumed-GUI: an environment for the interactive development of molecular dynamics analysis and biasing scripts_ [doi:10.1016/j.cpc.2013.11.019](http://dx.doi.org/10.1016/j.cpc.2013.11.019) 
- Information on the PLUMED engine at http://www.plumed.org 


License
-------

The plugin can be used under the terms of the 3-clause BSD license. 


Citation
--------

If you use Plumed-GUI in research work, please cite the following paper
(in addition to other possibly relevant Plumed citations):

-  T. Giorgino, “PLUMED-GUI: An environment for the interactive
   development of molecular dynamics analysis and biasing scripts,”
   Computer Physics Communications, vol. 185, no. 3, pp. 1109–1114,
   Mar. 2014. [doi:10.1016/j.cpc.2013.11.019](http://dx.doi.org/10.1016/j.cpc.2013.11.019) and 
   [arXiv:1312.3190](https://arxiv.org/abs/1312.3190)





