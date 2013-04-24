# -*- Makefile -*-


default: pkgIndex.tcl

# Read VMD's variables - not doing include Makefile not to pull in
# .SILENT (which can't be unset)

VMVERSION = $(shell awk '/VMVERSION =/ {print $$NF}' Makefile)


# In principle TCLLIST=VMFILES of root Makefile, but we don't include it
TCLLIST  = vmdplumed.tcl templates_list_v1.tcl \
	templates_list_v2_autogen.tcl pkgIndex.tcl




# Index
pkgIndex.tcl: $(TCLLIST)
	tclsh <<< "pkg_mkIndex -verbose ."




# Todo - replace with sub-Make
templates_list_v2_autogen.tcl: private/templates/generate_templates_aux.tcl
	$(MAKE) -C private/templates



# Handle doc directory, as per
# http://stackoverflow.com/questions/4669105/makefile-dependencies-on-directory-content-when-creating-a-tar-file

# These are automatically generated. The whole dir is included anyway.
GENERATED_DOCFILES = doc/index.html doc/README

doc/README: doc/index.html
	links -dump $< | cat private/README_header.txt - > $@

doc/index.html:
	wget --user-agent="Mozilla/5.0 (X11; U; Linux i686; it; rv:1.9.0.19) Gecko/2011032314 Iceweasel/3.0.6 (Debian-3.0.6-3)" -k 'http://www.multiscalelab.org/utilities/PlumedCVTool?action=print' -O $@




# The future TGZ dir
VMD_DIST_DIR = plumed_gui_$(VMVERSION)
DISTLIST = doc Makefile pkgIndex.tcl ChangeLog $(TCLLIST)

TGZ = $(VMD_DIST_DIR).tar.gz
dist: $(TGZ) 

$(TGZ): $(TCLLIST) $(DISTLIST) $(GENERATED_DOCFILES)
	rm -rf $(VMD_DIST_DIR)
	mkdir $(VMD_DIST_DIR)
	cp -a $(DISTLIST) $(VMD_DIST_DIR)
	tar -zcvf  $@  $(VMD_DIST_DIR)
	rm -rf $(VMD_DIST_DIR)
#	cp $@ /home/toni/Dropbox/Public





clean:
	$(MAKE) -C private/templates clean
	rm -rf templates_list_v2_autogen.tcl $(VMD_DIST_DIR) $(TGZ) \
		$(GENERATED_DOCFILES)


