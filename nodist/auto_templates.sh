#!/bin/bash
# plumed manual --action NONE

rm -rf templates
mkdir templates
rm xx??
plumed manual --action NONE 2>&1 |csplit - '/DOCUMENTED ACTIONS/1'  '/LINE TOOLS/'

for action in $(cat xx01); do
    plumed gentemplate --action $action > templates/$action
done

