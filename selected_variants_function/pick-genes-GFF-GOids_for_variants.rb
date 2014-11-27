#!/usr/bin/ruby
# encoding: utf-8
#

require 'csv'
require 'bio'

data = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
## Open gff file from scaffolds and parse gene records with Ontology_term and descriptions
## selected genes are pushed to a hash
gff3 = Bio::GFF::GFF3.new(File.read(ARGV[0]))
gff3.records.each do | record |
	if record.feature == 'gene'
		geneid = record.get_attributes('ID')
		#go = record.get_attributes('Ontology_term')
		godes = record.get_attributes('ontology_term_description')
		data[geneid] = godes
	end
end

=begin
## Existing gff file is parsed and gene records are appended with Ontology_term and descriptions
gff3 = Bio::GFF::GFF3.new(File.read(ARGV[1]))
gff3.records.each do | record |
  if record.feature == 'gene'
  	geneid = record.get_attributes('ID')
  	if  data.key?(geneid[0]) == true
  		data[geneid[0]].each { |database, v1|
	  		array_term = []
	  		array_descrip = []
  			data[geneid[0]][database].each { |id, v2|
  				array_term.push(id)
		  		array_descrip.push(v2)
		  	}
		  	if database == 'GO'
				record.attributes <<   ["Ontology_term", array_term.join(',')]
				record.attributes <<   ["ontology_term_description", array_descrip.join(',')]
			elsif database == 'PFAM'
				record.attributes <<   ["PFAM", array_term.join(',')]
				record.attributes <<   ["PFAM_description", array_descrip.join(',')]
			end
		}
	  outfile.puts "#{record.to_s}"
	else
	  outfile.puts "#{record.to_s}"
	end
  else
    outfile.puts "#{record.to_s}"
  end
end


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