#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'
require 'active_record'
require 'pp'
require './connect_mysql_db.rb'
require './fraxinus_calcs.rb'

### Extract read info from the sam file of reads covering the variant region
sam_select_read = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
Dir.glob("*-selected.sam") do |samfile|
	bamfile = samfile.gsub("-selected.sam","")
	sam = File.read(samfile)
	sam.split("\n").each do |entry|
		info = entry.split("\t")
		term = [info[0], info[1], info[3]].join("_")
		sam_select_read[bamfile][term] = entry
	end
end
print "\n"

toplist = File.new("User_different_alignments.txt", "w")
toplist.puts "Reference\tPattern\tposition\tbamfile\tID\tHighScore\tNoOfUsersWithHighScore\t\
NoOfReadsinPuzzle\tNoOfUsableReadsinPuzzle\tUserPercentDifferntToBWA\tMeanPercentOfReadsDifferent\t\
NoOfReadsinPuzzleCovALT\tUserPercentDifferntToBWACovALT\tMeanPercentOfReadsDifferentCovALT\n"

Dataset.find_each do |datasetid|
	bamfilename =  datasetid.bam_filename                            # bamfile name of current puzzle
	inputreadcount = datasetid.sam_file.split("\n").count.to_i         # total number of reads
	samreads, allreadcount = Fraxinus.allreads(datasetid.sam_file)               # hash of read ids in puzzle
	selreads, selreadcount = Fraxinus.hash_selectreads(datasetid.sam_file, samreads, sam_select_read, bamfilename)    # reads covering ALT allele count

	basepattern = datasetid.base_pattern.gsub("\n","\t")
	altpos = datasetid.pos
	patterns =  Pattern.where(dataset_id: datasetid.id)
	scores = patterns.pluck(:score)                          # score array from all patterns of current puzzle
	high = scores.max.to_i

	## Try to avoid puzzles with negative score, or i could use ceratin cut off here to avoid a minimum score puzzles
	if high > 0

		highcount = scores.count(high)
		high_mismatch = 0
		high_read_mm = []
		high_mismatch_sel = 0
		high_read_mm_sel = []
		userdiff = Hash.new {|h,k| h[k] = {} }

		patterns.each do |pattern|
			if pattern.score.to_i == high
				counter = Fraxinus.mm_allreads(pattern.cigar_files, samreads)
				userdiff[pattern.id], selectcount = Fraxinus.hash_mm_selreads(pattern.cigar_files, selreads)
				if counter > 0 
					percent_mm_read = (counter * 100)/allreadcount
					high_read_mm.push(percent_mm_read.to_f)
					high_mismatch = high_mismatch + 1
				end
				if selectcount > 0 
					percent_mm_read_sel = (selectcount * 100)/selreadcount
					high_read_mm_sel.push(percent_mm_read_sel.to_f)
					high_mismatch_sel = high_mismatch_sel + 1
				end
			end
		end

		high_mmpercent = (high_mismatch * 100)/highcount
		high_read_mm_mean = 0
		if high_read_mm.empty? == false
			high_read_mm_mean = high_read_mm.inject(:+).to_f/high_read_mm.size
		end

		high_mm_sel_percent = (high_mismatch_sel * 100)/highcount
		high_read_mm_sel_mean = 0
		if high_read_mm_sel.empty? == false
			high_read_mm_sel_mean = high_read_mm_sel.inject(:+).to_f/high_read_mm_sel.size
		end

		if high_mm_sel_percent.to_i == 100
		# if high_mm_sel_percent.to_i > 0
			readdiff = Hash.new {|h,k| h[k] = {} }
			userdiff.each_key { |patternid|
				userdiff[patternid].each_key { |readid|
					if readdiff[readid].key?(userdiff[patternid][readid]) == true
						readdiff[readid][userdiff[patternid][readid]] = 1 + readdiff[readid][userdiff[patternid][readid]]
					else
						readdiff[readid][userdiff[patternid][readid]] = 1
					end
				}
			}

			readdiff.each_key{ |readposid|
				readdiff[readposid].each_key { |cigarid|
					toplist.print "#{basepattern}#{altpos}\t#{bamfilename}\t#{datasetid.id}\t#{high}\t#{highcount}\t#{inputreadcount}\t#{allreadcount}\t#{high_mmpercent}\t#{high_read_mm_mean}\t#{selreadcount}\t#{high_mm_sel_percent}\t#{high_read_mm_sel_mean}\t"
					toplist.print "#{readposid}\t#{selreads[readposid][:seq]}\t#{selreads[readposid][:cigar]}\t"
					toplist.print "#{cigarid}\t#{readdiff[readposid][cigarid]}\n"
				}
			}
		end

	end
end

