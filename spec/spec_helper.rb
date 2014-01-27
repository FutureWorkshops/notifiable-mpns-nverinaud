ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require 'simplecov-rcov'
require 'database_cleaner'
require 'active_record'
require 'rails'
require 'notifiable'
require 'webmock/rspec'
require File.expand_path("../../lib/notifiable/mpns/nverinaud",  __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter "/spec/"
end

db_path = 'spec/support/db/test.sqlite3'
DatabaseCleaner.strategy = :truncation

Rails.logger = Logger.new(STDOUT)

RSpec.configure do |config|  
  config.mock_with :rspec
  config.order = "random"
  
  config.before(:all) {
    
    # DB setup
    ActiveRecord::Base.establish_connection(
     { :adapter => 'sqlite3',
       :database => db_path,
       :pool => 5,
       :timeout => 5000}
    )
    
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate "spec/support/db/migrate"
  }
  
  config.before(:each) {
    DatabaseCleaner.start
  }
  
  config.after(:each) {
    DatabaseCleaner.clean
  }
  
  config.after(:all) {    
    # drop the database
    File.delete(db_path)
  }
end


User = Struct.new(:device_token) do
  def device_tokens
    [device_token]
  end
end
