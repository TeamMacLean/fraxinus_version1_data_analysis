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
print "\nNumber of variants from each strain\nvcf_file\tbam_file\tsnp\tindel"
Dir.glob("*.vcf") do |vcffile|
	bamfile2 = vcffile.gsub("\.vcf", "")
	sam = File.read(vcffile)
	sam.split("\n").each do |entry|
		if entry !~ /^\#/
			info = entry.split("\t")
			puzzleid = [info[4], info[3]].join("_")
			if info[11] =~ /^INDEL/
				variants[:indel][bamfile2][puzzleid] = info[5]
			else
				variants[:snp][bamfile2][puzzleid] = info[5]
			end
		end
	end
	print "\n#{vcffile}\t#{bamfile2}\t#{variants[:snp][bamfile2].length}\t#{variants[:indel][bamfile2].length}"
end
print "\n"

toplist = File.new("Highscore_info.txt", "w")
toplist.puts "ID\tvariant\tHighScore\tNoOfUsersWithHighScore\tNoOfReadsinPuzzle\t\
NoOfUsableReadsinPuzzle\tUserPercentDifferntToBWA\tMeanPercentOfReadsDifferent\t\
NoOfReadsinPuzzleCovALT\tUserPercentDifferntToBWACovALT\tMeanPercentOfReadsDifferentCovALT\n"

fraxpuzzle = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
#Dataset.find_each(start: 10088, batch_size: 10) do |datasetid|
Dataset.find_each do |datasetid|
	bamfilename =  datasetid.bam_filename                            # bamfile name of current puzzle
	inputreadcount = datasetid.sam_file.split("\n").count.to_i 		     # total number of reads
	samreads, allreadcount = Fraxcalc.allreads(datasetid.sam_file)				       # hash of read ids in puzzle
	selreads, selreadcount = Fraxcalc.selectreads(datasetid.sam_file, samreads, sam_select_read, bamfilename)		 # reads covering ALT allele count
	basepattern = datasetid.base_pattern.chop
	basepattern = basepattern.gsub("\n","_")
	basepattern = basepattern.gsub(">","")

	position_info = 0
	variant = ""
	if variants[:indel][bamfilename].key?(basepattern) == true
		variant = "indel"
		position_info = variants[:indel][bamfilename][basepattern]
	elsif variants[:snp][bamfilename].key?(basepattern) == true
		variant = "snp"
		position_info = variants[:snp][bamfilename][basepattern]
	else
		warn("#{datasetid.id}\n")
	end
	correct_pos_in_play = position_info.to_i - 10		# now we know real puzzle position and long reference sequence
	pos_in_play = datasetid.pos.to_i
	difference = correct_pos_in_play - pos_in_play

	if fraxpuzzle[bamfilename].key?(variant) == true
		fraxpuzzle[bamfilename][variant] += 1
	else
		fraxpuzzle[bamfilename][variant] = 1
	end

	patterns = 	Pattern.where(dataset_id: datasetid.id)
	scores = patterns.pluck(:score)									         # score array from all patterns of current puzzle
	high = scores.max.to_i
	highcount = scores.count(high)

	## Try to avoid puzzles with negative score, or i could use ceratin cut off here to avoid a minimum score puzzles
	if high > 0

		high_mismatch = 0
		high_read_mm = []
		high_mismatch_sel = 0
		high_read_mm_sel = []

		patterns.each do |pattern|
			if pattern.score.to_i == high
				counter = Fraxcalc.mm_allreads(pattern.cigar_files, samreads, difference).to_i
				selectcount = Fraxcalc.mm_selreads(pattern.cigar_files, selreads, difference).to_i
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

		toplist.puts "#{datasetid.id}\t#{variant}\t#{high}\t#{highcount}\t#{inputreadcount}\t#{allreadcount}\t#{high_mmpercent}\t#{high_read_mm_mean}\t#{selreadcount}\t#{high_mm_sel_percent}\t#{high_read_mm_sel_mean}\n"
	end
end

print "\n"
fraxpuzzle.each_key { |file|
	print "#{file}"
	fraxpuzzle[file].each_key { |var|
		count = fraxpuzzle[file][var]
		print "\t#{var}\t#{count}"
	}
	print "\n"
}
