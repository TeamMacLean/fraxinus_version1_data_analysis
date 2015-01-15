#!/usr/bin/ruby
# encoding: utf-8
#

require 'csv'
require 'bio'

data = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
## Open gff file from scaffolds and parse gene records with Ontology_term and descriptions
## selected genes are pushed to a hash
gff1 = Bio::GFF::GFF3.new(File.read(ARGV[0]))
gff1.records.each do | record |
	if record.feature == 'gene'
		geneid = record.get_attributes('ID').join(" ")
		#go = record.get_attributes('Ontology_term')
		godes = record.get_attributes('ontology_term_description').join(" ")
		if godes == ''
			godes = 'NA'
		end
		data[geneid] = godes
	end
end

contigs = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
## Open gff file of genes on contigs
## and parse gene records and their limits
gff2 = Bio::GFF::GFF3.new(File.read(ARGV[1]))
gff2.records.each do | record |
	if record.feature == 'gene'
		geneid = record.get_attributes('ID').join(" ").gsub(/\.\d$/, '')
		limits = [record.start, record.end].join("_")
		contigs[record.seqid][geneid] = limits
	end
end

variants = Hash.new {|h,k| h[k] = {} }
## Open alignments comparison file from Fraxinus analysis
## and store improved variant locations to a hash
## file header
## variant	contig_id	pattern	pos	BWA_CIGAR	BWA_ALGN	PLAY_CIGAR	PLAY_ALGN	BWA_READ	PLAY_READ	BWA_WIN	PLAY_WIN
lines = File.read(ARGV[2])
lines.split("\n").each do |line|
	if line !~ /^variant/
		array1 = line.split("\t")
		if (array1[11].to_f > array1[10].to_f) and (array1[9].to_f >= array1[8].to_f)
			term = [array1[0], array1[1], array1[2], array1[3]].join("_")
			variants[array1[1]][term] = array1[3]
		end
	end
end

candis = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
variants.each_key { |contig|
	variants[contig].each_key { |selected|
		contigs[contig].each_key { |gene|
			coord = contigs[contig][gene].split("_")
			# warn "#{gene}\t#{coord[0].to_i}\t#{coord[1].to_i}"
			if (variants[contig][selected].to_i >= coord[0].to_i) and (variants[contig][selected].to_i <= coord[1].to_i)
				candis[selected][gene] = 1
			end
		}
	}
}

## New file is opened to write the selected variants info
outfile = File.new("Selected_gene_goids.txt", "w")
variants.each_key { |contig2|
	variants[contig2].each_key { |selected2|
		outfile.print "#{selected2}"
		if candis.has_key?(selected2)
			candis[selected2].each_key { |terms|
				outfile.print "\t#{data[terms]}"
			}
			outfile.print "\n"
		else
			outfile.print "\tNo genes\n"
		end
	}
}
