#!/bin/ruby

require 'etc'
require 'fileutils'


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
TILEMILL_DIR="#{Etc.getpwuid.dir}/Documents/MapBox/project"

LOCAL_DB_NAME="tilemill_osm"
SERVER_DB_NAME="osm"
SERVER_LOGIN="root@50.56.237.60"

#########################################


# Get tilescape directory
SCRIPT_DIR=File.expand_path(File.dirname(__FILE__))
TILESCAPE_DIR=File.expand_path("..",SCRIPT_DIR)

puts PROJECT_NAME
puts TILEMILL_DIR
puts SCRIPT_DIR
puts TILESCAPE_DIR

# Copy XML, Fonts and Images from the TileMill directory into the TileScape directory
FileUtils.rm_rf("#{TILESCAPE_DIR}/project/#{PROJECT_NAME}/fonts")
FileUtils.cp_r("#{TILEMILL_DIR}/#{PROJECT_NAME}/fonts", "#{TILESCAPE_DIR}/project/#{PROJECT_NAME}")
FileUtils.rm_rf("#{TILESCAPE_DIR}/project/#{PROJECT_NAME}/img")
FileUtils.cp_r("#{TILEMILL_DIR}/#{PROJECT_NAME}/img", "#{TILESCAPE_DIR}/project/#{PROJECT_NAME}")
FileUtils.cp("#{TILEMILL_DIR}/#{PROJECT_NAME}/mapnik.xml", "#{TILESCAPE_DIR}/project/#{PROJECT_NAME}/mapnik.xml")

# Replace the shapefile locations in mapnik.xml
file = File.open("#{TILESCAPE_DIR}/project/#{PROJECT_NAME}/mapnik.xml", "rb")
contents = file.read
shp_strings = contents.scan(/\[\/.*shp/)
shps = []
shp_strings.each do |str|
  start = str.rindex(/\//) + 1
  finish = str.rindex(/shp/) + 2
  shps << str[start..finish]
  puts str[start..finish]
end
shp_strings.each_with_index do |str, index|
  contents.gsub!((str[1..-1]), "../../shared/shapefiles/#{shps[index]}")
end
File.open("#{TILESCAPE_DIR}/project/#{PROJECT_NAME}/mapnik.xml", "w") {|file| file.puts contents}

# Replace the database name in mapnik.xml
file = File.open("#{TILESCAPE_DIR}/project/#{PROJECT_NAME}/mapnik.xml", "rb")
contents = file.read
contents.gsub!("[CDATA[#{LOCAL_DB_NAME}]]", "[CDATA[#{SERVER_DB_NAME}]]")
File.open("#{TILESCAPE_DIR}/project/#{PROJECT_NAME}/mapnik.xml", "w") {|file| file.puts contents}

# Send project files to server
system("scp -r #{TILESCAPE_DIR}/project/#{PROJECT_NAME} #{SERVER_LOGIN}:/root/tilescape/project")

# Add new project to tilecache config
proj_cfg = "
[#{PROJECT_NAME}]
type=Mapnik
mapfile=/root/tilescape/project/#{PROJECT_NAME}/mapnik.xml
spherical_mercator=true"

system("ssh #{SERVER_LOGIN} 'echo \"#{proj_cfg}\" >> /var/www/tilecache/tilecache.cfg'")








