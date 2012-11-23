#!/bin/bash

#!/bin/bash

########################################################################
# Copyright (C) 2012 Jeff Haack
# 
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This script will set up a project you can open and style with TileMill
#  and then easily push to your server
########################################################################

#HOME=~/Documents/TileScape  # Change this if you want to put your tilescape project files elsewhere
#SHARED=$HOME/shared
#SHAPEFILES=$SHARED/shapefiles
#PROJECT=$HOME/project

#mkdir -p $HOME
#mkdir -p $SHARED
#mkdir -p $SHAPEFILES
#mkdir -p $PROJECT

########################
## Get shapefile data ##
########################
# Get tilescape directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TILESCAPE_DIR="$(dirname "$SCRIPT_DIR")"
sudo apt-get -y install unzip
cd $TILESCAPE_DIR/shared/shapefiles
wget http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.3.0/physical/10m-land.zip
wget http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.4.0/cultural/10m-populated-places-simple.zip
wget http://tilemill-data.s3.amazonaws.com/osm/coastline-good.zip
wget http://tilemill-data.s3.amazonaws.com/osm/shoreline_300.zip
unzip 10m-land.zip
unzip 10m-populated-places-simple.zip
unzip coastline-good.zip
unzip shoreline_300.zip


# Setup Local DB
#psql -U postgres -c "create database tilemill_osm;"
#psql -U postgres -d tilemill_osm -c "CREATE EXTENSION postgis;"
### Get data here ###
#osm2pgsql -c -G -U postgres -d tilemill_osm -S /usr/local/share/osm2pgsql/default.style azerbaijan.osm.bz2





