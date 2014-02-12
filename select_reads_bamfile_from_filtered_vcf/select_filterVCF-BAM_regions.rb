#!/usr/bin/ruby
# encoding: utf-8
#


bamfile = File.read(ARGV[0])

def extract_from_bam (string)
	data = Hash.new {|h,k| h[k] = {} }
	array = string.split("\t")
	upper = array[2] + 5
	lower = array[2] - 5
#	sam = system ("source", "samtools-0.1.19;", "samtools", "view", "bamfile", "#{array[1]}:#{upper}-#{lower}")
	sam = %x[source samtools-0.1.19; samtools view bamfile array[1]:upper-lower]
	alignments = sam.split("\n")
	alignments.each do |string|
		info = string.split("\t")
		data[info[9]] = string
	end
	data
end

outfile = File.new("Test-#{ARGV[0]}-out.sam", "w")

lines = File.read(ARGV[1])
results = lines.split("\n")
results.each do |string|
	hash = extract_from_bam (string)
	hash.each { |key,value|
		outfile.puts  hash[key]
	}
end
