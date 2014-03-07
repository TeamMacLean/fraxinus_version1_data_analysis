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

#users = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
#patterns = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
userstat = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
useralns = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}

## dataset table
##	id	sam_file	base_pattern	active	pos	bam_filename
## user table
##	id	name	fbid	score	bonus_points
## pattern table
##	id	user_id	dataset_id	score	cigar_files	last_saved	current_best	was_best	icon_id

Dataset.find_each do |datasetid|
	inputreadcount = datasetid.sam_file.split("\n").length.to_i
	scores = Pattern.where(dataset_id: datasetid.id).pluck(:score)
	players = Pattern.where(dataset_id: datasetid.id).pluck(:user_id)
	
	Pattern.where(dataset_id: datasetid.id).each do | pattern|
		# users[pattern.user_id][datasetid.id] = pattern
		# patterns[datasetid.id][pattern.last_saved] = pattern
		term = [pattern.last_saved, datasetid.id].join("_")
		userstat[pattern.user_id][DateTime.parse(pattern.last_saved.to_s).strftime('%F')][term] = pattern
		if pattern.cigar_files == ""
			if useralns.has_key?(pattern.user_id) == true
				useralns[pattern.user_id] += 1
			else
			 	useralns[pattern.user_id] = 1
			end
		end
	end
end


print "UserId\tNoofDays\tTotalTasks\tMeanTaskperDay\tEmptyTasks\tFBScore\tFBBonus\tFBID\n"

User.find_each do |eachuser|
	userid = eachuser.id
	if userstat.has_key?(userid) == true
		days_no = userstat[userid].length
		tasks = []
		userstat[userid].each_key { |day|
			tasks.push(userstat[userid][day].length)
		}
		average = tasks.sum/tasks.size
		empty = 0
		if useralns.has_key?(userid) == true
			empty = useralns[userid]
		end
		print "#{userid}\t#{days_no}\t#{tasks.sum}\t#{average.to_f}\t#{empty}\t"
		userstat.delete(userid)
	else
		print "#{userid}\t0\t0\t0\t0\t"
	end
	print "#{eachuser.score}\t#{eachuser.bonus_points}\t#{eachuser.fbid}\n"
end

userstat.each_key { |id|
	userstat[id].each_key { |day|
		userstat[id][day].each_key { |pattern|
			print "#{userstat[id][day][pattern]}\n"
		}
	}
}

=begin
	
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
