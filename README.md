TileScape
==========

###![screenshot](https://raw.github.com/jeffhaack/tilescape/master/preview.png)

TileScape provides scripts and templates that make it easy for you to set up
an OpenStreetMap server capable of dynamically serving custom tiles.  It also
helps you get started designing maps with TileMill, and easily transitioning
your styles to your own tile server.

This is a work in progress and you are encouraged to use the
[issue tracker][] to note missing features or problems with the current
implementation.


[TileMill]: http://tilemill.com/
[issue tracker]: http://github.com/jeffhaack/tilescape/issues/
[GeoFabrik]: http://download.geofabrik.de/openstreetmap/

Setup Instructions
------------------

### 1. Setup the Server ###

An OpenStreetMap server capable of serving tiles requires the following:

- Postgresql with PostGIS extensions (and some custom setup)
- osm2pgsql (a program for importing OSM data into your postgis database)
- mapnik (renders image tiles from the database; we require >= 2.0.2 for TileMill compatibility)
- apache2 (web server to serve tiles)
- tilecache (a cgi program which renders and caches tiles)
- osmosis (optional - if you want to update your database regularly with diffs)

TileScape provides a shell script that will set up a new Ubuntu 12.04 machine as your
tileserver, clean and ready to go. If you choose to run this script, your server should
be ready and you can skip to section 2, setting up your local machine. If you want to set
up your OpenStreetMap server manually, see the instructions ###HERE###

Before running provision_precise1204.sh, open it with a text editor and adjust some of the
options. The script will create a database and import OSM data for you, so you must specify
where to find the data that you want to import.

You may choose one of two strategies for importing data, either FILE or EXTRACT.  If you
choose the FILE strategy you must specify a .osm.bz2 file for the script to download and
import.  You can find country and regional exports at [GeoFabrik][]. You must also set the
bounding box coordinates for the area you are importing.

In some cases you may want to choose the EXTRACT strategy. Rather than using a region that
has already been extracted, this strategy will use Osmosis to cut out a piece of the map
itself. It is recommended that you ONLY use this strategy when the area you want to import
is not available as an extract already, because it may take considerably more time.  To use
this option, you must specify a file that contains the area you want to import, and then set
the bounding box for the section you which to slice out and import into your database. For
example, if your country of interest is not available as an extract or you simply want a small
part of a country, you may use this strategy. As an example, you might set the file to
asia.osm.bz2 and then set a small bounding box in Asia for the area you want to extract.

You may also change some of the directories that the script creates, however it is recommended
that you retain the defaults.

If you do not want your server to update the data regularly or wish to change the frequency of
the updates, you may edit the settings for this. By default this script sets up a cron job that
will fetch OpenStreetMap diffs and update your database every 5 minutes.

To run the script on a new machine:

	scripts/provision_precise1204.sh

This script should work cleanly on a freshly installed Ubuntu 12.04 machine.  If you are having
difficulty with it, you may need to try installing everything manually.

When the script has finished running, you should be able to see your first set of tiles at

	http://SERVER_IP_ADDRESS/map.html

If everything is good, you're ready to start designing your own tiles!  The server is rockin'
and rollin'.


### 2. Setup Your Local Machine with TileMill and PostGIS ###

Next you will want your local machine to be set up so that you can easily style your maps
with TileMill and seamlessly transfer the styles to your server.  You will need the following
on your local machine:

- Postgresql with PostGIS extensions (optional)
- a database with osm data, such as the one created on the server in step 1 (optional)
- [TileMill]

It is recommended that you set up a PostGIS database on your local machine for designing
stylesheets in TileMill. This is not strictly necessary, as you could easily connect to
your server database, but because your server is probably located remotely it will take
considerable time to query the database, and when you are designing in TileMill you will
want your tiles to update quickly.

If you are installing on Mac OS X, we recommend using the installers provided at
[http://www.kyngchaos.com/software:postgres]

Run the PostgreSQL 9.1.* and PostGIS 2.0.* for Postgres 9.1 installers.

Create a database:

	psql -U postgres -c "create database tilemill_osm;"
	psql -U postgres -d tilemill_osm -c "CREATE EXTENSION postgis;"

Download an extract file from [GeoFabrik][]. It can be anything you want to use in TileMill,
but it will be easier to design if you import the same data that you did on the server.

Then import the data into your database:

	osm2pgsql -c -G -U postgres -d tilemill_osm -S /usr/local/share/osm2pgsql/default.style OSM_FILE

Go the the scripts directory of tilescape and run

	./setup_local.sh

to download the base shapefiles.

Edit the settings in create_project.sh.  Then run it:

	./create_project.sh

This will create a new project in your TileMill directory that you can edit with TileMill.

When you are done styling this you can (reasonably) easily send it to your server. First
in TileMill go to "Export -> Mapnik XML" and save the file as "mapnik.xml" in the TileMill
project directory.

Then then run the ruby script in the tilescape scripts directory.  This script will copy the mapnik.xml
file, edit the paths to shapefiles and database settings so that it matches those on your server, and then
it will use scp to upload the files onto your server and add the project to tilecache.

	ruby push_project.rb

















