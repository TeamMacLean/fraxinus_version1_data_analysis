#!/usr/bin/ruby
# encoding: utf-8
#

def extract_from_bam(line)
	data = Hash.new {|h,k| h[k] = {} }
	bamfile = ARGV[0]
	array = line.split("\t")
	File.new("Reading-out.sam", "w")
#	puts "source samtools-0.1.19; samtools view #{bamfile} #{array[1]}:#{array[2]}-#{array[2]} -o Reading-out.sam"
	%x[source samtools-0.1.19; samtools view #{bamfile} #{array[1]}:#{array[2]}-#{array[2]} -o Reading-out.sam]
	sam = File.read("Reading-out.sam")
	alignments = sam.split("\n")
	alignments.each do |string|
		info = string.split("\t")
		data[info[9]] = string
	end
	data
end

outfile = File.new("Test-#{ARGV[0]}-out.sam", "w")
headers = %x[source samtools-0.1.19; samtools view -H #{ARGV[0]}]
outfile.puts headers

lines = File.read(ARGV[1])
results = lines.split("\n")
results.each do |string|
  if string !~ /^#/
#	puts string
	hash = extract_from_bam(string)
	hash.each { |key,value|
		outfile.puts  hash[key]
	}
  end
end

