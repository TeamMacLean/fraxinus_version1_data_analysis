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

class Array
    def sum
        self.inject{|sum,x| sum + x }
    end
end

users = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
patterns = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
userstat = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}

## dataset table
##	id	sam_file	base_pattern	active	pos	bam_filename
## user table
##	id	name	fbid	score	bonus_points
## pattern table
##	id	user_id	dataset_id	score	cigar_files	last_saved	current_best	was_best	icon_id

print "Datsetid\tPlayers_total\tNo.ofalignments\tPlayers_active\tUsable_alignments\tEmpty_alignments\tMaxscoreperread\tReadnumber\n"

Dataset.find_each do |datasetid|
	inputreadcount = datasetid.sam_file.split("\n").length
	scores = Pattern.where(dataset_id: datasetid.id).pluck(:score)
	players = Pattern.where(dataset_id: datasetid.id).pluck(:user_id)
	player_num = players.uniq.length
	mean_max_score = scores.max.to_f/inputreadcount.to_f
	datasets = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
	not_empty_aln = 0
	Pattern.where(dataset_id: datasetid.id).each do | pattern|
		users[pattern.user_id][datasetid.id] = pattern
		patterns[datasetid.id][pattern.last_saved] = pattern
		userstat[pattern.user_id][DateTime.parse(pattern.last_saved.to_s).strftime('%F')][datasetid.id] = 1
		if pattern.cigar_files != "" 
			datasets[pattern.user_id][pattern.score] = 1
			not_empty_aln += 1
		end
	end
	empty_aln = scores.length.to_i - not_empty_aln
	active_players = datasets.length

=begin
	datasets.each_key { |playerid|
		if datasets[playerid].length > 1
			warn ("#{datasetid.id}\t#{playerid}\n")
		end
	}
=end

	print "#{datasetid.id}\t#{player_num}\t#{scores.length}\t#{active_players}\t#{not_empty_aln}\t#{empty_aln}\t#{mean_max_score.to_f}\t#{inputreadcount}\n"
		
end

=begin

userstat.each_key { |userid|
	days_no = userstat[userid].length
	tasks = []
	userstat[userid].each_key { |day|
		tasks.push(userstat[userid][day].length)
	}
	average = tasks.sum/tasks.size
	print "#{userid}\t#{days_no}\t#{average}\n"
}

	
	uniquedays = visitdays.uniq
	if (uniquedays.length > 1)
		sorted = uniquedays.sort
		timediff = Time.diff(sorted[0], sorted[-1], '%d')
		days = timediff[:diff].gsub(/\s\w+/, "").to_i + 1
		print "#{n}\t#{days}\t#{uniquedays.length}\t#{DateTime.parse(sorted[0].to_s).strftime('%F')}\t#{DateTime.parse(sorted[-1].to_s).strftime('%F')}\t#{details}\n"
	else
		print "#{n}\t1\t1\t#{uniquedays[0]}\t#{uniquedays[0]}\t#{details}\n"
	end
	
=end
