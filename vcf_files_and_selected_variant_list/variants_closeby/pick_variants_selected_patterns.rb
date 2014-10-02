#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'

data = Hash.new {|h,k| h[k] = {} }
Dir.glob("*.vcf") do |vcffile|
	print "#{vcffile}\n"
	vcflines = File.read(vcffile)
	vcflines.split("\n").each do |vcf|
		if vcf =~ /^Cf/
			array1 = vcf.split("\t")
			variant = ''
			if array1[7] =~ /^INDEL/
				variant = 'indel'
			else
				variant = 'snp'
			end
			data[array1[0]][array1[1].to_i] = variant
		end
	end

	data.each_key { |scaffold|
		previous = ''
		contig = ''
		data[scaffold].keys.sort.each { |position|
			if previous == ''
				previous = position.to_i
				contig = scaffold
			else
				diff = position.to_i - previous
				if diff < 75
					print "#{contig}\t#{previous}\t#{data[contig][previous]}\t#{scaffold}\t#{position}\t#{data[scaffold][position]}\t#{diff}\n"
				end
				previous = position.to_i
				contig = scaffold
			end
		}
	}
	print "\n"
end
