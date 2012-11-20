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
# This script will take a freshly setup Ubuntu 12.04 machine and set it
# up with an OpenStreetMap database that is continually updated.  It
# also sets up Mapnik to render tiles and images.
########################################################################

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
THIS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME=$(readlink -m $THIS/..)
#HOME=/root/tilescape  # Change this if you want to put your tilescape project files elsewhere
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

echo "$HOME"

######################
## Make directories ##
######################
if [ ! -d $HOME ]; then
	echo "Making directory $HOME"
	mkdir $HOME
else
	echo "Directory $HOME exists"
fi
if [ ! -d $SRC ]; then
	echo "Making directory $SRC"
	mkdir -p $SRC
else
	echo "Directory $SRC exists"
fi
if [ ! -d $DATA ]; then
	echo "Making directory $DATA"
	mkdir -p $DATA
else
	echo "Directory $DATA exists"
fi
if [ ! -d $BIN ]; then
	echo "Making directory $BIN"
	mkdir -p $BIN
else
	echo "Directory $BIN exists"
fi
echo "Updating apt-get"
sudo apt-get update
sudo apt-get -y install libfreetype6-dev libtool autoconf make libboost-all-dev
IP=$(curl ifconfig.me)
#git clone git://github.com/ramunasd/mod_tile.git
#apt-get -y install autoconf make

##############################
## Setup PostgreSQL/PostGIS ##
##############################
echo "############################################################"
echo "Installing PostgreSQL 9.1 and PostGIS extensions..."
echo "############################################################"
sudo apt-get -y install python-software-properties
sudo add-apt-repository -y ppa:pitti/postgresql
sudo apt-get update
sudo apt-get -y install postgresql-9.1 postgresql-9.1-postgis postgresql-contrib-9.1 libpq-dev
# Adjust PostgreSQL settings all to trust locally
# And adjust settings for import
echo "*********************************************"
echo "*****  Making PostgreSQL very trusting  *****"
echo "*********************************************"
sed -i s/"ident"/"trust"/ /etc/postgresql/9.1/main/pg_hba.conf
sed -i s/"md5"/"trust"/ /etc/postgresql/9.1/main/pg_hba.conf
sed -i s/"peer"/"trust"/ /etc/postgresql/9.1/main/pg_hba.conf
sed -i s/"shared_buffers = 24MB"/"shared_buffers = 128MB"/ /etc/postgresql/9.1/main/postgresql.conf
sed -i s/"#checkpoint_segments = 3"/"checkpoint_segments = 20"/ /etc/postgresql/9.1/main/postgresql.conf
sed -i s/"#maintenance_work_mem = 16MB"/"maintenance_work_mem = 256MB"/ /etc/postgresql/9.1/main/postgresql.conf
sed -i s/"#autovacuum = on"/"autovacuum = off"/ /etc/postgresql/9.1/main/postgresql.conf
sudo sh -c "echo 'kernel.shmmax=268435456' > /etc/sysctl.d/60-shmmax.conf"
sudo service procps start
# Allow us to access postgresql from our local network
echo "host all all $LOCAL_IP/24 trust" >> /etc/postgresql/9.1/main/pg_hba.conf
sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/ /etc/postgresql/9.1/main/postgresql.conf
sudo /etc/init.d/postgresql restart


####################
## Install Apache ##
####################
echo "##############################################"
echo "Installing Apache2..."
echo "##############################################"
sudo apt-get -y install apache2


###################
## Setup Osmosis ##
###################
if [ ! -x $OSMOSIS ]; then
	echo "##############################################"
	echo "Installing Osmosis..."
	echo "##############################################"
	cd $SRC
	sudo apt-get -y install openjdk-6-jdk
	wget http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz
	tar xvfz osmosis-latest.tgz
	cd osmosis-*
	chmod a+x bin/osmosis
	ln -s $SRC/osmosis-*/bin/osmosis /bin/osmosis
	cd $HOME
else
	echo "Osmosis already installed..."
fi


#######################
## Install osm2pgsql ##
#######################
if [ ! -x $OSM2PGSQL ]; then
	echo "##############################################"
	echo "Installing Osm2pgsql..."
	echo "##############################################"
	sudo add-apt-repository -y ppa:kakrueger/openstreetmap
	sudo apt-get update
	sudo apt-get -y install osm2pgsql
else
	echo "Osm2pgsql already installed..."
fi


