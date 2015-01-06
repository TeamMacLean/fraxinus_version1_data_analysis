#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'
require 'pp'


data = Hash.new {|h,k| h[k] = {} }
lines = File.read(ARGV[0])
lines.split("\n").each do |line|
	array = line.split("\t")
	id = array[2].gsub(">", "")
	data[array[3]] = id
end


vcflines = File.read(ARGV[1])
vcflines.split("\n").each do |vcf|
	if vcf !~ /^#/
    	array1 = vcf.split("\t")
    	hashkey = array1[0][4, 21]
    	if data.key?(hashkey) == true
    		# warn(hashkey)
    		if array1[1] == data[hashkey]
    			array1.shift
				# puts vcf
				puts array1.join("\t")
			end
		end
	end
end
