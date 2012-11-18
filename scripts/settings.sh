#!/bin/bash

#####################################
########## CUSTOM OPTIONS ###########
#####################################

#################
# File Settings #
#################
# Set this to FILE OR EXTRACT
IMPORT_STRATEGY="FILE"
# Set these options - if you are using EXTRACT strategy, the bounding box you provide
#  will be sliced out of the file you download
FILE="gaza.osm.bz2"
DOWNLOAD_FILE="http://download.geofabrik.de/openstreetmap/asia/$FILE"
MIN_LON="34.125" 	# left
MIN_LAT="31.16" 	# bottom
MAX_LON="34.648" 	# right
MAX_LAT="31.708" 	# top

#####################
# Database Settings #
#####################
DB_NAME="osm" 			# The name you want your database to have (you can change this)
DB_USER=postgres 		# The database user for the DB - (don't change this)
LOCAL_IP="176.73.15.6"	# Provide your local IP address so you can connect to your database remotely

###################
# Import Settings #
###################
# Set this to an extra language you want to include in your database
LANGUAGE="name:ka" # add a name tag into the database (your stylesheet still must utilize this)

###################
# Update Settings #
###################
DIFF_UPDATE=true
CRON_TIME="0,5,10,15,20,25,30,35,40,45,50,55 * * * *" 	# How often should the database be updated?

#####################
# Directories/Files #
#####################
THIS=${PWD}
HOME=../$THIS  # Change this if you want to put your tilescape project files elsewhere
#HOME=~
SRC=$HOME/setup/src
DATA=$HOME/setup/data
BIN=$HOME/setup/bin
DIFF_WORKDIR=$DATA/.diffs
OSM2PGSQL_STYLESHEET=$DATA/multilingual.style

#####################
# Program Locations #
#####################
# we will install these programs if they don't already exist
POSTGRESQL=/etc/init.d/postgresql
APACHE=/etc/init.d/apache2
OSMOSIS=/bin/osmosis
OSM2PGSQL=/usr/bin/osm2pgsql
MAPNIK_PYTHON_DIR=/var/lib/python-support/python2.7/mapnik/

#########################################
########## END CUSTOM OPTIONS ###########
#########################################