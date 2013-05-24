.SILENT:

VMFILES = vmdplumed.tcl pkgIndex.tcl \
	  templates_list_v1.tcl templates_list_v2_autogen.tcl
VMVERSION = 2.1
DIR = $(PLUGINDIR)/noarch/tcl/plumed$(VMVERSION)

bins:
win32bins:
dynlibs:
staticlibs:
win32staticlibs:

# Toni's plumed_wiki_distrib: make -f private/Makefile

distrib:
	@echo "Copying plumed $(VMVERSION) files to $(DIR)"
	mkdir -p $(DIR) 
	cp $(VMFILES) $(DIR) 

