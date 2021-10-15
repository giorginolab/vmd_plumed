# This -*- Makefile -*- requires plumed 2.0

# Usage: make -f maintainer/Makefile   (not -C)

# When changing VMVERSION version number, also fix it in
#  vmdplumed.tcl
#  templates_list_v1.tcl
#  templates_list_vmdcv.tcl
#  maintainer/templates_list_v2_generator.tcl


default: templates_list_v2.tcl pkgIndex.tcl

templates_list_v2.tcl: maintainer/templates_list_v2_generator.tcl
	tclsh $< > $@


#  $(VMFILES) sans pkgIndex itself
pkgIndex.tcl: templates_list_v1.tcl templates_list_v2.tcl \
	templates_list_vmdcv.tcl vmdplumed.tcl
	tclsh <<< "pkg_mkIndex -verbose ."

.PHONY:
clean:
	-rm templates_list_v2.tcl pkgIndex.tcl



# Cross-compiling plumed2
# ./configure --host=i686-w64-mingw32   --disable-shared LDFLAGS=-static

# Linking all molfiles (useless) ---------
# Extract catdcd-5.1.tar.gz
# make -k win32
# olist=`( cd Obj_win32 ; echo *.o |sed 's/\.o//g')`
# bash config/create_static_header.sh MOLFILE molfile include/libmolfile_plugin.h $olist
# ar rcs libmolfile_plugin.a Obj_win32/*.o
# i686-w64-mingw32-ranlib libmolfile_plugin.a
#
# In plumed
# ./configure --host=i686-w64-mingw32 --disable-shared LDFLAGS="-static -L/tmp/catdcd-5.1" CPPFLAGS=-I/tmp/catdcd-5.1/include
# -----------------------------------------
