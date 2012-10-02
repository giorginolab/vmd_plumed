#!/bin/bash
# plumed manual --action NONE

# Get list of all actions
rm xx??
plumed manual --action NONE 2>&1 |csplit - '/DOCUMENTED ACTIONS/1'  '/LINE TOOLS/'

# Create a template per action
rm -rf templates_temp
mkdir templates_temp

for action in $(cat xx01); do
    plumed gentemplate --action $action > templates_temp/$action
done

# Generate the templates
tclsh templates_list_v2_gen.tcl > ../templates_list_v2.tcl

# Update pkg index
tclsh <<EOF
cd ..
pkg_mkIndex -verbose .
EOF


