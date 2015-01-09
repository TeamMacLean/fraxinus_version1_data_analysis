#!/usr/bin/ruby
# encoding: utf-8

class Cigar
	class << self

		def alignchunks(cigarstring)
			type = []
			count = []
			leftover = String.new(cigarstring)
			while matches = leftover.match(/^(\d+)([MSID])(.*)/)
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
			while matches = leftover.match(/^(\d+)([MSID])(.*)/)
				yield matches[2], matches[1].to_i
				leftover = matches[3]
			end
			unless leftover.length == 0
				raise "Incorrect parsing of cigar string #{cigarstring}, at the end left with #{leftover}"
			end
		end

		def percent_identity(cigarstring, reference_sequence, refpos, query_sequence_string)
			num_match = 0
			num_mismatch = 0

			#reference_sequence_string = reference_sequence[refpos..reference_sequence.length]
			ref_index = refpos
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

		def aligner(type, count, ref, offset, read)
			alignment = "\t"
			alignment = alignment + ref[0, offset]
			if type.include?("I")
				temp = Array.new(type)
				printpos = offset
				index = 0
				while temp.empty? == false
					if type[index] =~ /[DMS]/
						alignment = alignment + ref[printpos, count[index]]
						printpos = count[index].to_i + printpos
					elsif type[index] =~ /I/
						alignment = alignment + (" " * count[index])
					end
					temp.slice!(0)
					index = 1 + index
				end
				alignment = alignment + ref[printpos..-1]
			else
				alignment = alignment + ref[offset..-1]
			end

			alignment = alignment + "\n\t" + (" " * offset)
			if type.include?("D")
				temp = Array.new(type)
				printpos = 0
				index = 0
				while temp.empty? == false
					if type[index] =~ /[IMS]/
						if type[index] =~ /S/
							alignment = alignment + (read[printpos, count[index]]).downcase
						else
							alignment = alignment + read[printpos, count[index]]
						end
						printpos = count[index].to_i + printpos
					elsif type[index] =~ /D/
						alignment = alignment + (" " * count[index])
					end
					temp.slice!(0)
					index = 1 + index
				end
			else
				alignment = alignment + read
			end
			alignment = alignment + "\n"
			return alignment
		end


		def sw_score(cigarstring, reference_sequence, ref_index, query_sequence_string)
			num_match = 0
			num_mismatch = 0
			num_gap = 0
			gap_score = 0

			#reference_sequence_string = reference_sequence[refpos..reference_sequence.length]
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
					query_index += count
					if (count > 1)
						num_gap += (count - 1)
						gap_score += 5
					else
						gap_score += 5
					end
				when 'D'
					# Extra characters in the reference sequence
					ref_index += count
					if (count > 1)
						num_gap += (count - 1)
						gap_score += 5
					else
						gap_score += 5
					end
				when 'S'
					query_index += count
				else
					raise "Cigar string not parsed correctly. Unrecognised alignment type #{type}"
				end
			end
			score = (num_match.to_i * 1) - (num_mismatch.to_i * 3) - (num_gap.to_i * 2) - gap_score

			return score.to_f
		end

	end
end

