#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'
require 'active_record'
require 'pp'

### Start mysql if it has not started
	status = %x[mysql.server status]
	warn (status)
	if status.chomp == ' ERROR! MySQL is not running'
		status = %x[mysql.server start]
		warn (status)
	end

### Database config
ActiveRecord::Base.establish_connection(
	:adapter => "mysql",
	:database => "db1",
	:username => "root",
	:password => "",
	:host => "localhost"
)

### Schema
	class Cigar < ActiveRecord::Base
		self.table_name = "cigar"
	end

	class Dataset < ActiveRecord::Base
		self.table_name = "dataset"
	end

	class Notification < ActiveRecord::Base
		self.table_name = "notification"
	end

	class Pattern < ActiveRecord::Base
		self.table_name = "pattern"
	end

	class User < ActiveRecord::Base
		self.table_name = "user"
	end

# taken from http://trevoke.net/blog/2009/11/06/auto-vivifying-hashes-in-ruby/
def nesthash # creates nested hash
	Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
end

### Extract read info from the sam file of reads covering the variant region
# sam_select_read = Hash.new(&(p=lambda{|h,k| h[k] = Hash.new(&p)})) # vivified hash
sam_select_read = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
# sam_select_read = nesthash
print "\nReads_selected_covering the alt allele"
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

### puzzle input reads and alignment cigars to hash
def puzzle_input_all(samstring)
	data = Hash.new {|h,k| h[k] = {} }
	hash = Hash.new {|h,k| h[k] = {} }
	samstring.split("\n").each do |string|
		saminfo = string.split("\t")
		data[saminfo[0]] = saminfo[5]     # read id is key and cigar is value
		term = [saminfo[0], saminfo[1], saminfo[3]].join("_")
		hash[saminfo[0]][term] = 1     # read id is key and cigar is value
	end
	hash.each_key { |key|
		if hash[key].length > 1
			data.delete(key)
		end
	}
	count = data.length
	return data, count
end

### to count number of reads not matching to machine calls cigars
def mismatch_counter_all(cigarstring, samread)
	count = 0
	cigarstring.split(",").each do |cig|
		if samread.key?(Cigar.find_by(id: cig).read_id.to_s) == true
			if samread[Cigar.find_by(id: cig).read_id.to_s] != Cigar.find_by(id: cig).data.to_s
				count = count + 1
			end
		end
	end
	return count
end

### to count number of reads used for puzzle are covering ALT allele
def puzzle_input_select(samstring, samread, data, bamfile)
	hash = Hash.new {|h,k| h[k] = {} }
	readcount = 0;
	samstring.split("\n").each do |string|
		saminfo = string.split("\t")
		if samread.key?(saminfo[0]) == true
			term = [saminfo[0], saminfo[1], saminfo[3]].join("_")
			if data[bamfile].key?(term.to_s) == true
				readcount = readcount + 1
				hash[saminfo[0]] = saminfo[5]
			end
		end
	end
	return hash, readcount
end


### to count number of reads not matching to machine 
### that are selected to cover the varinat position
def mismatch_counter_select(cigarstring, selread)
	count = 0
	cigarstring.split(",").each do |cig|
		if selread.key?(Cigar.find_by(id: cig).read_id.to_s) == true
				if selread[Cigar.find_by(id: cig).read_id.to_s] != Cigar.find_by(id: cig).data.to_s
					count = count + 1
				end
		end
	end
	return count
end

# where method gives an array
# find_by method is one string, it it likely first entry from where method

toplist = File.new("Highscore_info.txt", "w")
toplist.puts "ID\tHighScore\tNoOfUsersWithHighScore\tNoOfReadsinPuzzle\tNoOfUsableReadsinPuzzle\tUserPercentDifferntToBWA\tMeanPercentOfReadsDifferent\tNoOfReadsinPuzzleCovALT\tUserPercentDifferntToBWACovALT\tMeanPercentOfReadsDifferentCovALT\n"

Dataset.find_each(start: 9000, batch_size: 500) do |id|
	# warn (id)
	bamfilename =  Dataset.find_by(id: id).bam_filename                            # bamfile name of current puzzle
	inputreadcount = Dataset.find_by(id: id).sam_file.split("\n").count.to_i 		     # total number of reads
	samreads, allreadcount = puzzle_input_all(Dataset.find_by(id: id).sam_file)				       # hash of read ids in puzzle
	selreads, selreadcount = puzzle_input_select(Dataset.find_by(id: id).sam_file, samreads, sam_select_read, bamfilename)		 # reads covering ALT allele count
	scores = Pattern.where(dataset_id: id).pluck(:score)									         # score array from all patterns of current puzzle
	high = scores.max.to_i

	## Try to avoid puzzles with negative score, or i could use ceratin cut off here to avoid a minimum score puzzles
	if high > 0

		highcount = scores.count(high)
		high_mismatch = 0
		high_read_mm = []
		high_mismatch_sel = 0
		high_read_mm_sel = []

		Pattern.where(dataset_id: id).each do |pattern|
			if pattern.score.to_i == high
				counter = mismatch_counter_all(pattern.cigar_files, samreads).to_i
				selectcount = mismatch_counter_select(pattern.cigar_files, selreads).to_i
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

		toplist.puts "#{Dataset.find_by(id: id).id}\t#{high}\t#{highcount}\t#{inputreadcount}\t#{allreadcount}\t#{high_mmpercent}\t#{high_read_mm_mean}\t#{selreadcount}\t#{high_mm_sel_percent}\t#{high_read_mm_sel_mean}\n"
	end
end

