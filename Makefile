default: pkgIndex.tcl

TCLLIST:=vmdplumed.tcl templates_list_v1.tcl templates_list_v2_autogen.tcl
DISTLIST:=INSTALL README.txt pkgIndex.tcl $(TCLLIST)
VMD_PLUGIN_DIR=plumed1.901

dist: $(DISTLIST)
	rm -rf $(VMD_PLUGIN_DIR)
	mkdir $(VMD_PLUGIN_DIR)
	cp $(DISTLIST) $(VMD_PLUGIN_DIR)
	tar -zcvf  $(VMD_PLUGIN_DIR).tgz  $(VMD_PLUGIN_DIR)


pkgIndex.tcl: $(TCLLIST)
	tclsh <<< "pkg_mkIndex -verbose ."

# Todo - download wiki, update README
README.txt:
	links -dump 'http://www.multiscalelab.org/utilities/PlumedCVTool?action=print' | \
		cat templates/README_header.txt - > $@

# Todo - template magic trick
templates_list_v2_autogen.tcl: templates/generate_templates.sh templates/generate_templates_aux.tcl
	cd templates && bash generate_templates.sh


clean:
	rm -rf templates_list_v2_autogen.tcl $(VMD_PLUGIN_DIR).tgz  $(VMD_PLUGIN_DIR) README.txt \
		templates/templates_full.tmp templates/templates.tmp 

