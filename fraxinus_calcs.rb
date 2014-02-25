#!/usr/bin/ruby
# encoding: utf-8

### puzzle input reads and alignment cigars to hash
class Fraxinus
  class << self

  	### Returns hash of read ids and number of reads in the current pattern
	def allreads(samstring)
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

	### Returns hash of read ids and number of reads used in the current pattern, that are covering ALT allele
	def selectreads(samstring, samread, data, bamfile)
		hash = Hash.new {|h,k| h[k] = {} }
		readcount = 0;
		samstring.split("\n").each do |string|
			#warn (string)
			saminfo = string.split("\t")
			if samread.key?(saminfo[0]) == true
				#warn (saminfo[0])
				term = [saminfo[0], saminfo[1], saminfo[3]].join("_")
				#warn(term)
				if data[bamfile].key?(term.to_s) == true
					#warn (term)
					readcount += 1
					hash[saminfo[0]] = saminfo[5]
				end
			end
		end
		# readcount = 30
		#warn (hash.length)
		return hash, readcount
	end

	### Returns number of reads not matching to machine call cigars
	### funcation inputs are string of cigar ids from pattern table and hash of all read ids
	def mm_allreads(cigarstring, samread)
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

	### Returns number of reads not not matching to machine cigars
	### that are selected to cover the varinat position
	### funcation inputs are string of cigar ids from pattern table and hash of selected read ids
	def mm_selreads(cigarstring, selread)
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
  end
end
