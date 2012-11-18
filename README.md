TileScape
==========

###![screenshot](https://raw.github.com/mapbox/osm-bright/master/preview.png)

TileScape provides scripts and templates that make it easy for you to set up
an OpenStreetMap server capable of dynamically serving custom tiles from your
own server.  It also helps you get started designing maps with TileMill, and
easily transitioning your styles to your own tile server.

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
- mod_tile (an apache module that renders tiles on the fly, using the renderd daemon)
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
difficulty with it, you may need to try installin everything manually.

When the script has finished running, you should be able to see your first set of tiles at

	http://SERVER_IP_ADDRESS/map.html

If everything is good, you're ready to start designing your own tiles!  The server is rockin'
and rollin'.


### 2. Setup Your Local Machine with TileMill and PostGIS ###



You will need an OSM database extract in one of the following formats:

- .osm.pbf (binary; smallest & fastest)
- .osm.bz2 (compressed xml)
- .osm (xml)

You can find appropriate data extracts for a variety of regions at
<http://download.geofabrik.de/osm> or <http://downloads.cloudmade.com>. Exracts
of select metropolitan areas are available at <http://metro.teczno.com>. See
[the OSM wiki][2] for information about (very large) full-planet downloads.

You need to process this data and import it to your PostGIS database. You can
do this with either [Imposm][] or [osm2pgsql][]; see their respective websites
for installation instructions.

#### Using Imposm

If you are using Imposm, you should use the [included mapping configuration][4]
which includes a few important tags compared to the default. The Imposm import 
command looks like this:

    imposm -U <postgres_user> -d <postgis_database> \
      -m /path/to/osm-bright/imposm-mapping.py --read --write \
      --optimize --deploy-production-tables <data.osm.pbf>

See `imposm --help` or the [online documentation][3] for more details.

#### Using osm2pgsql

If you are using osm2pgsql the default style file should work well. The 
osm2pgsql import command looks like this:

    osm2pgsql -c -G -U <postgres_user> -d <postgis_database> <data.osm.pbf>

See `man osm2pgsql` or the [online documentation][5] for more details.

[2]: http://wiki.openstreetmap.org/wiki/Planet
[Imposm]: http://imposm.org/
[3]: http://imposm.org/
[4]: https://github.com/mapbox/osm-bright/blob/master/imposm-mapping.py
[osm2pgsql]: http://wiki.openstreetmap.org/wiki/Osm2pgsql
[5]: http://wiki.openstreetmap.org/wiki/Osm2pgsql

### 3. Edit the configuration ###

You'll need to adjust some settings for things like your PostgreSQL connection
information.

1. Make a copy of `configure.py.sample` and name it `configure.py`.
2. Open `configure.py` in a text editor.
3. Make sure the "importer" option matches the program you used to import your 
   data (either "imposm" or "osm2pgsql").
4. Optionally change the name of your project from the default, 'OSM Bright'.
5. Adjust the path to point to your MapBox project folder.
6. Make any adjustments to the PostgreSQL connection settings. Your database
   may be set up so that you require a password or different user name.
7. Optionally adjust the query extents or shapefile locations. (Refer to the 
   comments in the configuration file for more information.)
8. Save & close the file.

### 4. Run make.py ###

This will create a new folder called "build" with your new project, customized
with the variables you set in `configure.py` and install a copy of this build
to your MapBox project folder. If you open up TileMill you should see your new
map in the project listing.

You're now ready to start editing the template in TileMill!
