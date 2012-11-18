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

HOME=~/Documents/TileScape  # Change this if you want to put your tilescape project files elsewhere
SHARED=$HOME/shared
SHAPEFILES=$SHARED/shapefiles
PROJECT=$HOME/project

mkdir -p $HOME
mkdir -p $SHARED
mkdir -p $SHAPEFILES
mkdir -p $PROJECT

########################
## Get shapefile data ##
########################
sudo apt-get -y install unzip
cd $SHAPEFILES
wget http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.3.0/physical/10m-land.zip
wget http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.4.0/cultural/10m-populated-places-simple.zip
wget http://tilemill-data.s3.amazonaws.com/osm/coastline-good.zip
wget http://tilemill-data.s3.amazonaws.com/osm/shoreline_300.zip
unzip 10m-land.zip
unzip 10m-populated-places-simple.zip
unzip coastline-good.zip
unzip shoreline_300.zip
