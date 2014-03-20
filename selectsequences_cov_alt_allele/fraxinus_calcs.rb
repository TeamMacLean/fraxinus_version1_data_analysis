#!/usr/bin/ruby
# encoding: utf-8

### puzzle input reads and alignment cigars to hash
class Fraxinus
  class << self

  	### Returns hash of read ids and number of reads in the current pattern
  	def allreads(samstring)
  		samread = Hash.new {|h,k| h[k] = {} }
  		hash = Hash.new {|h,k| h[k] = {} }
  		samstring.split("\n").each do |string|
  			saminfo = string.split("\t")
			samread[saminfo[0]][:cigar] = saminfo[5]    # read id is key and cigar is value
			hash[saminfo[0]][string] = 1     # hash to count alignments for a read id used in the pattern
		end
		# then delete read ids with more than one alignment information (only for first version of Fraxinus datasets)
		hash.each_key { |key|
			if hash[key].length > 1
				samread.delete(key)
			end
		}
		count = samread.length
		return samread, count
	end

	### Returns hash of read ids and number of reads used in the current pattern, that are covering ALT allele
	def selectreads(samstring, samread, data, bamfile)
		selread = Hash.new {|h,k| h[k] = {} }
		readcount = 0;
		samstring.split("\n").each do |string|
			saminfo = string.split("\t")
			if samread.key?(saminfo[0]) == true
				term = [saminfo[0], saminfo[1], saminfo[3]].join("_")
				if data[bamfile].key?(term.to_s) == true
					readcount += 1
					selread[saminfo[0]][:cigar] = saminfo[5]
				end
			end
		end
		return selread, readcount
	end


	### Returns hash of read ids and number of reads used in the current pattern, that are covering ALT allele
	def hash_selectreads(samstring, samread, data, bamfile)
		selread = Hash.new {|h,k| h[k] = {} }
		readcount = 0;
		samstring.split("\n").each do |string|
			saminfo = string.split("\t")
			if samread.key?(saminfo[0]) == true
				term = [saminfo[0], saminfo[1], saminfo[3]].join("_")
				if data[bamfile].key?(term.to_s) == true
					readcount += 1
					selread[saminfo[0]][:cigar] = saminfo[5]							# read id is key and cigar is value
					selread[saminfo[0]][:seq] = [saminfo[3], saminfo[9]].join("\t")	# read id is key and alignment position & read sequence is value
				end
			end
		end
		return selread, readcount
	end

	### Returns number of reads not matching to machine call cigars
	### funcation inputs are string of cigar ids from pattern table and hash of all read ids
	def mm_allreads(cigarstring, samread)
		count = 0
		cigarstring.split(",").each do |cig|
			cigar = Cigar.find_by(id: cig)
			if samread.key?(cigar.read_id.to_s) == true
				if samread[cigar.read_id.to_s][:cigar] != cigar.data.to_s
					count = count + 1
				end
			end
		end
		return count
	end

	### Returns number of reads not not matching to machine cigars
	### that are selected to cover the varinat position
	### funcation inputs are string of cigar ids from pattern table and hash of selected read ids
	def mm_selreads(cigarstring, selread)
		count = 0
		cigarstring.split(",").each do |cig|
			cigar = Cigar.find_by(id: cig)
			if selread.key?(cigar.read_id.to_s) == true
				if selread[cigar.read_id.to_s][:cigar] != cigar.data.to_s
					count = count + 1
				end
			end
		end
		return count
	end

	### Returns number of reads not not matching to machine cigars and hash of respective read ids
	### that are selected to cover the varinat position
	### funcation inputs are string of cigar ids from pattern table and hash of selected read ids
	def hash_mm_selreads(cigarstring, selread)
		hash = Hash.new {|h,k| h[k] = {} }
		count = 0
		cigarstring.split(",").each do |cig|
			cigar = Cigar.find_by(id: cig)
			if selread.key?(cigar.read_id.to_s) == true
				if selread[cigar.read_id.to_s][:cigar] != cigar.data.to_s
					hash[cigar.read_id] = [cigar.data, cigar.pos].join("\t")
					count = count + 1
				end
			end
		end
		return hash, count.to_i
	end

  end
end

