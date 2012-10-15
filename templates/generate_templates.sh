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
rm -rf templates_temp templates_full
mkdir templates_temp templates_full

for action in $(cat list.tmp); do
    echo "Action: $action"
    plumed gentemplate --action $action > templates_temp/$action
    plumed gentemplate --action $action --include-optional > templates_full/$action
done

# Generate the templates
tclsh generate_templates_list_v2.tcl > ../templates_list_v2_autogen.tcl

# Update pkg index
tclsh <<EOF
cd ..
pkg_mkIndex -verbose .
EOF


