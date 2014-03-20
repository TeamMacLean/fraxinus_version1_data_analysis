#!/usr/bin/ruby
# encoding: utf-8

require 'rubygems'
require 'active_record'
require 'pp'

### Start mysql if it has not started
status = %x[mysql.server status]
# warn (status)
if status.chomp == ' ERROR! MySQL is not running'
	status = %x[mysql.server start]
	# warn (status)
end

### Database config
ActiveRecord::Base.establish_connection(
	:adapter => "mysql",
	:database => "atd",
	:username => "root",
	:password => "user",
	:host => "localhost"
	)

### Schema
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
