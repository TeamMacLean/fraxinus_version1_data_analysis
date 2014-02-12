#!/usr/bin/ruby
# encoding: utf-8
#
#  filter_vcf_for_app.rb
#
#  Created by Dan MacLean (TSL) on 2013-06-06.
#  Copyright (c). All rights reserved.
#
require 'pp'
require 'json'
require 'csv'
require 'bio'
require 'bio-samtools'
require 'barmcakes'
require 'bio-gngm'


def ref_sequence_is_ok?(vcf,fasta)
  subseq = fasta[vcf.chrom].subseq(vcf.pos - 10, vcf.pos + 10)
  return false if subseq =~ /[^ATCG]/i
  subseq
end

def is_useable?(vcf,fasta,p) 
  params = {
    :min_depth => p[:min_depth],
    :mapping_quality => p[:mapping_quality],
    :min_non_ref_count => (vcf.used_depth / p[:min_non_ref_count_divisor]).floor,
    :min_snp_quality => p[:min_snp_quality]
  }


  if (vcf.is_mnp? params or vcf.is_snp? params or vcf.is_indel? params) \
  and ( (vcf.pos - 10) > 1) \
  and ( (vcf.pos + 10) < fasta[vcf.chrom].length) \
  and (vcf.alternatives.length > 0) \
  and not (vcf.alt =~ /[^ATGC\,]/i) \
  and not (vcf.ref =~ /[^ATGC]/i)
    return true
  end
  false
end

def longref_sequence(vcf,fasta)
  start = 1
  stop = fasta[vcf.chrom].length
  if ((vcf.pos - 100) >1 )
    start = vcf.pos - 100
  end
  if ((vcf.pos + 100) < fasta[vcf.chrom].length )
    stop = vcf.pos + 100
  end
  subseq = fasta[vcf.chrom].subseq(start, stop)
  return subseq, start, stop
end

args = Arrghs.parse(ARGV)

[:vcf, :fasta].each do |opt| 
  unless args.has_key?(opt)
    $stderr.puts "missing opt #{opt}\nusage: filter_vcf_for_app.rb\n\t--vcf <vcf_file>\n\t--fasta <fasta_file>"
    exit
  end
end  

fasta = Hash.new
file = Bio::FastaFormat.open(args[:fasta])
file.each do |entry|
 fasta[entry.entry_id] = entry.seq
end

#pp fasta

params = {
  :min_depth => 10,
  :mapping_quality => 20,
  :min_non_ref_count_divisor => 10, #not absolute count, is the denominator in the ratio depth / min_non_ref_count to give the propn of the depth that the non-ref bases should take up
  :min_snp_quality => 20
}

puts "##{params.to_s}"

File.open(args[:vcf], "r").each_except_comments do |record|
  vcf = Bio::DB::Vcf.new(record)
  if is_useable?(vcf,fasta,params) and subseq = ref_sequence_is_ok?(vcf,fasta)
    longseq, start, stop = longref_sequence(vcf,fasta)
    longseq2 = longseq.gsub(subseq, subseq.downcase)
    puts [longseq2, start, stop, subseq, record].join("\t")
  end
end
