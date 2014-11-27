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

genes = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
## Open gff file of genes on contigs
## and parse gene records and their limits
gff2 = Bio::GFF::GFF3.new(File.read(ARGV[1]))
gff2.records.each do | record |
	if record.feature == 'gene'
		geneid = record.get_attributes('ID').join(" ").gsub(/\.\d$/, '')
		limits = [record.start, record.end].join("_")
		genes[geneid] = limits
	end
end

=begin

CSV.foreach(ARGV[0], :headers => true) do |csv_row|
  ## Based on header info each gene info is placed to a hash and all splice variant information is stored under one gene name
  geneid = (csv_row['gene']).gsub(/\.\d$/, "")
#  puts geneid
  if data.key?(geneid) == true
  	if (data[geneid][csv_row['database']]).key?(csv_row['id']) == false
		data[geneid][csv_row['database']][csv_row['id']] = csv_row['description']
	end
  else
	data[geneid][csv_row['database']][csv_row['id']] = csv_row['description']
  end
end

## New file is opened to write the gff info
outfile = File.new("Chalara_fraxinea_ass_s1v1_ann_v1.1.gene_goids.gff", "w")
	outfile.puts "##gff-version 3"
	outfile.puts "##In addition to 'Ontology_term', 'ontology_term_description', 'PFAM' and 'PFAM_description' was added to Attributes field"

=end