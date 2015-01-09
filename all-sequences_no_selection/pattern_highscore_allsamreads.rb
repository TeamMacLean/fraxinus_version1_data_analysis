#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'
require 'active_record'
require 'pp'
require './connect_mysql_db.rb'
require './fraxinus_calcs.rb'

toplist = File.new("Highscore_info_allreads.txt", "w")
toplist.puts "ID\tHighScore\tNoOfUsersWithHighScore\tNoOfReadsinPuzzle\t\
NoOfUsableReadsinPuzzle\tUserPercentDifferntToBWA\tMeanPercentOfReadsDifferent\n"

datasets = Dataset.limit(10087)
#Dataset.find_each(start: 10088, batch_size: 10) do |datasetid|
datasets.each do |datasetid|
	bamfilename =  datasetid.bam_filename                            # bamfile name of current puzzle
	inputreadcount = datasetid.sam_file.split("\n").count.to_i 		     # total number of reads
	samreads, allreadcount = Fraxinus.allreads(datasetid.sam_file)				       # hash of read ids in puzzle
	patterns = 	Pattern.where(dataset_id: datasetid.id)
	scores = patterns.pluck(:score)									         # score array from all patterns of current puzzle
	high = scores.max.to_i

	## Try to avoid puzzles with negative score, or i could use ceratin cut off here to avoid a minimum score puzzles
	if high > 0

		highcount = scores.count(high)
		high_mismatch = 0
		high_read_mm = []

		patterns.each do |pattern|
			if pattern.score.to_i == high
				counter = Fraxinus.mm_allreads(pattern.cigar_files, samreads).to_i
				if counter > 0
					percent_mm_read = (counter * 100)/allreadcount.to_i
					high_read_mm.push(percent_mm_read.to_f)
					high_mismatch += 1
				end
			end
		end

		high_mmpercent = (high_mismatch * 100)/highcount
		high_read_mm_mean = 0
		if high_read_mm.empty? == false
			high_read_mm_mean = high_read_mm.inject(:+).to_f/high_read_mm.size
		end

		toplist.puts "#{datasetid.id}\t#{high}\t#{highcount}\t#{inputreadcount}\t#{allreadcount}\t#{high_mmpercent}\t#{high_read_mm_mean}\n"
	end
end

