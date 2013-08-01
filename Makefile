.SILENT:

VMFILES = vmdplumed.tcl pkgIndex.tcl \
	  templates_list_v1.tcl templates_list_v2_autogen.tcl
VMVERSION = 2.2
DIR = $(PLUGINDIR)/noarch/tcl/plumed$(VMVERSION)

bins:
win32bins:
dynlibs:
staticlibs:
win32staticlibs:

# Toni: make -C maintainer
#
# If changing the version number, also fix it in
# templates_list_v1.tcl and in generator.tcl


distrib:
	@echo "Copying plumed $(VMVERSION) files to $(DIR)"
	mkdir -p $(DIR) 
	cp $(VMFILES) $(DIR) 

