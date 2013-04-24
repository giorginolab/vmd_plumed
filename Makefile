.SILENT:

VMFILES = vmdplumed.tcl pkgIndex.tcl \
	templates_list_v1.tcl templates_list_v2_autogen.tcl
VMVERSION = 1.9
DIR = $(PLUGINDIR)/noarch/tcl/plumed$(VMVERSION)

bins:
win32bins:
dynlibs:
staticlibs:
win32staticlibs:

distrib:
	@echo "Copying plumed $(VMVERSION) files to $(DIR)"
	mkdir -p $(DIR) 
	cp $(VMFILES) $(DIR) 

	
