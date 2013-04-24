
# plumed manual --action NONE

# Full data model		Simple tcl
#      KEYWORD		
#      template		        +
#      full template
#      menu label		+
#      menu shortcut
#      doc
#      html link
#      short help
#      sort order		+
#      example


default: ../../templates_list_v2_autogen.tcl


# Get list of all actions. Prints an harmless warning on STDOUT
# --action DISTANCE is a temporary workaround
list.tmp:
	plumed gentemplate --list --action DISTANCE 2> $@  > /dev/null

# Create a template per action
temp_dirs: list.tmp
	rm -rf templates.tmp templates_full.tmp
	mkdir templates.tmp templates_full.tmp
	for action in $$(cat list.tmp); do	\
	    echo "Action: $$action";		\
	    plumed gentemplate --action $$action > templates.tmp/$$action;				\
	    plumed gentemplate --action $$action --include-optional > templates_full.tmp/$$action;	\
	done


# Generate the templates
../../templates_list_v2_autogen.tcl: generate_templates_aux.tcl list.tmp temp_dirs
	tclsh generate_templates_aux.tcl > $@


clean:
	rm -rf *.tmp

