#!/usr/bin/ruby
# encoding: utf-8
#
# ruby ./export-mysql.rb

require 'rubygems'
require 'active_record'
require 'pp'

# Start mysql as a precaution. will have to check if i make it conditional (like start only when it is not started)
%x[mysql.server start]

# Database config
ActiveRecord::Base.establish_connection(
  :adapter => "mysql",
  :database => "db1",
  :username => "root",
  :password => "",
  :host => "localhost"
)

# Schema
class Cigar < ActiveRecord::Base
  self.table_name = "cigar"
end

class Dataset < ActiveRecord::Base
  self.table_name = "dataset"
end

class Notification < ActiveRecord::Base
  self.table_name = "notification"
end

class Pattern < ActiveRecord::Base
  self.table_name = "pattern"
end

class User < ActiveRecord::Base
  self.table_name = "user"
end

# where method gives an array
# find_by method is one string, it it likely first entry from where method

bamfiles = Dataset.pluck(:bam_filename)
bamfiles = bamfiles.uniq
puts "bam_filename\tPattern_count"
bamfiles.each do |bamfile|
  n = 0
  samout = File.new("Dataset_sam-entries-#{bamfile}.sam", "w")
  variant = File.new("Dataset_entries-#{bamfile}.txt", "w")
  Dataset.find_each do |id|
    if Dataset.find_by(id: id).bam_filename == bamfile
      variant.puts "#{Dataset.find_by(id: id).id}\t#{Dataset.find_by(id: id).pos}\t#{Dataset.find_by(id: id).base_pattern.gsub("\n","\t")}\t#{Dataset.find_by(id: id).bam_filename}"
      samout.puts Dataset.find_by(id: id).sam_file
      n = 1 + n
    end
  end
  puts "#{bamfile}\t#{n}"
end
