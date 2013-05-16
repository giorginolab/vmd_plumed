# -*- Makefile -*-

# Read VMD's variables - not doing include Makefile not to pull in
# .SILENT (which can't be unset)

VMVERSION = $(shell awk '/VMVERSION =/ {print $$NF}' ../Makefile)
VMDPLUGINDIR = plumed$(VMVERSION)

GENERATED_DOCFILES = ../doc/index.html ../doc/README ../doc/versionId



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
../templates_list_v2_autogen.tcl: 
	$(MAKE) -C templates
	cp templates/templates_list_v2_autogen.tcl ..



# ----------------------------------------
# Doc generator, as per
# http://stackoverflow.com/questions/4669105/makefile-dependencies-on-directory-content-when-creating-a-tar-file

# These are automatically generated. The whole dir is included anyway.
../doc/README: ../doc/index.html
	links -dump $< | cat README_header.txt - > $@

../doc/index.html:
	wget --user-agent="Mozilla/5.0 (X11; U; Linux i686; it; rv:1.9.0.19) Gecko/2011032314 Iceweasel/3.0.6 (Debian-3.0.6-3)" -k 'http://www.multiscalelab.org/utilities/PlumedGUI?action=print' -O $@

../doc/versionId:
	( echo -n "Package generated on "; \
	  date; \
	  echo "========"; \
	  git show -s --oneline ) > $@



# ----------------------------------------
# Distribution (No attempt at tracking deps). Usable for both the wiki
# and VMD.
TGZ = $(VMDPLUGINDIR).tar.gz

dist: $(TGZ) 

$(TGZ): default
	mkdir $(VMDPLUGINDIR)
	cp -a ../doc ../*.tcl ../Makefile $(VMDPLUGINDIR)
	tar -zcvf $@ $(VMDPLUGINDIR)
	rm -rf $(VMDPLUGINDIR)



# ----------------------------------------
clean:
	$(MAKE) -C templates clean
	rm -rf ../templates_list_v2_autogen.tcl $(GENERATED_DOCFILES) $(TGZ) 


