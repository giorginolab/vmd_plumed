# -*- Makefile -*-

default: pkgIndex.tcl

# Read VMD's variables - not doing this not to pull in .SILENT
# include Makefile

VMVERSION=$(shell awk '/VMVERSION =/ {print $$NF}' Makefile)

TCLLIST:=vmdplumed.tcl templates_list_v1.tcl templates_list_v2_autogen.tcl
DOCFILES:=doc/index.html doc/README
DISTLIST:=doc Makefile pkgIndex.tcl ChangeLog $(TCLLIST)
VMD_PLUGIN_DIR=plumed_$(VMVERSION)
TGZ=$(VMD_PLUGIN_DIR).tar.gz

dist: $(TGZ)

$(TGZ): $(DISTLIST) $(DOCFILES)
	rm -rf $(VMD_PLUGIN_DIR)
	mkdir $(VMD_PLUGIN_DIR)
	cp -a $(DISTLIST) $(VMD_PLUGIN_DIR)
	tar -zcvf  $@  $(VMD_PLUGIN_DIR)
	rm -rf $(VMD_PLUGIN_DIR)
#	cp $@ /home/toni/Dropbox/Public


pkgIndex.tcl: $(TCLLIST)
	tclsh <<< "pkg_mkIndex -verbose ."


# Handle doc directory, as per http://stackoverflow.com/questions/4669105/makefile-dependencies-on-directory-content-when-creating-a-tar-file

doc/README: doc/index.html
	links -dump $< | cat private/README_header.txt - > $@

doc/index.html:
	wget --user-agent="Mozilla/5.0 (X11; U; Linux i686; it; rv:1.9.0.19) Gecko/2011032314 Iceweasel/3.0.6 (Debian-3.0.6-3)" -k 'http://www.multiscalelab.org/utilities/PlumedCVTool?action=print' -O $@



# Todo - replace with sub-Make
templates_list_v2_autogen.tcl: private/templates/generate_templates_aux.tcl
	$(MAKE) -C private/templates



clean:
	$(MAKE) -C private/templates clean
	rm -rf templates_list_v2_autogen.tcl $(VMD_PLUGIN_DIR) $(TGZ)


