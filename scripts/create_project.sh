#!/bin/bash

########################################################################
# Copyright (C) 2012 Jeff Haack
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
########################################################################

# This script will create a new project in your TileMill directory that can
# be used will your TileScape setup

#########################################

# Edit these settings #
PROJECT_NAME="My_New_TileScape_Project2"
TILEMILL_DIR=$(eval echo ~${USER})/Documents/MapBox/project

LOCAL_DB_NAME="tilemill_osm"
SERVER_DB_NAME="osm"

#########################################

# Get tilescape directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TILESCAPE_DIR="$(dirname "$SCRIPT_DIR")"

echo "$SCRIPT_DIR"
echo "$TILESCAPE_DIR"
echo "$TILEMILL_DIR"

# Create a copy of the default project
cp -r $TILESCAPE_DIR/project/default $TILESCAPE_DIR/project/$PROJECT_NAME

# Now create another copy and put it in the TileMill directory, and change the settings
cp -r $TILESCAPE_DIR/project/default $TILEMILL_DIR/$PROJECT_NAME
sed -ie s#SHARED_SHP#$TILESCAPE_DIR/shared/shapefiles#g $TILEMILL_DIR/$PROJECT_NAME/project.mml
sed -ie s#NEW_PROJECT_NAME#$PROJECT_NAME#g $TILEMILL_DIR/$PROJECT_NAME/project.mml
sed -ie s#DB_NAME#$LOCAL_DB_NAME#g $TILEMILL_DIR/$PROJECT_NAME/project.mml

# Now add the project to a list of projects 

# 

# Settings file must have
#  Local DB connection settings
#  Server DB connections settings


# Steps
# copy project to TileMill directory
# edit project settings to point to the correct shapes and database
# Add the project to a list of tilescape projects maintained in the script dir (add to to .gitignore)

# User edits the project, then when they want to upload they create mapnik xml and run push_project

# push_project gets the proper settings from the settings file and loads them into a tilescape copy of the project
# the copy is then pushed to the server









