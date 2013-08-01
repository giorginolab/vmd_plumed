# -*- Makefile -*-

# Read VMD's variables - not doing include Makefile not to pull in
# .SILENT (which can't be unset)

VMVERSION = $(shell awk '/VMVERSION =/ {print $$NF}' ../Makefile)
VMDPLUGINDIR = plumed$(VMVERSION)

GENERATED_DOCFILES = ../doc/versionId



# ----------------------------------------
# Default is: Pkg Index, Templates, Doc files

default: ../pkgIndex.tcl ../templates_list_v2_autogen.tcl $(GENERATED_DOCFILES)



# ----------------------------------------
# PKG Index

# In principle TCLLIST=VMFILES of root Makefile, but we don't include it
TCLLIST  = ../vmdplumed.tcl ../templates_list_v1.tcl \
	   ../templates_list_v2_autogen.tcl 

../pkgIndex.tcl: $(TCLLIST)
	cd ..; tclsh <<< "pkg_mkIndex -verbose ."



# ----------------------------------------
# Template generator
../templates_list_v2_autogen.tcl: template_generator.tcl
	tclsh template_generator.tcl > $@



# ----------------------------------------
# Doc generator, as per

../doc/versionId:
	( echo -n "Package generated on "; \
	  date; \
	  echo "========"; \
	  git show -s --oneline ) > $@



# ----------------------------------------
# Distribution (No attempt at tracking deps). Usable for both the wiki
# and VMD.
ZIP = $(VMDPLUGINDIR).zip

dist: $(ZIP) 

$(ZIP): default
	mkdir $(VMDPLUGINDIR)
	cp -a ../doc ../*.tcl ../Makefile $(VMDPLUGINDIR)
	zip -r $@ $(VMDPLUGINDIR)
	rm -rf $(VMDPLUGINDIR)



# ----------------------------------------
clean:
	rm -rf ../templates_list_v2_autogen.tcl $(GENERATED_DOCFILES) $(ZIP) 


