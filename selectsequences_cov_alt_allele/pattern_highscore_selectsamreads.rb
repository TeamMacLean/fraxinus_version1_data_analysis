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
print "\nReads selected covering the alt allele"
Dir.glob("*-selected.sam") do |samfile|
	bamfile = samfile.gsub("-selected.sam","")
	sam = File.read(samfile)
	sam.split("\n").each do |entry|
			info = entry.split("\t")
			term = [info[0], info[1], info[3]].join("_")
			sam_select_read[bamfile][term] = entry
	end
	print "\n#{samfile}\t#{bamfile}\t#{sam_select_read[bamfile].length}"
end
print "\n"

variants = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
Dir.glob("*.vcf") do |vcffile|
	bamfile2 = vcffile.gsub("\.vcf", "")
	sam = File.read(vcffile)
	sam.split("\n").each do |entry|
		if entry !~ /^\#/
			info = entry.split("\t")
			puzzleid = [info[4], info[3]].join("_")
			if info[11] =~ /^INDEL/
				variants[:indel][bamfile2] = puzzleid
			else
				variants[:snp][bamfile2] = puzzleid
			end
		end
	end
end

toplist = File.new("Highscore_info.txt", "w")
toplist.puts "ID\tHighScore\tNoOfUsersWithHighScore\tNoOfReadsinPuzzle\t\
NoOfUsableReadsinPuzzle\tUserPercentDifferntToBWA\tMeanPercentOfReadsDifferent\t\
NoOfReadsinPuzzleCovALT\tUserPercentDifferntToBWACovALT\tMeanPercentOfReadsDifferentCovALT\n"

#Dataset.find_each(start: 10088, batch_size: 10) do |datasetid|
Dataset.find_each do |datasetid|
	bamfilename =  datasetid.bam_filename                            # bamfile name of current puzzle
	inputreadcount = datasetid.sam_file.split("\n").count.to_i 		     # total number of reads
	samreads, allreadcount = Fraxinus.allreads(datasetid.sam_file)				       # hash of read ids in puzzle
	selreads, selreadcount = Fraxinus.selectreads(datasetid.sam_file, samreads, sam_select_read, bamfilename)		 # reads covering ALT allele count
<<<<<<< HEAD
	basepattern = datasetid.base_pattern.chop
	basepattern = basepattern.gsub("\n","_")
	basepattern = basepattern.gsub(">","")
	patterns = 	Pattern.where(dataset_id: datasetid.id)
	patterns.each do |pattern|
		counter = Fraxinus.mm_allreads(pattern.cigar_files, samreads).to_i
		selectcount = Fraxinus.mm_selreads(pattern.cigar_files, selreads).to_i
		variant = variants[bamfilename.to_s][basepattern.to_s]
		# warn("#{bamfilename.to_s}\t#{basepattern.to_s}\n")
		toplist.puts "#{datasetid.id}\t#{variant}\t#{pattern.score}\t\
		#{inputreadcount}\t#{allreadcount}\t#{counter}\t#{selreadcount}\t#{selectcount}\n"
=======
	patterns = 	Pattern.where(dataset_id: datasetid.id)
	scores = patterns.pluck(:score)									         # score array from all patterns of current puzzle
	high = scores.max.to_i

	## Try to avoid puzzles with negative score, or i could use ceratin cut off here to avoid a minimum score puzzles
	if high > 0

		highcount = scores.count(high)
		high_mismatch = 0
		high_read_mm = []
		high_mismatch_sel = 0
		high_read_mm_sel = []

		patterns.each do |pattern|
			if pattern.score.to_i == high
				counter = Fraxinus.mm_allreads(pattern.cigar_files, samreads).to_i
				selectcount = Fraxinus.mm_selreads(pattern.cigar_files, selreads).to_i
				if counter > 0
					percent_mm_read = (counter * 100)/allreadcount.to_i
					high_read_mm.push(percent_mm_read.to_f)
					high_mismatch = high_mismatch + 1
				end
				if selectcount > 0 
					percent_mm_read_sel = (selectcount * 100)/selreadcount.to_i
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

		toplist.puts "#{datasetid.id}\t#{high}\t#{highcount}\t#{inputreadcount}\t#{allreadcount}\t#{high_mmpercent}\t#{high_read_mm_mean}\t#{selreadcount}\t#{high_mm_sel_percent}\t#{high_read_mm_sel_mean}\n"
>>>>>>> parent of 216bd3f... printing variant type, each variant score and no of reads not matching etc for all alignments
	end
end

