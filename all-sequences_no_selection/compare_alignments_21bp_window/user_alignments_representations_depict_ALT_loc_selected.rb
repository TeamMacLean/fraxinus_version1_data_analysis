#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'
require './cigar_class'
require 'pp'

puzzles = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
input = File.read(ARGV[0])
input.split("\n").each do | puzzle |
	line = puzzle.gsub(">", "").split("\t")
	lineid = [line[0], line[1]].join("_")
	puzzles[line[3]][lineid][puzzle] = 1
		#   bamfile   ref & seq  line
end

Dir.glob("*.vcf") do |filename|
	bamfilename = filename.gsub("\.vcf", "")
	variants = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
	sam = File.read(filename)
	sam.split("\n").each do |entry|
		if entry !~ /^\#/
			info = entry.split("\t")
			puzzleid = [info[4], info[3]].join("_")
			if puzzles[bamfilename.to_s].key?(puzzleid.to_s) == true
				puzzles[bamfilename.to_s][puzzleid.to_s].each_key { |key|
					print "#{info[4]}\t#{info[3]}\t#{info[5]}\t#{key}\t"

					data = key.split("\t")
					pos_in_play = data[2].to_i
					bwapos = data[12].to_i
					readseq = data[13]
					bwacigar = data[14].to_s
					playercigar = data[15].to_s
					playerpos = data[16].to_i

					if bwacigar != '*'
						# now we have real variant position and long reference sequence around the 21bp pattern
						correct_pos_in_play = info[5].to_i - 10
						# 102074 - 10
						difference = correct_pos_in_play - pos_in_play
						# 102064-102024 = 40
						corrected_playerpos = playerpos + difference
						# 101986 + 40 = 102026
						longref_startpos = info[1].to_i

						types, counts = Cigar.alignchunks(bwacigar)
						newcigar = ""
						i = 0
						if bwapos < pos_in_play
							puzzlelen = 21
							to_cut = pos_in_play - bwapos
							if types[0] =~ /S/
								to_cut += counts[0]
							end
							while to_cut > 0 and i < types.length do
								if types[i] =~ /I/
									to_cut += counts[i]
									i += 1
									next
								end
								to_cut -= counts[i]
								if to_cut <= 0
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

							while puzzlelen > 0 and i < types.length do
								if types[i] =~ /I/
									newcigar = [newcigar, counts[i], types[i]].join("")
									i += 1
									next
								end
								puzzlelen -= counts[i]
								if puzzlelen <= 0
									newcigar = [newcigar, counts[i]+puzzlelen, types[i]].join("")
								else
									newcigar = [newcigar, counts[i], types[i]].join("")
								end
								i += 1
							end
						elsif bwapos > pos_in_play
							puzzlelen = 21 - (bwapos - pos_in_play)

							while puzzlelen > 0 and i < types.length do
								if types[0] =~ /S/
									i += 1
									next
								elsif types[i] =~ /I/
									newcigar = [newcigar, counts[i], types[i]].join("")
									i += 1
									next
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

=begin
						initial_gap = bwapos.to_i - longref_startpos
						adjusted = initial_gap
						if types[0] =~ /S/
							adjusted = adjusted - counts[0].to_i # BWA cigar treats alingment position after soft clipping (default)
						end
						percent, match, mismatch = Cigar.percent_identity(bwacigar, info[0].upcase, initial_gap, readseq)
=end

						types2, counts2 = Cigar.alignchunks(playercigar)
						newplayercigar = ""
						i = 0
						if corrected_playerpos < pos_in_play
							puzzlelen = 21
							to_cut = pos_in_play - corrected_playerpos
							while to_cut > 0 and i < types2.length do
								if types2[i] =~ /I/
									to_cut += counts2[i]
									i += 1
									next
								end
								to_cut -= counts2[i]
								if to_cut <= 0
									if (to_cut.abs >= puzzlelen)
										newplayercigar = [newplayercigar, puzzlelen, types2[i]].join("")
										puzzlelen = 0
									elsif (to_cut.abs > 0)
										newplayercigar = [newplayercigar, to_cut.abs, types2[i]].join("")
										puzzlelen -= to_cut.abs
									end
								end
								i += 1
							end

							while puzzlelen > 0 and i < types2.length do
								if types2[i] =~ /I/
									newplayercigar = [newplayercigar, counts2[i], types2[i]].join("")
									i += 1
									next
								end
								puzzlelen -= counts2[i]
								if puzzlelen < 0
									newplayercigar = [newplayercigar, counts2[i]+puzzlelen, types2[i]].join("")
								else
									newplayercigar = [newplayercigar, counts2[i], types2[i]].join("")
								end
								i += 1
							end
						elsif corrected_playerpos > pos_in_play
							puzzlelen = 21 - (corrected_playerpos - pos_in_play)

							while puzzlelen > 0 and i < types2.length do
								if types2[0] =~ /S/
									i += 1
									next
								elsif types2[i] =~ /I/
									newplayercigar = [newplayercigar, counts2[i], types2[i]].join("")
									i += 1
									next
								end
								puzzlelen -= counts2[i]
								if puzzlelen <= 0
									newplayercigar = [newplayercigar, counts2[i]+puzzlelen, types2[i]].join("")
								else
									newplayercigar = [newplayercigar, counts2[i], types2[i]].join("")
								end
								i += 1
							end

						end

						print "#{newcigar}\t#{newplayercigar}\n"

=begin
						initial_gap2 = corrected_playerpos - longref_startpos
						adjusted2 = initial_gap2
						if types2[0] =~ /S/
							adjusted2 = adjusted2 + counts2[0].to_i # Fraxinus cigar treats alingment position begining of a read even for soft clipping (take care about this)
						end
						percent2, match2, mismatch2 = Cigar.percent_identity(playercigar, info[0].upcase, adjusted2, readseq)

						if percent2 > percent and (percent2 - percent) > 1
						# if percent2 > percent
							stats = [percent, match, mismatch, percent2, match2, mismatch2].join("\t")
							bwaalign = Cigar.aligner(types, counts, info[0], adjusted, readseq)
							playeralign = Cigar.aligner(types2, counts2, info[0], initial_gap2, readseq)
							alignments = [bwaalign, playeralign].join("_")
							keyid = [puzzleid, correct_pos_in_play].join("_")
							variants[keyid][key][stats] = alignments
						end
=end

					end
				}
			end
		end
	end

=begin
	file = File.new("#{bamfilename}_player_alignments_selected.txt", "w")
	variants.each_key { |key|
		# if variants[key].length > 1
			file.print "#{key}\n"
			useraln = []
			variants[key].each_key { |puzzle|
				variants[key][puzzle].each_key { |stats|
					alns = variants[key][puzzle][stats].split("_")
					file.print "#{alns[0]}"
					useraln.push(alns[1])
				}
			}
			file.print "Player alignments\n"
			useraln.each { |aln|
				file.print "#{aln}"
			}
		# end
	}
=end
end


=begin
	# print "#{info[4]}\t#{info[3]}\t#{info[5]}\t#{key}\n"
	print "\t#{percent}\t#{match}\t#{mismatch}\n"
	print "\t#{percent2}\t#{match2}\t#{mismatch2}\t#{data[20]}\n"
	print "\n"
	data = key.split("\t")
	refid = data[0]
	pattern = data[1]
	pos_in_play = data[2]
	bamfile = data[3]
	readid = data[14]
	bwapos = data[15]
	readseq = data[16]
	bwacigar = data[17]
	playercigar = data[18]
	playerpos = data[19]

=end
