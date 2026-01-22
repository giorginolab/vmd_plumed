.SILENT:

VMD_PLUMED_FILES = vmdplumed.tcl pkgIndex.tcl \
	  templates_list_v1.tcl templates_list_v2.tcl templates_list_vmdcv.tcl
VMD_PLUMED_VERSION = 2.9
DIR = $(PLUGINDIR)/noarch/tcl/plumed$(VMD_PLUMED_VERSION)


bins:
win32bins:
dynlibs:
staticlibs:
win32staticlibs:


# The first targets are used by VMD's builds.
distrib: 
	@echo "Copying vmd_plumed $(VMD_PLUMED_VERSION) files to $(DIR)"
	mkdir -p $(DIR) 
	cp $(VMD_PLUMED_FILES) $(DIR) 



# export
# .PHONY:
# autogen: 
#	make -f maintainer/Makefile


