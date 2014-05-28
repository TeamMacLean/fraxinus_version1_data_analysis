#!/usr/bin/ruby
# encoding: utf-8

class Cigar
	class << self

		def alignchunks(cigarstring)
			type = []
			count = []
			leftover = String.new(cigarstring)
			while matches = leftover.match(/^(\d+)([MSIDHNXP\=])(.*)/)
				count.push matches[1].to_i
				type.push matches[2]
				leftover = matches[3]
			end
			unless leftover.length == 0
				raise "Incorrect parsing of cigar string #{cigarstring}, at the end left with #{leftover}"
			end
			return type, count
		end

		def each_alignchunk(cigarstring)
			leftover = String.new(cigarstring)
			while matches = leftover.match(/^(\d+)([MSIDHNXP\=])(.*)/)
				yield matches[2], matches[1].to_i
				leftover = matches[3]
			end
			unless leftover.length == 0
				raise "Incorrect parsing of cigar string #{cigarstring}, at the end left with #{leftover}"
			end
		end

		def percent_identity(cigarstring, reference_sequence, ref_index, query_sequence_string)
			num_match = 0
			num_mismatch = 0

			types, counts = alignchunks(cigarstring)
			if types[0] =~ /S/
				ref_index -= counts[0]
			end
			query_index = 0
			each_alignchunk(cigarstring) do |type, count|
				case type
				when 'M'
					(0...count).each do |i|
						if reference_sequence[ref_index+i] == query_sequence_string[query_index+i]
							# warn("#{ref_index+i}\t#{reference_sequence[ref_index+i]}\t#{query_index+i}\t#{query_sequence_string[query_index+i]}\n")
							num_match += 1
						else
							num_mismatch += 1
						end
					end
					ref_index += count
					query_index += count
				when 'I'
					# Extra characters in the query sequence
					num_mismatch += count
					query_index += count
				when 'D'
					# Extra characters in the reference sequence
					num_mismatch += count
					ref_index += count
				when 'S'
					query_index += count
				else
					raise "Cigar string not parsed correctly. Unrecognised alignment type #{type}"
				end
			end
			percent = num_match.to_f/(num_match+num_mismatch)*100

			return percent, num_match, num_mismatch
		end

		def aligner(cigarstring, ref, ref_index, read)
			type, count = alignchunks(cigarstring)
			if type[0] =~ /S/
				ref_index -= count[0]
			end
			alignment = "\t"
			alignment += ref[0, ref_index]
			if type.include?("I")
				temp = Array.new(type)
				printpos = ref_index
				index = 0
				while temp.empty? == false
					if type[index] =~ /[DMS]/
						alignment += ref[printpos, count[index]]
						printpos += count[index].to_i
					elsif type[index] =~ /I/
						alignment += (" " * count[index])
					end
					temp.slice!(0)
					index += 1
				end
				if printpos < ref.length.to_i
					alignment += ref[printpos..-1]
				end
			else
				alignment += ref[ref_index..-1]
			end

			alignment += "\n\t" + (" " * ref_index)
			if type.include?("D") or type.include?("S") 
				temp = Array.new(type)
				printpos = 0
				index = 0
				while temp.empty? == false
					if type[index] =~ /[IMS]/
						if type[index] =~ /S/
							alignment += (read[printpos, count[index]]).downcase
						else
							if printpos < read.length.to_i
								alignment += read[printpos, count[index]]
							end
						end
						printpos += count[index].to_i
					elsif type[index] =~ /D/
						alignment += (" " * count[index])
					end
					temp.slice!(0)
					index += 1
				end
			else
				alignment += read
			end
			alignment += "\n"
			return alignment
		end

		def newcigars(cigar, pattern_positon, align_position)
			types, counts = alignchunks(cigar)
			newcigar = ""
			begin_trim = 0
			end_trim = 0
			newalnpos = 0
			i = 0
			if align_position < pattern_positon
				newalnpos = pattern_positon
				puzzlelen = 21
				to_cut = pattern_positon - align_position
				begin_trim += to_cut
				while to_cut > 0 and i < types.length do
					if types[i] =~ /I/ or types[i] =~ /S/
						begin_trim += counts[i]
						i += 1
						next
					elsif types[i] =~ /D/
						begin_trim -= counts[i]
					end					
					to_cut -= counts[i]
					if to_cut < 0
						if (to_cut.abs >= puzzlelen)
							newcigar = [newcigar, puzzlelen, types[i]].join("")
							puzzlelen = 0
						elsif (to_cut.abs > 0)
							newcigar = [newcigar, to_cut.abs, types[i]].join("")
							puzzlelen -= to_cut.abs
						end
					end
					i += 1
				end
				end_trim += (begin_trim + 21)
				while puzzlelen > 0 and i < types.length do
					if types[i] =~ /I/
						newcigar = [newcigar, counts[i], types[i]].join("")
						end_trim += counts[i]
						i += 1
						next
					end
					if types[i] =~ /D/
						end_trim -= counts[i]
					end	
					puzzlelen -= counts[i]
					if puzzlelen <= 0
						newcigar = [newcigar, counts[i]+puzzlelen, types[i]].join("")
					else
						newcigar = [newcigar, counts[i], types[i]].join("")
					end
					i += 1
				end
			elsif align_position >= pattern_positon
				newalnpos = align_position
				puzzlelen = 21 - (align_position - pattern_positon)
				end_trim += puzzlelen
				while puzzlelen > 0 and i < types.length do
					if types[i] =~ /S/
						begin_trim += counts[i]
						end_trim += counts[i]
						i += 1
						next
					elsif types[i] =~ /I/
						newcigar = [newcigar, counts[i], types[i]].join("")
						end_trim += counts[i]
						i += 1
						next
					elsif types[i] =~ /D/
						end_trim -= counts[i]
					end
					puzzlelen -= counts[i]
					if puzzlelen <= 0
						newcigar = [newcigar, counts[i]+puzzlelen, types[i]].join("")
					else
						newcigar = [newcigar, counts[i], types[i]].join("")
					end
					i += 1
				end
			end
			return newcigar, begin_trim, end_trim, newalnpos
		end

	end
end

