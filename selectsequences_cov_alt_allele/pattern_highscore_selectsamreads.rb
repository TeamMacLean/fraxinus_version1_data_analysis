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
				variants[bamfile2][puzzleid] = "indel"
			else
				variants[bamfile2][puzzleid] = "snp"
			end
		end
	end
end

toplist = File.new("Highscore_info.txt", "w")
toplist.puts "ID\tvariant\tScore\tNoOfReadsinPuzzle\tUsableReadsinPuzzle\t\
ReadsDifferntToBWA\tNoOfReadsinPuzzleCovALT\tSelReadsDifferntToBWACovALT\n"

#Dataset.find_each(start: 10088, batch_size: 10) do |datasetid|
Dataset.find_each do |datasetid|
	bamfilename =  datasetid.bam_filename                            # bamfile name of current puzzle
	inputreadcount = datasetid.sam_file.split("\n").count.to_i 		     # total number of reads
	samreads, allreadcount = Fraxinus.allreads(datasetid.sam_file)				       # hash of read ids in puzzle
	selreads, selreadcount = Fraxinus.selectreads(datasetid.sam_file, samreads, sam_select_read, bamfilename)		 # reads covering ALT allele count
	basepattern = datasetid.base_pattern.gsub("\n","_")
	basepattern = basepattern.gsub(">","")
	patterns = 	Pattern.where(dataset_id: datasetid.id)
	patterns.each do |pattern|
		counter = Fraxinus.mm_allreads(pattern.cigar_files, samreads).to_i
		selectcount = Fraxinus.mm_selreads(pattern.cigar_files, selreads).to_i
		toplist.puts "#{datasetid.id}\t#{variants[bamfilename][basepattern]}\t#{pattern.score}\t\
		#{inputreadcount}\t#{allreadcount}\t#{counter}\t#{selreadcount}\t#{selectcount}\n"
	end
end

