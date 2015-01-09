#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'
require 'active_record'
require 'time_diff'
require 'date'
require 'pp'
require './connect_mysql_db.rb'
I18n.enforce_available_locales = false


# hash = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
## notification table
##	id	type	timestamp	player_from	player_to	fb_request_id	dataset_id	new_score	prev_score
## user table
##	id	name	fbid	score	bonus_points
## pattern table
##	id	user_id	dataset_id	score	cigar_files	last_saved	current_best	was_best	icon_id

print "UserID\tName\tFBid\tFBScore\tTimestamp\tScore\n"

User.find_each do |userid|
	details = [userid.name, userid.fbid, userid.score].join("\t")
	Pattern.where(user_id: userid.id).each do | pattern |
		print "#{userid.id}\t#{details}\t#{pattern.last_saved}\t#{pattern.score}\n"
	end
end