################################################
## Adding additional language to our database ##
################################################
cd $DATA
wget http://svn.openstreetmap.org/applications/utils/export/osm2pgsql/default.style
mv default.style $OSM2PGSQL_STYLESHEET
echo "node,way   $LANGUAGE      text         linear" >> $OSM2PGSQL_STYLESHEET


##########################
## Install Mapnik v 2.1 ##
##########################
if [ ! -d $MAPNIK_PYTHON_DIR ]; then
	echo "##############################################"
	echo "Installing Mapnik..."
	echo "##############################################"
	sudo add-apt-repository -y ppa:mapnik/v2.1.0
	sudo apt-get update
	sudo apt-get install -y libmapnik mapnik-utils python-mapnik
else
	echo "Mapnik already installed..."
fi


############################
## Create an OSM database ##
############################
echo "##############################################"
echo "Creating database $DB_NAME..."
echo "##############################################"
psql -U postgres -c "create database $DB_NAME;"
psql -U postgres -d $DB_NAME -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
psql -U postgres -d $DB_NAME -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql


##############
## Get data ##
##############
echo "##############################################"
echo "Downloading $DOWNLOAD_FILE..."
echo "##############################################"
wget $DOWNLOAD_FILE -O $DATA/$FILE
# Let's get the timestamp of the file too
YEAR=$(date -r $DATA/$FILE +%Y)
MONTH=$(date -r $DATA/$FILE +%m)
DAY=$(date -r $DATA/$FILE +%d)
HOUR=$(date -r $DATA/$FILE +%k)
MINUTE=$(date -r $DATA/$FILE +%M)
SECOND=$(date -r $DATA/$FILE +%S)
if [[ "$IMPORT_STRATEGY" == "EXTRACT" ]]; then
	osmosis --rx $DATA/$FILE --bb left=$MIN_LON top=$MAX_LAT right=$MAX_LON bottom=$MIN_LAT --wx $DATA/extract.osm.bz2
	FILE="extract.osm.bz2"
fi

#################
## Import data ##
#################
echo "##############################################"
echo "Importing Data..."
echo "##############################################"
osm2pgsql --slim -U postgres -d $DB_NAME -S $OSM2PGSQL_STYLESHEET --cache-strategy sparse --cache 10 $DATA/$FILE


###################################
## Setup Minutely Mapnik updates ##
###################################
if [[ $DIFF_UPDATE ]]; then
	echo "##############################################"
	echo "Importing Diffs..."
	echo "##############################################"
	echo "Diff information will be stored in $DIFF_WORKDIR"
	echo "Using the file $DATA/$FILE"
	echo "Using the bounding box $MIN_LON,$MIN_LAT,$MAX_LON,$MAX_LAT"
	echo "We're going to load recent changes first..."
	if [ ! -d $DIFF_WORKDIR ]; then
		mkdir $DIFF_WORKDIR
	fi
	osmosis --read-replication-interval-init workingDirectory=$DIFF_WORKDIR
	wget "http://toolserver.org/~mazder/replicate-sequences/?Y=$YEAR&m=$MONTH&d=$DAY&H=$HOUR&i=$MINUTE&s=$SECOND&stream=minute#" -O $DIFF_WORKDIR/state.txt
	sed -i s/"minute-replicate"/"replication\/minute"/ $DIFF_WORKDIR/configuration.txt
	osmosis -q --rri workingDirectory=$DIFF_WORKDIR --simc --write-xml-change $DATA/changes.osc.gz
	osm2pgsql -a -s -b "$MIN_LON,$MIN_LAT,$MAX_LON,$MAX_LAT" -U postgres -d $DB_NAME -e 15 -o $DATA/expire.list -S $OSM2PGSQL_STYLESHEET --cache-strategy sparse --cache 10 $DATA/changes.osc.gz
fi

# Setup Cron Job
# We'll create a script to update the database and then add it to the crontab
if [[ $DIFF_UPDATE ]]; then
	echo "##############################################"
	echo "Setting up cron job to apply diffs..."
	echo "##############################################"
	touch $DATA/update_osm_db.sh
	echo "#!/bin/bash
# This script will update the $DB_NAME database with OpenStreetMap Data...
# We need the bounding box of this area
MIN_LON=34.125 	# left
MIN_LAT=31.16 	# bottom
MAX_LON=34.648 	# right
MAX_LAT=31.708 	# top

DB_NAME=osm
DB_USER=postgres

# Directories
HOME=~
SRC=\$HOME/src
DATA=\$HOME/data
DIFF_WORKDIR=\$DATA/.diffs

