#!/bin/bash
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



# Get list of all actions
plumed gentemplate --list 2> list.tmp

# Create a template per action
rm -rf templates.tmp templates_full.tmp
mkdir templates.tmp templates_full.tmp

for action in $(cat list.tmp); do
    echo "Action: $action"
    plumed gentemplate --action $action > templates.tmp/$action
    plumed gentemplate --action $action --include-optional > templates_full.tmp/$action
done

# Generate the templates
tclsh generate_templates_aux.tcl > ../templates_list_v2_autogen.tcl



