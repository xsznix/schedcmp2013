# encoding: utf-8

#DataMapper::Logger.new(STDOUT, :debug) # DEBUG, logs SQL queries
#DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"
DataMapper.setup(:default, ENV['JUSTONEDB_DBI_URL'] || "sqlite://#{Dir.pwd}/database.db")
#DataMapper.setup :default, 'sqlite::memory:'

require_relative 'fuzzysearch'
require_relative 'scheduledcourse'
require_relative 'studenttrigram'
require_relative 'student'
DataMapper.finalize.auto_upgrade!
DataMapper::Model.raise_on_save_failure = false
#require 'dm-sweatshop'
#require_relative 'fixtures'