#YEAR=\$(date -r \$DATA/changes.osc.gz +%Y)
#MONTH=\$(date -r \$DATA/changes.osc.gz +%m)
#DAY=\$(date -r \$DATA/changes.osc.gz +%d)
#HOUR=\$(date -r \$DATA/changes.osc.gz +%k)
#MINUTE=\$(date -r \$DATA/changes.osc.gz +%M)
#SECOND=\$(date -r \$DATA/changes.osc.gz +%S)

#rm -rf \$DIFF_WORKDIR/*
rm \$DATA/expire.list
rm \$DATA/changes.osc.gz.prev
cp \$DATA/changes.osc.gz \$DATA/changes.osc.gz.prev
rm \$DATA/changes.osc.gz

#osmosis --read-replication-interval-init workingDirectory=\$DIFF_WORKDIR
#wget \"http://toolserver.org/~mazder/replicate-sequences/?Y=\$YEAR&m=\$MONTH&d=\$DAY&H=\$HOUR&i=\$MINUTE&s=\$SECOND&stream=minute#\" -O \$DIFF_WORKDIR/state.txt
#sed -i s/\"minute-replicate\"/\"replication\/minute\"/ \$DIFF_WORKDIR/configuration.txt
osmosis -q --rri workingDirectory=\$DIFF_WORKDIR --simc --write-xml-change \$DATA/changes.osc.gz
osm2pgsql -a -s -b \"\$MIN_LON,\$MIN_LAT,\$MAX_LON,\$MAX_LAT\" -U postgres -d \$DB_NAME -e 15 -o \$DATA/expire.list -S $OSM2PGSQL_STYLESHEET --cache-strategy sparse --cache 10 \$DATA/changes.osc.gz" > $DATA/update_osm_db.sh

	chmod +x $DATA/update_osm_db.sh
	#write out current crontab
	crontab -l > mycron
	#echo new cron into cron file
	echo "$CRON_TIME $DATA/update_osm_db.sh" >> mycron
	#install new cron file
	crontab mycron
	rm mycron
fi


########################
## Get shapefile data ##
########################
echo "##############################################"
echo "Getting shapefile data..."
echo "##############################################"
sudo apt-get -y install unzip
cd $HOME
if [ ! -d shared ]; then
	mkdir shared
fi
if [ ! -d shared/shapefiles ]; then
	mkdir shared/shapefiles
fi
cd shared/shapefiles
wget http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.3.0/physical/10m-land.zip
wget http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.4.0/cultural/10m-populated-places-simple.zip
wget http://tilemill-data.s3.amazonaws.com/osm/coastline-good.zip
wget http://tilemill-data.s3.amazonaws.com/osm/shoreline_300.zip
unzip 10m-land.zip
unzip 10m-populated-places-simple.zip
unzip coastline-good.zip
unzip shoreline_300.zip


#####################
## Setup Tilecache ##
#####################
echo "##############################################"
echo "Installing TileCache..."
echo "##############################################"
cd /var/www
wget http://tilecache.org/tilecache-2.11.tar.gz
tar -zvxf tilecache-*.tar.gz
rm tilecache-*.tar.gz
mv tilecache-* tilecache
echo "
[osm]
type=Mapnik
mapfile=/root/tilescape/project/default/default.xml
spherical_mercator=true" >> tilecache/tilecache.cfg
echo "
<Directory /var/www/tilecache>
     AddHandler cgi-script .cgi
     Options +ExecCGI
</Directory>" >> /etc/apache2/apache2.conf
/etc/init.d/apache2 restart


#############################
## Generate a sample image ##
#############################
cd $THIS
sed -i s/"bounds = (-6.5, 49.5, 2.1, 59)"/"bounds = ($MIN_LON, $MIN_LAT, $MAX_LON, $MAX_LAT)"/ generate_image.py
./generate_image.py
cp image.png /var/www
echo "#########################################"
echo "############___#########___##############"
echo "############|##|#######|##|##############"
echo "############|__|#######|__|##############"
echo "#########################################"
echo "###################>>>###################"
echo "####################>>###################"
echo "#########################################"
echo "###########|||#############||############"
echo "#############|||||||||||||||#############"
echo "#########################################"
echo ""
echo "Visit http://$IP/image.png to see a sample image rendered with the default stylesheet"
echo ""

#########################################
## Add our sample map.html to /var/www ##
#########################################
cd $THIS
cp map.html /var/www/map.html
echo "Go to http://$IP/map.html to see your tiles working..."



















